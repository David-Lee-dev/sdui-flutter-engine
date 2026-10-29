import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

import 'support/engine_harness.dart';

/// The tuk bottom nav "option C", written purely as a template: a dark glass
/// capsule bar, a center circle that liquid-merges with the bar and lifts to
/// float 12px above it, a glass lens that springs between tabs, and haptics
/// on tap.
Map<String, Object?> optionC() {
  Map<String, Object?> tab(int i) => {
    '_type': 'expanded',
    '_child': {
      '_type': 'sizedbox',
      'height': 64,
      '_on': {
        'tap': {'do': 'pick', 'event': i},
      },
      '_child': {
        '_type': 'center',
        '_child': {
          '_type': 'build_probe',
          'id': 'icon$i',
          'active': '\${tab == $i}',
        },
      },
    },
  };

  return {
    '_type': 'sizedbox',
    '_requires': ['spring_v1', 'shape_v1', 'math_v1', 'align_xy_v1'],
    'width': 360,
    'height': 120,
    '_scope': {
      '_state': {'tab': 0, 'lifted': false},
      '_action': {
        'pick': [
          [
            {'_type': 'set', 'tab': r'${event}'},
            {'_type': 'sys_haptic', 'variant': 'selection'},
          ],
        ],
        'lift': [
          [
            {'_type': 'set', 'lifted': r'${not lifted}'},
            {'_type': 'sys_haptic', 'variant': 'light'},
          ],
        ],
      },
    },
    '_child': {
      '_type': 'stack',
      '_morph': {
        '_to': r'${lifted ? 1 : 0}',
        '_as': 'lift',
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
                'height': 64,
              },
              {
                'kind': 'circle',
                'align': [0, -1],
                'radius': 28,
                'offset': r'${[0, lerp(28, -12, lift)]}',
              },
            ],
            'smooth': r'${lerp(20, 0, lift)}',
            'fill': '#E61C1C1E',
            'rim': {'color': '#33FFFFFF', 'width': 1},
          },
        },
        {
          '_type': 'positioned',
          'left': 0,
          'right': 0,
          'bottom': 0,
          'height': 64,
          '_child': {
            '_type': 'align',
            '_morph': {
              '_to': r'${tab}',
              '_as': 'lens',
              '_spring': 'spatial_default',
            },
            'alignment': r'${[remap(lens, 0, 3, -0.9, 0.9), 0]}',
            '_child': {
              '_type': 'sizedbox',
              'width': 72,
              'height': 52,
              '_child': {
                '_type': 'stack',
                '_children': [
                  {
                    '_type': 'positioned_fill',
                    '_child': {
                      '_type': 'shape',
                      'shapes': [
                        {'kind': 'capsule'},
                      ],
                      'fill': '#14FFFFFF',
                      'rim': {'color': '#40FFFFFF', 'width': 1},
                    },
                  },
                  {
                    '_type': 'offstage',
                    '_child': {'_type': 'text', 'value': r'lens=${lens}'},
                  },
                ],
              },
            },
          },
        },
        {
          '_type': 'positioned',
          'left': 0,
          'right': 0,
          'bottom': 0,
          'height': 64,
          '_child': {
            '_type': 'row',
            '_children': [tab(0), tab(1), tab(2), tab(3)],
          },
        },
        {
          '_type': 'positioned',
          'left': 152,
          'top': 0,
          'width': 56,
          'height': 56,
          '_child': {
            '_type': 'sizedbox',
            '_on': {'tap': 'lift'},
            '_child': {
              '_type': 'text',
              'value': r'${lift}',
              'style': {'color': '#00000000'},
            },
          },
        },
      ],
    },
  };
}

void main() {
  final builds = <String, int>{};
  final haptics = <Object?>[];

  setUp(() {
    builds.clear();
    haptics.clear();
    WidgetFactory.register(
      'build_probe',
      EagerSpec((context, props, children) {
        final id = '${props['id']}';
        builds[id] = (builds[id] ?? 0) + 1;
        return SizedBox(
          key: ValueKey(id),
          width: 24,
          height: 24,
          child: ColoredBox(
            color: props['active'] == true
                ? const Color(0xFFFFFFFF)
                : const Color(0x66FFFFFF),
          ),
        );
      }),
    );
  });
  tearDown(WidgetFactory.reset);

  void mockHaptics(WidgetTester tester) {
    final messenger = tester.binding.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'HapticFeedback.vibrate') haptics.add(call.arguments);
      return null;
    });
    messenger.setMockMethodCallHandler(
      const MethodChannel('sdui_engine/haptic'),
      (call) async => false,
    );
    addTearDown(() {
      messenger.setMockMethodCallHandler(SystemChannels.platform, null);
      messenger.setMockMethodCallHandler(
        const MethodChannel('sdui_engine/haptic'),
        null,
      );
    });
  }

  double lift(WidgetTester tester) => double.parse(
    tester
        .widget<Text>(
          find.byWidgetPredicate(
            (w) => w is Text && w.data != null && !w.data!.startsWith('lens'),
          ),
        )
        .data!,
  );

  double lens(WidgetTester tester) => double.parse(
    tester
        .widget<Text>(
          find.byWidgetPredicate(
            (w) => w is Text && (w.data ?? '').startsWith('lens='),
            skipOffstage: false,
          ),
        )
        .data!
        .substring(5),
  );

  group('option C nav bar composition', () {
    testWidgets('템플릿만으로 컴파일·마운트되고 탭·리프트가 동작한다', (tester) async {
      mockHaptics(tester);
      await pumpEngineTemplate(tester, optionC());
      expect(tester.takeException(), isNull);
      expect(find.byKey(const ValueKey('icon0')), findsOneWidget);
      expect(lift(tester), 0);

      // Tab 3: lens springs over with overshoot, selection haptic plays.
      await tester.tap(find.byKey(const ValueKey('icon3')));
      await tester.pump();
      var peak = 0.0;
      for (var i = 0; i < 60; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        if (lens(tester) > peak) peak = lens(tester);
      }
      expect(peak, greaterThan(3));
      await tester.pumpAndSettle();
      expect(lens(tester), 3);
      expect(haptics, contains('HapticFeedbackType.selectionClick'));

      // Center circle lifts with a spring and settles at 1.
      await tester.tapAt(const Offset(180, 28));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 50));
      expect(lift(tester), inExclusiveRange(0, 1.2));
      await tester.pumpAndSettle();
      expect(lift(tester), 1);
      expect(haptics, contains('HapticFeedbackType.lightImpact'));
      expect(tester.takeException(), isNull);
    });

    testWidgets('lift 애니메이션 동안 탭 아이콘 행은 다시 빌드되지 않는다', (tester) async {
      mockHaptics(tester);
      await pumpEngineTemplate(tester, optionC());
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(180, 28));
      await tester.pump(); // state change + retarget frame
      final before = Map.of(builds);
      expect(before.keys, {'icon0', 'icon1', 'icon2', 'icon3'});
      final values = <double>{};
      for (var i = 0; i < 40; i++) {
        await tester.pump(const Duration(milliseconds: 16));
        values.add(lift(tester));
      }
      expect(values.length, greaterThan(10)); // lift really animated
      expect(builds, before);
      await tester.pumpAndSettle();
      expect(builds, before);
    });
  });
}
