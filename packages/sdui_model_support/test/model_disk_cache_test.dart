import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_model_support/sdui_model_support.dart';

void main() {
  late Directory dir;

  setUp(() => dir = Directory.systemTemp.createTempSync('sdui_models_'));
  tearDown(() => dir.deleteSync(recursive: true));

  final url = Uri.parse('http://host/assets/a.glb');

  group('ModelDiskCache', () {
    test('쓴 모델과 서버 검증값을 다시 읽는다', () async {
      final disk = ModelDiskCache(directory: () => dir);

      expect(await disk.read(url), isNull);
      await disk.write(
        url,
        Uint8List.fromList([1, 2, 3]),
        etag: 'W/"1"',
        lastModified: 'Mon, 02 Nov 2026 06:40:59 GMT',
      );

      final stored = await ModelDiskCache(directory: () => dir).read(url);
      expect(stored!.bytes, [1, 2, 3]);
      expect(stored.etag, 'W/"1"');
      expect(stored.lastModified, 'Mon, 02 Nov 2026 06:40:59 GMT');
    });

    test('maxBytes를 넘으면 가장 오래 안 쓴 모델부터 지운다', () async {
      final disk = ModelDiskCache(directory: () => dir, maxBytes: 10);
      Uri at(String name) => Uri.parse('http://host/$name.glb');
      Future<void> put(String name) async {
        await disk.write(at(name), Uint8List(4));
        // File times are coarse on some file systems.
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }

      await put('a');
      await put('b');
      // A read's touch keeps whole seconds on some file systems.
      await Future<void>.delayed(const Duration(milliseconds: 1100));
      expect(await disk.read(at('a')), isNotNull); // a is now the newest
      await put('c');

      expect(await disk.read(at('a')), isNotNull);
      expect(await disk.read(at('b')), isNull);
      expect(await disk.read(at('c')), isNotNull);
    });

    test('파일 이름 키는 URL마다 16자리 16진수다', () {
      final a = ModelDiskCache.key(url);
      final b = ModelDiskCache.key(Uri.parse('http://host/assets/b.glb'));

      expect(a, matches(RegExp(r'^[0-9a-f]{16}$')));
      expect(b, matches(RegExp(r'^[0-9a-f]{16}$')));
      expect(a, isNot(b));
      expect(ModelDiskCache.key(url), a);
    });

    test('디렉터리를 못 쓰면 실패 없이 비어 있는 캐시처럼 군다', () async {
      final disk = ModelDiskCache(
        directory: () => throw const FileSystemException('no cache dir'),
      );

      await disk.write(url, Uint8List.fromList([1]));
      expect(await disk.read(url), isNull);
    });
  });

  group('ModelBytesCache with disk', () {
    test('한 번 받은 모델은 다음 실행에서 저장본을 바로 쓰고 뒤에서 확인만 한다', () async {
      final requests = <http.Request>[];
      ModelBytesCache cache() => ModelBytesCache(
        baseUrl: Uri.parse('http://host/'),
        disk: ModelDiskCache(directory: () => dir),
        client: MockClient((request) async {
          requests.add(request);
          if (request.headers['If-None-Match'] == 'W/"1"') {
            return http.Response('', 304);
          }
          return http.Response.bytes(
            [1, 2, 3],
            200,
            headers: {'etag': 'W/"1"'},
          );
        }),
      );

      final first = cache();
      expect(await first.load('/assets/a.glb'), [1, 2, 3]);
      await first.settle();

      final next = cache();
      expect(await next.load('/assets/a.glb'), [1, 2, 3]);
      await next.settle();

      expect(requests, hasLength(2));
      expect(requests.last.headers['If-None-Match'], 'W/"1"');
    });

    test('서버에서 바뀐 모델은 다음 실행부터 새 파일을 쓴다', () async {
      var version = 1;
      ModelBytesCache cache() => ModelBytesCache(
        baseUrl: Uri.parse('http://host/'),
        disk: ModelDiskCache(directory: () => dir),
        client: MockClient((request) async {
          final etag = 'W/"$version"';
          if (request.headers['If-None-Match'] == etag) {
            return http.Response('', 304);
          }
          return http.Response.bytes([version], 200, headers: {'etag': etag});
        }),
      );

      final first = cache();
      expect(await first.load('/assets/a.glb'), [1]);
      await first.settle();

      version = 2;
      final second = cache();
      // The stored copy serves at once; the revalidation stores version 2.
      expect(await second.load('/assets/a.glb'), [1]);
      await second.settle();

      expect(await cache().load('/assets/a.glb'), [2]);
    });

    test('오프라인이면 저장본으로 열린다', () async {
      final online = ModelBytesCache(
        baseUrl: Uri.parse('http://host/'),
        disk: ModelDiskCache(directory: () => dir),
        client: MockClient((_) async => http.Response.bytes([9], 200)),
      );
      await online.load('/assets/a.glb');
      await online.settle();

      final offline = ModelBytesCache(
        baseUrl: Uri.parse('http://host/'),
        disk: ModelDiskCache(directory: () => dir),
        client: MockClient((_) async => throw http.ClientException('offline')),
      );
      expect(await offline.load('/assets/a.glb'), [9]);
      await offline.settle();
    });

    test('실패한 응답은 저장하지 않는다', () async {
      final cache = ModelBytesCache(
        baseUrl: Uri.parse('http://host/'),
        disk: ModelDiskCache(directory: () => dir),
        client: MockClient((_) async => http.Response('nope', 500)),
      );

      await expectLater(
        cache.load('/assets/a.glb'),
        throwsA(isA<http.ClientException>()),
      );
      await cache.settle();
      expect(await ModelDiskCache(directory: () => dir).read(url), isNull);
    });
  });
}
