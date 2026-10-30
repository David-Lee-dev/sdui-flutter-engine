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

    test('모든 빌트인 타입의 skeleton form은 의도한 값이다 — 새 타입은 여기 추가해야 한다', () {
      // A built-in that loads or reports from its props while pending must
      // draw `box`; every other one renders for real under the bones.
      const forms = {
        'text': SkeletonForm.text,
        'icon': SkeletonForm.circle,
        'image': SkeletonForm.box,
        'video': SkeletonForm.box,
      };
      const real = {
        'anchor',
        'shared_element',
        'transition_source',
        'anchor_scope',
        'rich_text',
        'container',
        'column',
        'row',
        'sizedbox',
        'padding',
        'center',
        'align',
        'stack',
        'positioned',
        'expanded',
        'flexible',
        'absorb_pointer',
        'backdrop_filter',
        'badge',
        'color_filtered',
        'image_filtered',
        'opacity',
        'ignore_pointer',
        'physical_model',
        'tooltip',
        'unconstrained_box',
        'wrap',
        'spacer',
        'aspect_ratio',
        'clip_rrect',
        'clip_rect',
        'clip_oval',
        'decorated_box',
        'speech_balloon',
        'serpentine',
        'serpentine_row',
        'shape',
        'semantics',
        'spin_grid',
        'scratch_card',
        'chart',
        'skeleton',
        'rotated_box',
        'visibility',
        'positioned_fill',
        'interactive_viewer',
        'constrained_box',
        'fitted_box',
        'fractionally_sized_box',
        'intrinsic_height',
        'intrinsic_width',
        'limited_box',
        'offstage',
        'overflow_box',
        'sized_overflow_box',
        'transform',
        'baseline',
        'indexed_stack',
        'flex',
        'list_body',
        'overflow_bar',
        'safe_area',
        'shader_mask',
        'divider',
        'vertical_divider',
        'circular_progress_indicator',
        'linear_progress_indicator',
        'loading_indicator',
        'single_child_scroll_view',
        'auto_scroll',
        'list_view',
        'grid_view',
        'page_view',
        'scrollbar',
        'refresh_indicator',
        'dismissible',
        'custom_scroll_view',
        'sliver_to_box_adapter',
        'sliver_list',
        'sliver_grid',
        'sliver_padding',
        'sliver_fill_remaining',
        'sliver_persistent_header',
        'sliver_app_bar',
        'app_bar',
        'swipe_layout',
        'swipe_pane',
        'swipe_indicator',
        'default_tab_controller',
        'tab_bar',
        'tab',
        'tab_bar_view',
        'nested_scroll_view',
        'toggle',
        'cupertino_switch',
        'checkbox',
        'dropdown',
        'radio',
        'slider',
        'text_field',
        'scaffold',
        'list_tile',
        'collapsing_header',
        'layout_builder',
      };
      expect(
        {
          for (final type in WidgetFactory.types())
            type: WidgetFactory.specFor(type)!.skeleton,
        },
        {...forms, for (final type in real) type: SkeletonForm.real},
      );
    });

    test('form 없이 등록한 spec은 real이다', () {
      WidgetFactory.register(
        'custom_leaf',
        EagerSpec((_, _, _) => const SizedBox()),
      );
      expect(WidgetFactory.specFor('custom_leaf')!.skeleton, SkeletonForm.real);
    });
  });
}
