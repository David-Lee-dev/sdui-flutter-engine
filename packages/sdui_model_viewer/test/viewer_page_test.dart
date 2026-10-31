import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sdui_model_viewer/src/model_bytes.dart';
import 'package:sdui_model_viewer/src/viewer_page.dart';

final class _Bundle extends CachingAssetBundle {
  _Bundle(this.assets);

  final Map<String, List<int>> assets;
  final loads = <String>[];

  @override
  Future<ByteData> load(String key) async {
    loads.add(key);
    final bytes = assets[key];
    if (bytes == null) throw StateError('missing asset $key');
    return ByteData.sublistView(Uint8List.fromList(bytes));
  }
}

void main() {
  group('ModelBytesCache', () {
    group('resolve', () {
      final cache = ModelBytesCache(
        baseUrl: Uri.parse('http://192.168.0.2:4103/'),
      );

      test('http(s) src는 그대로 쓴다', () {
        expect(
          cache.resolve('https://cdn.example.com/a.glb'),
          Uri.parse('https://cdn.example.com/a.glb'),
        );
      });

      test('/로 시작하는 src는 baseUrl 기준으로 푼다', () {
        expect(
          cache.resolve('/assets/a.glb'),
          Uri.parse('http://192.168.0.2:4103/assets/a.glb'),
        );
      });

      test('그 밖의 src는 번들 에셋이다', () {
        expect(cache.resolve('assets/models/a.glb'), isNull);
        expect(ModelBytesCache().resolve('/assets/a.glb'), isNull);
      });
    });

    group('load', () {
      test('같은 src는 한 번만 받는다', () async {
        var requests = 0;
        final cache = ModelBytesCache(
          baseUrl: Uri.parse('http://host/'),
          client: MockClient((_) async {
            requests++;
            return http.Response.bytes([1, 2, 3], 200);
          }),
        );

        expect(await cache.load('/a.glb'), [1, 2, 3]);
        expect(await cache.load('/a.glb'), [1, 2, 3]);
        expect(requests, 1);
      });

      test('실패한 로드는 캐시하지 않아 다음에 다시 받는다', () async {
        var requests = 0;
        final cache = ModelBytesCache(
          baseUrl: Uri.parse('http://host/'),
          client: MockClient((_) async {
            requests++;
            return requests == 1
                ? http.Response('nope', 500)
                : http.Response.bytes([7], 200);
          }),
        );

        await expectLater(
          cache.load('/a.glb'),
          throwsA(isA<http.ClientException>()),
        );
        expect(await cache.load('/a.glb'), [7]);
        expect(requests, 2);
      });

      test('maxEntries를 넘으면 가장 오래 안 쓴 것을 버린다', () async {
        final bundle = _Bundle({
          'a': [1],
          'b': [2],
          'c': [3],
        });
        final cache = ModelBytesCache(bundle: bundle, maxEntries: 2);

        await cache.load('a');
        await cache.load('b');
        await cache.load('a');
        await cache.load('c');
        await cache.load('a');
        await cache.load('b');

        expect(bundle.loads, ['a', 'b', 'c', 'b']);
      });
    });
  });

  group('ViewerPage', () {
    final bundle = _Bundle({
      ViewerPage.scriptAsset: utf8.encode('/* viewer */'),
      'assets/a.glb': [9, 9],
    });
    final page = ViewerPage(
      origin: Uri.parse('sdui-model://app/'),
      models: ModelBytesCache(bundle: bundle),
      bundle: bundle,
    );

    test('pageUrl은 src와 옵션을 쿼리로 싣는다', () {
      final url = page.pageUrl(
        src: '/assets/a b.glb',
        interactive: true,
        autoRotate: true,
      );

      expect(url.scheme, 'sdui-model');
      expect(url.path, '/index.html');
      expect(url.queryParameters, {
        'src': '/assets/a b.glb',
        'interactive': '1',
        'rotate': '1',
      });
    });

    test('페이지, 스크립트, 모델을 같은 origin에서 내려준다', () async {
      final html = await page.respond(Uri.parse('sdui-model://app/index.html'));
      final script = await page.respond(
        Uri.parse('sdui-model://app/model-viewer.js'),
      );
      final model = await page.respond(
        Uri.parse('sdui-model://app/model?src=assets%2Fa.glb'),
      );

      expect(html!.contentType, 'text/html');
      expect(utf8.decode(html.data), viewerHtml);
      expect(script!.contentType, 'application/javascript');
      expect(utf8.decode(script.data), '/* viewer */');
      expect(model!.contentType, 'model/gltf-binary');
      expect(model.data, [9, 9]);
    });

    test('다른 origin이나 모르는 경로, 실패한 모델에는 응답하지 않는다', () async {
      expect(await page.respond(Uri.parse('https://evil/index.html')), isNull);
      expect(await page.respond(Uri.parse('sdui-model://app/other')), isNull);
      expect(
        await page.respond(Uri.parse('sdui-model://app/model?src=missing')),
        isNull,
      );
    });
  });
}
