import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/util/engine_metrics.dart';
import 'package:sdui_engine/src/runtime/util/props_resolver.dart';
import 'package:sdui_engine/src/runtime/util/styled_border.dart';

/// [context]를 캡처해 돌려주는 최소 위젯 — resolver의 context 의존 메서드 검증용.
Future<BuildContext> _capture(
  WidgetTester tester, {
  Widget Function(Widget)? wrap,
}) async {
  late BuildContext captured;
  final probe = Builder(
    builder: (context) {
      captured = context;
      return const SizedBox();
    },
  );
  await tester.pumpWidget(
    Directionality(
      textDirection: TextDirection.ltr,
      child: wrap == null ? probe : wrap(probe),
    ),
  );
  return captured;
}

void main() {
  group('EngineMetrics', () {
    group('scale_for_width', () {
      test('기준폭 390dp(Figma 프레임 폭)에서 1.0', () {
        expect(EngineMetrics.scaleForWidth(390), 1.0);
      });

      test('큰 화면은 1.0 상한 — 업스케일하지 않는다', () {
        expect(EngineMetrics.scaleForWidth(720), 1.0);
      });

      test('좁은 화면은 선형 축소(370.5 → 0.95)', () {
        expect(EngineMetrics.scaleForWidth(370.5), closeTo(0.95, 1e-9));
      });

      // 360dp 는 국내 안드로이드의 최빈 폭이다. 기준폭이 시안보다 좁게 잡혀 있으면
      // 여기서 1.0 이 나와 모든 치수가 시안보다 크게 그려진다 — 화면에는 배율
      // 오차가 아니라 불필요한 개행·넘침으로 보인다.
      test('360dp는 축소된다 — 기준폭이 시안보다 좁으면 안 된다', () {
        expect(EngineMetrics.scaleForWidth(360), closeTo(360 / 390, 1e-9));
      });

      test('바닥 0.82로 클램프 — 더 좁아도 그 아래로 안 내려간다', () {
        expect(EngineMetrics.scaleForWidth(100), 0.82);
      });

      test('비정상 폭(0·음수·비유한)은 1.0', () {
        expect(EngineMetrics.scaleForWidth(0), 1.0);
        expect(EngineMetrics.scaleForWidth(-5), 1.0);
        expect(EngineMetrics.scaleForWidth(double.nan), 1.0);
      });
    });

    group('scale_of', () {
      testWidgets('미설치 문맥은 1.0으로 폴백', (tester) async {
        final ctx = await _capture(tester);
        expect(EngineMetrics.scaleOf(ctx), 1.0);
      });

      testWidgets('설치되면 그 scale을 읽는다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(EngineMetrics.scaleOf(ctx), 0.5);
      });
    });
  });

  group('PropsResolver', () {
    group('size', () {
      testWidgets('scale을 곱해 반환한다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(PropsResolver.size(ctx, 20), 10.0);
      });

      testWidgets('숫자 문자열도 해석한다', (tester) async {
        final ctx = await _capture(tester); // scale 1.0
        expect(PropsResolver.size(ctx, '20'), 20.0);
      });

      testWidgets('음수·비유한·비수치는 null(값 없음)', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.size(ctx, -4), isNull);
        expect(PropsResolver.size(ctx, double.infinity), isNull);
        expect(PropsResolver.size(ctx, 'nope'), isNull);
        expect(PropsResolver.size(ctx, null), isNull);
      });
    });

    group('offset', () {
      testWidgets('음수 부호를 보존해 스케일하고 size의 기존 음수 거부는 유지한다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(PropsResolver.offset(ctx, -8), -4);
        expect(PropsResolver.size(ctx, -8), isNull);
      });
    });

    group('number', () {
      test('음수 허용, 유한 double만', () {
        expect(PropsResolver.number(-4), -4.0);
        expect(PropsResolver.number('1.5'), 1.5);
        expect(PropsResolver.number(double.infinity), isNull);
        expect(PropsResolver.number('x'), isNull);
      });
    });

    group('ratio01', () {
      test('0..1로 클램프', () {
        expect(PropsResolver.ratio01(0.4), 0.4);
        expect(PropsResolver.ratio01(1.5), 1.0);
        expect(PropsResolver.ratio01(-1), 0.0);
        expect(PropsResolver.ratio01('x'), isNull);
      });
    });

    group('color', () {
      test('#RGB·#RRGGBB·#AARRGGBB를 Color로', () {
        expect(PropsResolver.color('#fff'), const Color(0xffffffff));
        expect(PropsResolver.color('#112233'), const Color(0xff112233));
        expect(PropsResolver.color('#80112233'), const Color(0x80112233));
      });

      test('ARGB32 int를 Color로(mix 표현식 산출 경로)', () {
        expect(PropsResolver.color(0xff112233), const Color(0xff112233));
        expect(PropsResolver.color(0x80112233), const Color(0x80112233));
      });

      test('비문자열·비색은 null', () {
        expect(PropsResolver.color('red'), isNull);
        expect(PropsResolver.color(null), isNull);
      });
    });

    group('alignment', () {
      test('이름을 Alignment로', () {
        expect(PropsResolver.alignment('center'), Alignment.center);
        expect(PropsResolver.alignment('top_left'), Alignment.topLeft);
        expect(PropsResolver.alignment('bottom_right'), Alignment.bottomRight);
      });

      test('미지·비문자열은 null', () {
        expect(PropsResolver.alignment('nope'), isNull);
        expect(PropsResolver.alignment(3), isNull);
      });
    });

    group('edge', () {
      testWidgets('num은 전체에, scale이 각 성분에 곱해진다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(PropsResolver.edge(ctx, 20), const EdgeInsets.all(10));
      });

      testWidgets('[h,v]는 대칭으로', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.edge(ctx, [10, 20]),
          const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
        );
      });

      testWidgets('[l,t,r,b]는 LTRB로', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.edge(ctx, [1, 2, 3, 4]),
          const EdgeInsets.fromLTRB(1, 2, 3, 4),
        );
      });

      testWidgets('그 외 꼴·비수치는 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.edge(ctx, [1, 2, 3]), isNull);
        expect(PropsResolver.edge(ctx, 'x'), isNull);
      });
    });

    group('radius', () {
      testWidgets('num은 원형, scale이 곱해진다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(PropsResolver.radius(ctx, 20), BorderRadius.circular(10));
      });

      testWidgets('[tl,tr,br,bl]는 코너별로', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.radius(ctx, [1, 2, 3, 4]),
          const BorderRadius.only(
            topLeft: Radius.circular(1),
            topRight: Radius.circular(2),
            bottomRight: Radius.circular(3),
            bottomLeft: Radius.circular(4),
          ),
        );
      });

      testWidgets('그 외 꼴은 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.radius(ctx, [1, 2]), isNull);
        expect(PropsResolver.radius(ctx, 'x'), isNull);
      });
    });

    group('constraints', () {
      testWidgets('맵 성분을 읽고 빠진 건 Flutter 기본(0/무한)으로', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.constraints(ctx, {'min_width': 10, 'max_width': 100}),
          const BoxConstraints(
            minWidth: 10,
            maxWidth: 100,
            minHeight: 0,
            maxHeight: double.infinity,
          ),
        );
      });

      testWidgets('맵이 아니면 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.constraints(ctx, 5), isNull);
      });
    });

    group('border', () {
      testWidgets('{color,width}를 Border.all로, 빠진 건 BorderSide 기본으로', (
        tester,
      ) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.border(ctx, {'color': '#ff0000', 'width': 2}),
          Border.all(color: const Color(0xffff0000), width: 2),
        );
        expect(
          PropsResolver.border(ctx, const {}),
          Border.all(color: const Color(0xFF000000)),
        );
      });

      testWidgets('맵이 아니면 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.border(ctx, 'x'), isNull);
      });

      testWidgets('변별 맵은 지정한 변만 그린다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.border(ctx, {
          'bottom': {'color': '#000', 'width': 2},
        });
        expect(result, isA<Border>());
        if (result case final Border border) {
          expect(border.top, BorderSide.none);
          expect(border.left, BorderSide.none);
          expect(border.right, BorderSide.none);
          expect(
            border.bottom,
            const BorderSide(color: Color(0xff000000), width: 2),
          );
        }
      });

      testWidgets('gradient와 dashed/dotted는 StyledBoxBorder로 만든다', (
        tester,
      ) async {
        final ctx = await _capture(tester);
        final gradient = PropsResolver.border(ctx, const {
          'gradient': {
            'colors': ['#f00', '#00f'],
          },
        });
        final dashed = PropsResolver.border(ctx, const {'style': 'dashed'});
        final dotted = PropsResolver.border(ctx, const {'style': 'dotted'});

        expect(gradient, isA<StyledBoxBorder>());
        expect(dashed, isA<StyledBoxBorder>());
        expect(dotted, isA<StyledBoxBorder>());
      });
    });

    group('gradient', () {
      test('linear 기본형은 두 색을 해석한다', () {
        final result = PropsResolver.gradient({
          'colors': ['#f00', '#00f'],
        });
        expect(result, isA<LinearGradient>());
        expect(result?.colors, const [Color(0xffff0000), Color(0xff0000ff)]);
      });

      test('radial 타입을 만든다', () {
        final result = PropsResolver.gradient({
          'type': 'radial',
          'colors': ['#f00', '#00f'],
          'radius': 0.75,
        });
        expect(result, isA<RadialGradient>());
        if (result case final RadialGradient radial) {
          expect(radial.radius, 0.75);
        }
      });

      test('stops와 begin/end를 반영한다', () {
        final result = PropsResolver.gradient({
          'colors': ['#f00', '#00f'],
          'stops': [0.2, 0.8],
          'begin': 'top_left',
          'end': 'bottom_right',
        });
        expect(result, isA<LinearGradient>());
        if (result case final LinearGradient linear) {
          expect(linear.stops, [0.2, 0.8]);
          expect(linear.begin, Alignment.topLeft);
          expect(linear.end, Alignment.bottomRight);
        }
      });

      test('유효한 색이 둘 미만이거나 맵이 아니면 null', () {
        expect(
          PropsResolver.gradient({
            'colors': ['#f00', 'bad'],
          }),
          isNull,
        );
        expect(PropsResolver.gradient('bad'), isNull);
      });
    });

    group('box_shadow', () {
      testWidgets('맵 하나는 1-원소 리스트로, offset은 스케일된다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        final result = PropsResolver.boxShadow(ctx, {
          'color': '#000000',
          'blur_radius': 10,
          'spread_radius': 4,
          'offset': [4, 8],
        });
        expect(result, [
          const BoxShadow(
            color: Color(0xff000000),
            blurRadius: 5,
            spreadRadius: 2,
            offset: Offset(2, 4),
          ),
        ]);
      });

      testWidgets('음수 offset(위·왼쪽)은 부호를 보존하며 스케일된다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        final result = PropsResolver.boxShadow(ctx, {
          'offset': [-4, 8],
        });
        expect(result!.single.offset, const Offset(-2, 4));
      });

      testWidgets('맵 리스트는 여러 그림자로', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.boxShadow(ctx, [
          {'blur_radius': 1},
          {'blur_radius': 2},
        ]);
        expect(result, hasLength(2));
      });

      testWidgets('그 외 꼴은 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.boxShadow(ctx, 'x'), isNull);
      });
    });

    group('text_shadows', () {
      testWidgets('맵 하나를 Shadow로 만들고 각 치수를 스케일한다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        expect(
          PropsResolver.textShadows(ctx, {
            'color': '#000',
            'blur_radius': 2,
            'offset': [1, 1],
          }),
          const [
            Shadow(
              color: Color(0xff000000),
              blurRadius: 1,
              offset: Offset(0.5, 0.5),
            ),
          ],
        );
      });

      testWidgets('리스트의 맵만 해석하고 빈 결과·잘못된 값은 null', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.textShadows(ctx, [
            {'blur_radius': 1},
            'bad',
            {'blur_radius': 2},
          ]),
          hasLength(2),
        );
        expect(PropsResolver.textShadows(ctx, ['bad']), isNull);
        expect(PropsResolver.textShadows(ctx, 'bad'), isNull);
      });
    });

    group('box_decoration', () {
      testWidgets('맵 성분을 각 리졸버로 조립한다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.boxDecoration(ctx, {
          'color': '#fff',
          'border_radius': 8,
          'shape': 'circle',
        });
        expect(result?.color, const Color(0xffffffff));
        expect(result?.borderRadius, BorderRadius.circular(8));
        expect(result?.shape, BoxShape.circle);
      });

      testWidgets('맵이 아니면 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.boxDecoration(ctx, 5), isNull);
      });

      testWidgets('gradient가 있으면 color를 제외하고 blend mode를 읽는다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.boxDecoration(ctx, {
          'color': '#fff',
          'gradient': {
            'colors': ['#f00', '#00f'],
          },
          'background_blend_mode': 'multiply',
        });
        expect(result?.gradient, isA<LinearGradient>());
        expect(result?.color, isNull);
        expect(result?.backgroundBlendMode, BlendMode.multiply);
      });

      testWidgets('gradient가 없으면 기존 color 동작을 유지한다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.boxDecoration(ctx, {'color': '#fff'});
        expect(result?.color, const Color(0xffffffff));
        expect(result?.gradient, isNull);
      });
    });

    group('matrix4', () {
      test('비균일 scale로 X축을 뒤집는다', () {
        final result = PropsResolver.matrix4({
          'scale': [-1, 1],
        });
        expect(result?.entry(0, 0), -1);
        expect(result?.entry(1, 1), 1);
      });

      test('translate를 적용한다', () {
        final result = PropsResolver.matrix4({
          'translate': [10, 0],
        });
        expect(result?.entry(0, 3), 10);
        expect(result?.entry(1, 3), 0);
      });

      test('맵이 아니면 null', () {
        expect(PropsResolver.matrix4('bad'), isNull);
      });
    });

    group('text_style', () {
      testWidgets('fontSize·letterSpacing은 스케일, height는 배수라 그대로', (
        tester,
      ) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        final result = PropsResolver.textStyle(ctx, {
          'font_size': 20,
          'letter_spacing': 4,
          'height': 1.5,
          'color': '#fff',
          'font_weight': 'bold',
        });
        expect(result?.fontSize, 10);
        expect(result?.letterSpacing, 2);
        expect(result?.height, 1.5);
        expect(result?.color, const Color(0xffffffff));
        expect(result?.fontWeight, FontWeight.bold);
      });

      testWidgets('맵이 아니면 null', (tester) async {
        final ctx = await _capture(tester);
        expect(PropsResolver.textStyle(ctx, 5), isNull);
      });

      testWidgets('음수 letterSpacing은 부호를 보존해 스케일한다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.textStyle(ctx, const {
          'letter_spacing': -1.5,
        });

        expect(result?.letterSpacing, -1.5);
      });

      testWidgets('leading_distribution을 TextStyle에 반영한다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.textStyle(ctx, const {
          'leading_distribution': 'even',
        });

        expect(result?.leadingDistribution, TextLeadingDistribution.even);
      });

      testWidgets('leading_distribution이 없으면 null이다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.textStyle(ctx, const {});

        expect(result?.leadingDistribution, isNull);
      });

      testWidgets('장식·wordSpacing·배경·Shadow를 모두 반영한다', (tester) async {
        final ctx = await _capture(
          tester,
          wrap: (child) => EngineMetrics(scale: 0.5, child: child),
        );
        final result = PropsResolver.textStyle(ctx, {
          'decoration_color': '#f00',
          'decoration_style': 'wavy',
          'decoration_thickness': 2,
          'word_spacing': -4,
          'background_color': '#00f',
          'shadows': {
            'color': '#000',
            'blur_radius': 2,
            'offset': [2, 4],
          },
        });
        expect(result?.decorationColor, const Color(0xffff0000));
        expect(result?.decorationStyle, TextDecorationStyle.wavy);
        expect(result?.decorationThickness, 2);
        expect(result?.wordSpacing, -2);
        expect(result?.backgroundColor, const Color(0xff0000ff));
        expect(result?.shadows, const [
          Shadow(color: Color(0xff000000), blurRadius: 1, offset: Offset(1, 2)),
        ]);
      });

      testWidgets('새 속성이 없으면 모두 null로 남는다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.textStyle(ctx, const {});
        expect(result?.decorationColor, isNull);
        expect(result?.decorationStyle, isNull);
        expect(result?.decorationThickness, isNull);
        expect(result?.wordSpacing, isNull);
        expect(result?.backgroundColor, isNull);
        expect(result?.shadows, isNull);
      });
    });

    group('input_border', () {
      testWidgets('outline·underline·none을 각각 만든다', (tester) async {
        final ctx = await _capture(tester);
        final outline = PropsResolver.inputBorder(ctx, {
          'type': 'outline',
          'color': '#f00',
          'width': 2,
          'radius': 8,
        });
        expect(outline, isA<OutlineInputBorder>());
        expect(
          outline?.borderSide,
          const BorderSide(color: Color(0xffff0000), width: 2),
        );
        if (outline case final OutlineInputBorder border) {
          expect(border.borderRadius, BorderRadius.circular(8));
        }
        expect(
          PropsResolver.inputBorder(ctx, const {}),
          isA<UnderlineInputBorder>(),
        );
        expect(
          PropsResolver.inputBorder(ctx, {'type': 'none'}),
          InputBorder.none,
        );
        expect(PropsResolver.inputBorder(ctx, 'bad'), isNull);
      });
    });

    group('input_decoration', () {
      testWidgets('문구·채움·이름 아이콘을 조립한다', (tester) async {
        final ctx = await _capture(tester);
        final result = PropsResolver.inputDecoration(ctx, {
          'label_text': '이름',
          'hint_text': '입력',
          'filled': true,
          'prefix_icon': 'add',
        });
        expect(result?.labelText, '이름');
        expect(result?.hintText, '입력');
        expect(result?.filled, isTrue);
        expect(result?.prefixIcon, isA<Icon>());
        if (result?.prefixIcon case final Icon icon) {
          expect(icon.icon?.fontFamily, 'MaterialIcons');
        }
      });

      testWidgets('미지 아이콘과 비맵은 null로 강등한다', (tester) async {
        final ctx = await _capture(tester);
        expect(
          PropsResolver.inputDecoration(ctx, {
            'prefix_icon': 'not_an_icon',
          })?.prefixIcon,
          isNull,
        );
        expect(PropsResolver.inputDecoration(ctx, 'bad'), isNull);
      });
    });

    group('outlined_border', () {
      testWidgets('rounded·circle·stadium을 만든다', (tester) async {
        final ctx = await _capture(tester);
        final rounded = PropsResolver.outlinedBorder(ctx, {
          'radius': 8,
          'side': {'color': '#f00', 'width': 2},
        });
        expect(rounded, isA<RoundedRectangleBorder>());
        expect(
          rounded?.side,
          const BorderSide(color: Color(0xffff0000), width: 2),
        );
        expect(
          PropsResolver.outlinedBorder(ctx, {'type': 'circle'}),
          isA<CircleBorder>(),
        );
        expect(
          PropsResolver.outlinedBorder(ctx, {'type': 'stadium'}),
          isA<StadiumBorder>(),
        );
        expect(PropsResolver.outlinedBorder(ctx, 'bad'), isNull);
      });
    });

    group('integer', () {
      test('int·정수 표기 double·정수 문자열을 int로', () {
        expect(PropsResolver.integer(3), 3);
        expect(PropsResolver.integer(3.0), 3);
        expect(PropsResolver.integer('4'), 4);
        expect(PropsResolver.integer('x'), isNull);
        expect(PropsResolver.integer(null), isNull);
      });
    });

    group('flag', () {
      test('bool만 통과, 문자열 "true"는 값 없음', () {
        expect(PropsResolver.flag(true), true);
        expect(PropsResolver.flag('true'), isNull);
        expect(PropsResolver.flag(null), isNull);
      });
    });

    group('truthy', () {
      test('관대한 참 값을 판정한다', () {
        for (final value in <Object?>[true, 1, 'true', 'yes']) {
          expect(PropsResolver.truthy(value), isTrue, reason: '$value');
        }
      });

      test('그 밖의 값은 거짓으로 판정한다', () {
        for (final value in <Object?>[false, 0, '', 'false', null, 'nope']) {
          expect(PropsResolver.truthy(value), isFalse, reason: '$value');
        }
      });
    });

    group('text', () {
      test('String만 통과', () {
        expect(PropsResolver.text('hi'), 'hi');
        expect(PropsResolver.text(5), isNull);
      });
    });

    group('duration', () {
      test('비음수 ms를 Duration으로, 스케일 대상 아님', () {
        expect(PropsResolver.duration(500), const Duration(milliseconds: 500));
        expect(PropsResolver.duration(-1), isNull);
        expect(PropsResolver.duration('x'), isNull);
      });
    });

    group('enum_of', () {
      test('문자열 키를 테이블에서 찾는다, 미지·비문자열은 null', () {
        const table = {'a': 1};
        expect(PropsResolver.enumOf('a', table), 1);
        expect(PropsResolver.enumOf('b', table), isNull);
        expect(PropsResolver.enumOf(3, table), isNull);
      });
    });

    group('named enums', () {
      test('main_axis_alignment', () {
        expect(
          PropsResolver.mainAxisAlignment('space_between'),
          MainAxisAlignment.spaceBetween,
        );
        expect(PropsResolver.mainAxisAlignment('nope'), isNull);
      });

      test('cross_axis_alignment', () {
        expect(
          PropsResolver.crossAxisAlignment('stretch'),
          CrossAxisAlignment.stretch,
        );
      });

      test('main_axis_size', () {
        expect(PropsResolver.mainAxisSize('min'), MainAxisSize.min);
      });

      test('text_align', () {
        expect(PropsResolver.textAlign('justify'), TextAlign.justify);
      });

      test('text_overflow', () {
        expect(PropsResolver.textOverflow('ellipsis'), TextOverflow.ellipsis);
      });

      test('fontWeight — 이름과 100..900 숫자 둘 다', () {
        expect(PropsResolver.fontWeight('bold'), FontWeight.bold);
        expect(PropsResolver.fontWeight('w600'), FontWeight.w600);
        expect(PropsResolver.fontWeight(600), FontWeight.w600);
        expect(PropsResolver.fontWeight(650), isNull);
      });

      test('font_style', () {
        expect(PropsResolver.fontStyle('italic'), FontStyle.italic);
      });

      test('text_decoration_line', () {
        expect(
          PropsResolver.textDecorationLine('underline'),
          TextDecoration.underline,
        );
      });

      test('leading_distribution', () {
        expect(
          PropsResolver.leadingDistribution('even'),
          TextLeadingDistribution.even,
        );
        expect(
          PropsResolver.leadingDistribution('proportional'),
          TextLeadingDistribution.proportional,
        );
        expect(PropsResolver.leadingDistribution('unknown'), isNull);
        expect(PropsResolver.leadingDistribution(null), isNull);
      });

      test('새 enum decoder는 알려진 이름만 매핑한다', () {
        final cases = <(Object?, Object?, Object? Function(Object?))>[
          ('wavy', TextDecorationStyle.wavy, PropsResolver.textDecorationStyle),
          ('next', TextInputAction.next, PropsResolver.textInputAction),
          ('words', TextCapitalization.words, PropsResolver.textCapitalization),
          (
            'on_drag',
            ScrollViewKeyboardDismissBehavior.onDrag,
            PropsResolver.keyboardDismissBehavior,
          ),
          (
            'start_offset',
            TabAlignment.startOffset,
            PropsResolver.tabAlignment,
          ),
          (
            'label',
            TabBarIndicatorSize.label,
            PropsResolver.tabBarIndicatorSize,
          ),
          ('repeat_x', ImageRepeat.repeatX, PropsResolver.imageRepeat),
          ('high', FilterQuality.high, PropsResolver.filterQuality),
          (
            'mini_end_float',
            FloatingActionButtonLocation.miniEndFloat,
            PropsResolver.fabLocation,
          ),
        ];
        for (final (raw, expected, decode) in cases) {
          expect(decode(raw), same(expected), reason: '$raw');
          expect(decode('unknown'), isNull, reason: '$raw unknown');
          expect(decode(1), isNull, reason: '$raw non-string');
        }
      });

      test('box_fit', () {
        expect(PropsResolver.boxFit('cover'), BoxFit.cover);
      });

      test('axis', () {
        expect(PropsResolver.axis('vertical'), Axis.vertical);
      });

      test('vertical_direction', () {
        expect(PropsResolver.verticalDirection('up'), VerticalDirection.up);
      });

      test('text_direction', () {
        expect(PropsResolver.textDirection('rtl'), TextDirection.rtl);
      });

      test('text_baseline', () {
        expect(
          PropsResolver.textBaseline('ideographic'),
          TextBaseline.ideographic,
        );
      });

      test('wrap_alignment', () {
        expect(
          PropsResolver.wrapAlignment('space_evenly'),
          WrapAlignment.spaceEvenly,
        );
      });

      test('wrap_cross_alignment', () {
        expect(
          PropsResolver.wrapCrossAlignment('center'),
          WrapCrossAlignment.center,
        );
      });

      test('stack_fit', () {
        expect(PropsResolver.stackFit('expand'), StackFit.expand);
      });

      test('clip', () {
        expect(PropsResolver.clip('anti_alias'), Clip.antiAlias);
      });

      test('flex_fit', () {
        expect(PropsResolver.flexFit('tight'), FlexFit.tight);
      });

      test('box_shape', () {
        expect(PropsResolver.boxShape('circle'), BoxShape.circle);
      });

      test('blend_mode', () {
        expect(PropsResolver.blendMode('src_over'), BlendMode.srcOver);
        expect(PropsResolver.blendMode('nope'), isNull);
        expect(PropsResolver.blendMode(1), isNull);
      });

      test('decoration_position', () {
        expect(
          PropsResolver.decorationPosition('foreground'),
          DecorationPosition.foreground,
        );
        expect(PropsResolver.decorationPosition('nope'), isNull);
        expect(PropsResolver.decorationPosition(1), isNull);
      });
    });
  });
}
