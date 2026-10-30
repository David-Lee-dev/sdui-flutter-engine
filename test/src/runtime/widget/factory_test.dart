import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

/// [context]를 캡처해 돌려주는 최소 위젯 — WidgetFactory.build의 context 인자 검증용.
Future<BuildContext> _capture(WidgetTester tester) async {
  late BuildContext captured;
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: Builder(
        builder: (context) {
          captured = context;
          return const SizedBox();
        },
      ),
    ),
  );
  return captured;
}

void main() {
  group('WidgetFactory', () {
    // 전역 static 레지스트리라 케이스 간 누수를 막는다.
    tearDown(WidgetFactory.reset);

    group('build', () {
      testWidgets('빌트인 타입을 짓는다', (tester) async {
        final ctx = await _capture(tester);
        expect(
          WidgetFactory.build(ctx, 'text', {'value': 'hi'}, const []),
          isA<Text>(),
        );
        expect(
          WidgetFactory.build(ctx, 'container', const {}, const []),
          isA<Container>(),
        );
        expect(
          WidgetFactory.build(ctx, 'column', const {}, const []),
          isA<Column>(),
        );
      });

      testWidgets('등록되지 않은 타입은 StateError', (tester) async {
        final ctx = await _capture(tester);
        expect(
          () => WidgetFactory.build(ctx, 'nope', const {}, const []),
          throwsStateError,
        );
      });

      testWidgets('빌트인은 틀린 prop 타입에 관대하다 — throw 없이 값 없음으로 강등', (tester) async {
        final ctx = await _capture(tester);
        // 서버 데이터 문제는 엔진 버그가 아니다 — 변환기가 null로 강등해야 하고,
        // `as` 캐스트의 TypeError는 NodeGuard 정책 밖이라 금지 패턴이다.
        expect(
          () => WidgetFactory.build(ctx, 'text', {
            'value': 'hi',
            'size': 'big',
            'color': 42,
          }, const []),
          returnsNormally,
        );
        expect(
          () => WidgetFactory.build(ctx, 'container', {
            'width': 'wide',
            'height': true,
            'padding': const [],
            'color': 1,
          }, const []),
          returnsNormally,
        );
      });
    });

    group('register', () {
      testWidgets('등록한 타입을 짓는다(빌트인 위에 얹음)', (tester) async {
        final ctx = await _capture(tester);
        WidgetFactory.register(
          'x_custom',
          EagerSpec((context, props, children) => const SizedBox.shrink()),
        );
        expect(
          WidgetFactory.build(ctx, 'x_custom', const {}, const []),
          isA<SizedBox>(),
        );
        // 빌트인은 그대로 산다.
        expect(
          WidgetFactory.build(ctx, 'text', {'value': 'x'}, const []),
          isA<Text>(),
        );
      });

      testWidgets('registerAll로 여러 개를 한 번에', (tester) async {
        final ctx = await _capture(tester);
        WidgetFactory.registerAll({
          'a': EagerSpec((context, props, children) => const SizedBox.shrink()),
          'b': EagerSpec((context, props, children) => const Placeholder()),
        });
        expect(
          WidgetFactory.build(ctx, 'a', const {}, const []),
          isA<SizedBox>(),
        );
        expect(
          WidgetFactory.build(ctx, 'b', const {}, const []),
          isA<Placeholder>(),
        );
      });
    });

    group('reset', () {
      testWidgets('등록 세트를 빌트인만으로 되돌린다', (tester) async {
        final ctx = await _capture(tester);
        WidgetFactory.register(
          'x_custom',
          EagerSpec((context, props, children) => const SizedBox.shrink()),
        );
        WidgetFactory.reset();
        expect(
          () => WidgetFactory.build(ctx, 'x_custom', const {}, const []),
          throwsStateError,
        );
        // 빌트인은 reset 뒤에도 산다.
        expect(
          WidgetFactory.build(ctx, 'text', {'value': 'x'}, const []),
          isA<Text>(),
        );
      });
    });
  });
}
