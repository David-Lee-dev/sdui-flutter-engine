import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_frame.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

const _body = {
  '_type': 'sizedbox',
  'height': 120,
  '_child': {'_type': 'text', 'value': 'body'},
};

Future<void> _pumpFrame(
  WidgetTester tester, {
  Object content = _body,
  ModalVariant variant = ModalVariant.bottomSheet,
  EdgeInsets padding = const EdgeInsets.only(top: 24, bottom: 34),
  double keyboard = 0,
  String? align,
  Object? background,
}) async {
  tester.view.physicalSize = const Size(400, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 800),
          padding: padding,
          viewPadding: const EdgeInsets.only(top: 24, bottom: 34),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: ModalFrame(
          content: content,
          variant: variant,
          align: align,
          background: background,
          controller: ModalCloseController(),
          onClosed: (_, _) {},
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder get _surface =>
    find.ancestor(of: find.text('body'), matching: find.byType(Material)).first;

void main() {
  WidgetFactory.ensureRegistered();
  EngineSubtree.builder ??= (request) => EngineRunner(
    template: request.template,
    rootData: request.rootData,
    host: request.host,
  );

  testWidgets(
    'sheet surface reaches the bottom and lifts the body over the inset',
    (tester) async {
      await _pumpFrame(tester);

      expect(tester.getRect(_surface).bottom, 800);
      expect(tester.getSize(_surface).height, 154);
      expect(tester.getRect(find.text('body')).bottom, lessThanOrEqualTo(766));
    },
  );

  testWidgets('sheet consumes the bottom padding before the template', (
    tester,
  ) async {
    await _pumpFrame(tester);

    expect(MediaQuery.paddingOf(tester.element(find.text('body'))).bottom, 0);
  });

  testWidgets(
    'template safe_area inside the sheet does not add the inset again',
    (tester) async {
      await _pumpFrame(
        tester,
        content: const {'_type': 'safe_area', 'top': false, '_child': _body},
      );

      expect(tester.getRect(_surface).bottom, 800);
      expect(tester.getSize(_surface).height, 154);
    },
  );

  for (final insetEnd in <bool?>[null, true]) {
    testWidgets('sheet scroll adds no second inset with inset_end: $insetEnd', (
      tester,
    ) async {
      await _pumpFrame(
        tester,
        content: {
          '_type': 'sizedbox',
          'height': 200,
          '_child': {
            '_type': 'single_child_scroll_view',
            'inset_end': ?insetEnd,
            '_child': _body,
          },
        },
      );

      final scroll = find.byType(SingleChildScrollView);
      expect(tester.getRect(scroll).bottom, 766);
      expect(
        tester.widget<SingleChildScrollView>(scroll).padding,
        EdgeInsets.zero,
      );
    });
  }

  testWidgets('keyboard lifts the sheet without adding the home inset', (
    tester,
  ) async {
    await _pumpFrame(
      tester,
      keyboard: 300,
      padding: const EdgeInsets.only(top: 24),
      content: const {'_type': 'safe_area', 'top': false, '_child': _body},
    );

    expect(tester.getRect(_surface).bottom, 500);
    expect(tester.getSize(_surface).height, 120);
    expect(MediaQuery.paddingOf(tester.element(find.text('body'))).bottom, 0);
  });

  for (final align in ['top', 'bottom']) {
    testWidgets('dialog retains its $align safe area', (tester) async {
      await _pumpFrame(tester, variant: ModalVariant.dialog, align: align);

      final surface = tester.getRect(_surface);
      expect(
        align == 'top' ? surface.top : surface.bottom,
        align == 'top' ? 24 : 766,
      );
      expect(
        MediaQuery.paddingOf(tester.element(find.text('body'))),
        EdgeInsets.zero,
      );
    });
  }

  testWidgets('sheet keeps landscape left and right safe areas', (
    tester,
  ) async {
    await _pumpFrame(
      tester,
      padding: const EdgeInsets.fromLTRB(44, 0, 20, 34),
      content: const {
        '_type': 'sizedbox',
        'width': 400,
        'height': 120,
        '_child': {'_type': 'text', 'value': 'body'},
      },
    );

    final surface = tester.getRect(_surface);
    expect(surface.left, 44);
    expect(surface.right, 380);
    expect(surface.bottom, 800);
    expect(
      MediaQuery.paddingOf(tester.element(find.text('body'))),
      EdgeInsets.zero,
    );
  });

  testWidgets('transparent sheet leaves the bottom inset to the template', (
    tester,
  ) async {
    await _pumpFrame(tester, background: 'none');

    expect(tester.widget<Material>(_surface).type, MaterialType.transparency);
    expect(tester.getRect(_surface).bottom, 800);
    expect(tester.getSize(_surface).height, 120);
    expect(MediaQuery.paddingOf(tester.element(find.text('body'))).bottom, 34);
  });

  for (final keyboard in [0.0, 300.0]) {
    testWidgets('sheet height cap includes the inset with keyboard $keyboard', (
      tester,
    ) async {
      await _pumpFrame(
        tester,
        keyboard: keyboard,
        padding: EdgeInsets.only(bottom: keyboard == 0 ? 34 : 0),
        content: const {
          '_type': 'sizedbox',
          'height': 1000,
          '_child': {'_type': 'text', 'value': 'body'},
        },
      );

      expect(tester.getSize(_surface).height, (800 - keyboard) * 0.8);
      expect(tester.getRect(_surface).bottom, 800 - keyboard);
    });
  }
}
