import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_frame.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

Future<void> _pumpFrame(
  WidgetTester tester, {
  ModalVariant variant = ModalVariant.bottomSheet,
  Object? background,
  ThemeData? theme,
}) => tester.pumpWidget(
  MaterialApp(
    theme: theme,
    home: ModalFrame(
      content: const {'_type': 'text', 'value': 'body'},
      variant: variant,
      background: background,
      controller: ModalCloseController(),
      onClosed: (_, __) {},
    ),
  ),
);

Material _bodyMaterial(WidgetTester tester) => tester.widget<Material>(
  find
      .ancestor(of: find.text('body'), matching: find.byType(Material))
      .first,
);

void main() {
  WidgetFactory.ensureRegistered();
  DriverRegistry.ensureRegistered();
  // Bare frame mounts (no runner above) need the subtree seam installed.
  EngineSubtree.builder ??= (request) => EngineRunner(
    template: request.template,
    rootData: request.rootData,
    host: request.host,
  );

  group('ModalFrame', () {
    group('background', () {
      testWidgets('기본값은 테마 surface 색의 불투명 배경이다', (tester) async {
        final theme = ThemeData(
          colorScheme: const ColorScheme.light(surface: Color(0xFFABCDEF)),
        );
        await _pumpFrame(tester, theme: theme);

        final material = _bodyMaterial(tester);
        expect(material.color, const Color(0xFFABCDEF));
        expect(material.type, MaterialType.canvas);
      });

      testWidgets('시트는 위쪽만, 다이얼로그는 네 모서리 전부 둥글다', (tester) async {
        await _pumpFrame(tester);
        expect(
          _bodyMaterial(tester).borderRadius,
          const BorderRadius.vertical(top: Radius.circular(16)),
        );

        await _pumpFrame(tester, variant: ModalVariant.dialog);
        expect(
          _bodyMaterial(tester).borderRadius,
          const BorderRadius.all(Radius.circular(16)),
        );
      });

      testWidgets("background: 'none' 은 투명 바디를 유지한다", (tester) async {
        await _pumpFrame(tester, background: 'none');
        expect(_bodyMaterial(tester).type, MaterialType.transparency);
        expect(_bodyMaterial(tester).color, isNull);
      });

      testWidgets('색 문자열은 그대로 배경이 된다', (tester) async {
        await _pumpFrame(tester, background: '#112233');
        expect(_bodyMaterial(tester).color, const Color(0xFF112233));
      });
    });
  });
}
