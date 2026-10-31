import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_model_support/sdui_model_support.dart';
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

    test('pageUrl은 src를 쿼리로 싣는다', () {
      final url = page.pageUrl(src: '/assets/a b.glb');

      expect(url.scheme, 'sdui-model');
      expect(url.path, '/index.html');
      expect(url.queryParameters, {'src': '/assets/a b.glb'});
    });

    test('페이지는 자체 카메라 조작 없이 sduiCamera로만 움직인다', () {
      expect(viewerHtml, isNot(contains('camera-controls')));
      expect(viewerHtml, isNot(contains('auto-rotate')));
      expect(viewerHtml, contains('window.sduiCamera'));
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
