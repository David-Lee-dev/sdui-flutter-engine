import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';
import 'package:sdui_engine/src/runtime/media/shader_registry.dart';

import 'support/engine_harness.dart';

/// A meniscus bottom nav written purely as a template: a blurred glass
/// capsule whose top edge dips under the active tab (a smooth subtract that
/// follows a spring morph and widens with its velocity), a bead circle
/// placed with `at`, gradient fill, shadow, per-tab proximity via
/// `smoothstep`, semantics on every tab, and a `pressed_as` pop.
Map<String, Object?> meniscus() {
  const center = r'(pos + 0.5) / 5';
  Map<String, Object?> tab(int i) => {
    '_type': 'expanded',
    '_child': {
      '_type': 'semantics',
      'label': 'Tab $i',
      'button': true,
      'selected': '\${tab == $i}',
      '_child': {
        '_type': 'sizedbox',
        'height': 72,
        '_on': {
          'tap': {'do': 'pick', 'event': i, 'pressed_as': 'down'},
        },
        '_child': {
          '_type': 'center',
          '_child': {
            '_type': 'transform',
            'scale': r'${down ? 0.86 : 1}',
            '_child': {
              '_type': 'opacity',
              'opacity':
                  '\${0.4 + 0.6 * (1 - smoothstep(0, 1, abs(pos - $i)))}',
              '_child': {
                '_type': 'sizedbox',
                'width': 24,
                'height': 24,
                '_child': {'_type': 'text', 'value': '\${down ? "D" : ""}$i'},
              },
            },
          },
        },
      },
    },
  };

  return {
    '_type': 'sizedbox',
    '_requires': [
      'spring_v1',
      'spring_v2',
      'shape_v1',
      'shape_v2',
      'math_v1',
      'math_v2',
      'press_v1',
      'semantics_v1',
    ],
    'width': 360,
    'height': 120,
    '_scope': {
      '_state': {'tab': 0},
      '_action': {
        'pick': {'_type': 'set', 'tab': r'${event}'},
      },
    },
    '_child': {
      '_type': 'stack',
      '_morph': {
        '_to': r'${tab}',
        '_as': 'pos',
        '_velocity': 'vel',
        '_spring': 'spatial_default',
      },
      '_children': [
        {
          '_type': 'positioned_fill',
          '_child': {
            '_type': 'shape',
            'shapes': [
              {
                'kind': 'capsule',
                'align': 'bottom_center',
                'width': 360,
                'height': 72,
              },
              {
                'kind': 'circle',
                'op': 'subtract',
                'at': '\${[$center, 0.32]}',
                'radius': r'${30 + clamp(abs(vel) * 2, 0, 8)}',
                'smooth': 12,
              },
            ],
            'fill': {
              'colors': ['#2EFFFFFF', '#14FFFFFF'],
              'begin': 'top_center',
              'end': 'bottom_center',
            },
            'rim': {'color': '#40FFFFFF', 'width': 1},
            'shadow': {
              'color': '#33000000',
              'blur': 12,
              'offset': [0, 4],
            },
            'backdrop': {'blur': 16},
          },
        },
        {
          '_type': 'positioned_fill',
          '_child': {
            '_type': 'shape',
            'shapes': [
              {'kind': 'circle', 'at': '\${[$center, 0.3]}', 'radius': 22},
            ],
            'fill': {
              'type': 'radial',
              'colors': ['#FFFFFFFF', '#FF8AB4F8'],
            },
          },
        },
        {
          '_type': 'positioned',
          'left': 0,
          'right': 0,
          'bottom': 0,
          'height': 72,
          '_child': {
            '_type': 'row',
            '_children': [for (var i = 0; i < 5; i++) tab(i)],
          },
        },
        {
          '_type': 'offstage',
          '_child': {
            '_type': 'text',
            'value': r'${abs(vel) > 0.01 ? "moving" : "rest"}',
          },
        },
      ],
    },
  };
}

void main() {
  late List<SduiError> errors;

  setUp(() {
    ShaderRegistry.reset();
    errors = [];
    EngineErrors.observer = _Capture(errors);
  });
  tearDown(() {
    EngineErrors.reset();
    ShaderRegistry.reset();
  });

  for (final shader in [false, true]) {
    testWidgets('meniscus nav가 컴파일·마운트되고 탭 전환에 맞춰 움직인다 '
        '(셰이더 ${shader ? '있음' : '없음'})', (tester) async {
      if (shader) {
        await tester.runAsync(ShaderRegistry.warmUp);
        expect(ShaderRegistry.available, isTrue);
      }
      final semantics = tester.ensureSemantics();
      await pumpEngineTemplate(tester, meniscus());
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(find.text('rest', skipOffstage: false), findsOneWidget);
      expect(tester.layers.whereType<BackdropFilterLayer>(), hasLength(1));
      // 유리의 하드 윤곽(backdrop clip): dip은 탭 0 위에 있다.
      Path glass() => tester.layers.whereType<ClipPathLayer>().single.clipPath!;
      expect(glass().contains(const Offset(36, 55)), isFalse);
      expect(glass().contains(const Offset(252, 55)), isTrue);
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Tab 0'))),
        matchesSemantics(
          label: 'Tab 0',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );

      // 누르는 동안 pressed_as로 탭 아이콘이 작아진다.
      final target = find.text('3');
      final gesture = await tester.startGesture(tester.getCenter(target));
      await tester.pump();
      expect(find.text('D3'), findsOneWidget);
      final pressed = tester.widget<Transform>(
        find.ancestor(of: find.text('D3'), matching: find.byType(Transform)),
      );
      expect(pressed.transform.storage[0], closeTo(0.86, 1e-6));
      await gesture.up();
      await tester.pump();

      // 스프링이 움직이는 동안 _velocity가 0이 아니다.
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('moving', skipOffstage: false), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('rest', skipOffstage: false), findsOneWidget);
      // dip이 탭 3 위로 옮겨 갔다.
      expect(glass().contains(const Offset(36, 55)), isTrue);
      expect(glass().contains(const Offset(252, 55)), isFalse);
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Tab 3'))),
        matchesSemantics(
          label: 'Tab 3',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel(RegExp('^Tab 0'))),
        matchesSemantics(
          label: 'Tab 0',
          isButton: true,
          hasSelectedState: true,
        ),
      );
      // 근접도: 활성 탭은 불투명, 먼 탭은 0.4.
      Opacity opacityOf(String label) => tester.widget<Opacity>(
        find
            .ancestor(of: find.text(label), matching: find.byType(Opacity))
            .first,
      );
      expect(opacityOf('3').opacity, closeTo(1, 1e-6));
      expect(opacityOf('0').opacity, closeTo(0.4, 1e-6));

      expect(tester.takeException(), isNull);
      expect(errors, isEmpty);
      semantics.dispose();
    });
  }
}

final class _Capture extends SduiErrorObserver {
  _Capture(this.sink);

  final List<SduiError> sink;

  @override
  void onError(SduiError error) => sink.add(error);
}
