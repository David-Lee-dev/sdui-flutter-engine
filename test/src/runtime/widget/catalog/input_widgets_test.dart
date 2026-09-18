import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/checkbox_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/cupertino_switch_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/slider_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/text_field_widget.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/toggle_widget.dart';

typedef _BoundBuild =
    Widget Function(
      BuildContext,
      Map<String, Object?>,
      Object?,
      ValueChanged<Object?>?,
      ValueChanged<Object?>?,
    );

Future<void> _pumpBound(
  WidgetTester tester,
  _BoundBuild build, {
  Map<String, Object?> props = const {},
  Object? value,
  ValueChanged<Object?>? onChanged,
  ValueChanged<Object?>? onSubmit,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Builder(
        builder: (context) => build(context, props, value, onChanged, onSubmit),
      ),
    ),
  ),
);

/// Pumps a `text_field` inside a 44px-tall, vertically centered [Row] next to
/// a 20px [Icon] — the pill layout that exposed the `isDense` 48px floor bug.
Future<void> _pumpInCenteredRow(
  WidgetTester tester, {
  required Map<String, Object?> decoration,
}) => tester.pumpWidget(
  MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(
          height: 44,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.person, size: 20),
              Expanded(
                child: Builder(
                  builder: (context) => TextFieldWidget.build(
                    context,
                    {'decoration': decoration},
                    null,
                    null,
                    null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  ),
);

void main() {
  group('boolean inputs', () {
    for (final entry in <(String, _BoundBuild, Type)>[
      ('checkbox', CheckboxWidget.build, Checkbox),
      ('toggle', ToggleWidget.build, Switch),
    ]) {
      testWidgets('${entry.$1} — truthy 값을 체크 상태로 읽는다', (tester) async {
        for (final value in <Object>[1, 'true']) {
          await _pumpBound(tester, entry.$2, value: value, onChanged: (_) {});
          if (entry.$3 == Checkbox) {
            expect(
              tester.widget<Checkbox>(find.byType(Checkbox)).value,
              isTrue,
            );
          } else {
            expect(tester.widget<Switch>(find.byType(Switch)).value, isTrue);
          }
        }
      });

      testWidgets('${entry.$1} — enabled false면 변경 콜백이 없다', (tester) async {
        await _pumpBound(
          tester,
          entry.$2,
          props: const {'enabled': false},
          onChanged: (_) {},
        );
        if (entry.$3 == Checkbox) {
          expect(
            tester.widget<Checkbox>(find.byType(Checkbox)).onChanged,
            isNull,
          );
        } else {
          expect(tester.widget<Switch>(find.byType(Switch)).onChanged, isNull);
        }
      });
    }

    testWidgets('checkbox — checkColor와 shape를 전달한다', (tester) async {
      await _pumpBound(
        tester,
        CheckboxWidget.build,
        props: const {
          'check_color': '#ffffff',
          'shape': {'radius': 8},
        },
      );
      final checkbox = tester.widget<Checkbox>(find.byType(Checkbox));
      expect(checkbox.checkColor, const Color(0xffffffff));
      expect(checkbox.shape, isA<RoundedRectangleBorder>());
    });

    testWidgets('toggle — 트랙과 비활성 thumb 색을 전달한다', (tester) async {
      await _pumpBound(
        tester,
        ToggleWidget.build,
        props: const {
          'active_track_color': '#112233',
          'inactive_thumb_color': '#445566',
          'inactive_track_color': '#778899',
        },
      );
      final toggle = tester.widget<Switch>(find.byType(Switch));
      expect(toggle.activeTrackColor, const Color(0xff112233));
      expect(toggle.inactiveThumbColor, const Color(0xff445566));
      expect(toggle.inactiveTrackColor, const Color(0xff778899));
    });

    testWidgets('cupertino_switch — truthy 값을 체크 상태로 읽는다', (tester) async {
      for (final value in <Object>[1, 'true']) {
        await _pumpBound(
          tester,
          CupertinoSwitchWidget.build,
          value: value,
          onChanged: (_) {},
        );
        expect(
          tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
          isTrue,
        );
      }
    });

    testWidgets('cupertino_switch — enabled false면 변경 콜백이 없다', (tester) async {
      await _pumpBound(
        tester,
        CupertinoSwitchWidget.build,
        props: const {'enabled': false},
        onChanged: (_) {},
      );
      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).onChanged,
        isNull,
      );
    });

    testWidgets('cupertino_switch — 트랙과 thumb 색을 전달한다', (tester) async {
      await _pumpBound(
        tester,
        CupertinoSwitchWidget.build,
        props: const {
          'active_track_color': '#112233',
          'inactive_track_color': '#445566',
          'thumb_color': '#778899',
        },
      );
      final sw = tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch));
      expect(sw.activeTrackColor, const Color(0xff112233));
      expect(sw.inactiveTrackColor, const Color(0xff445566));
      expect(sw.thumbColor, const Color(0xff778899));
    });

    testWidgets('cupertino_switch — scale는 스위치를 크기 박스에 맞춘다', (tester) async {
      await _pumpBound(
        tester,
        CupertinoSwitchWidget.build,
        props: const {'scale': 0.5},
      );
      expect(find.byType(CupertinoSwitch), findsOneWidget);
      expect(find.byType(FittedBox), findsOneWidget);
      final box = tester.widget<SizedBox>(
        find
            .ancestor(
              of: find.byType(FittedBox),
              matching: find.byType(SizedBox),
            )
            .first,
      );
      expect(box.width, 51 * 0.5);
      expect(box.height, 31 * 0.5);
    });

    testWidgets('cupertino_switch — scale 없으면 그대로(FittedBox 없음)', (
      tester,
    ) async {
      await _pumpBound(tester, CupertinoSwitchWidget.build);
      expect(find.byType(CupertinoSwitch), findsOneWidget);
      expect(find.byType(FittedBox), findsNothing);
    });
  });

  group('text_field', () {
    testWidgets('number codec — 숫자·빈 값·입력 중간 문자열을 정규화한다', (tester) async {
      final committed = <Object?>[];
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'input_type': 'number'},
        onChanged: committed.add,
      );

      final onChanged = tester
          .widget<TextField>(find.byType(TextField))
          .onChanged!;
      onChanged('26');
      onChanged('');
      onChanged('12.');

      expect(committed, <Object?>[26, null, '12.']);
    });

    testWidgets('enabled false면 입력과 submit을 모두 막는다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'enabled': false},
        onChanged: (_) {},
        onSubmit: (_) {},
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.enabled, isFalse);
      expect(field.onChanged, isNull);
      expect(field.onSubmitted, isNull);
    });

    testWidgets('readOnly와 errorText를 Flutter 필드에 전달한다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'read_only': true, 'error_text': '잘못된 값'},
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.readOnly, isTrue);
      expect(field.decoration?.errorText, '잘못된 값');
    });

    testWidgets('number 입력은 키보드와 formatter를 설정한다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'input_type': 'number'},
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.number);
      expect(
        field.inputFormatters,
        contains(isA<FilteringTextInputFormatter>()),
      );
    });

    testWidgets('multiline 입력은 multiline 키보드와 열린 maxLines를 쓴다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'input_type': 'multiline'},
      );

      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.keyboardType, TextInputType.multiline);
      expect(field.maxLines, isNull);
    });

    testWidgets('decoration 맵과 top-level hintText를 병합한다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {
          'decoration': {'label_text': 'Name', 'filled': true},
          'hint_text': '이름 입력',
        },
      );
      final decoration = tester
          .widget<TextField>(find.byType(TextField))
          .decoration!;
      expect(decoration.labelText, 'Name');
      expect(decoration.filled, isTrue);
      expect(decoration.hintText, '이름 입력');
    });

    testWidgets('입력 동작·줄·정렬·autofocus prop을 전달한다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {
          'input_type': 'multiline',
          'max_length': 30,
          'text_input_action': 'next',
          'text_capitalization': 'words',
          'min_lines': 2,
          'text_align': 'center',
          'autofocus': true,
        },
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.maxLength, 30);
      expect(field.textInputAction, TextInputAction.next);
      expect(field.textCapitalization, TextCapitalization.words);
      expect(field.minLines, 2);
      expect(field.textAlign, TextAlign.center);
      expect(field.autofocus, isTrue);
    });

    testWidgets('style prop이 렌더링되는 텍스트 스타일에 반영된다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {
          'style': {'font_size': 20, 'color': '#112233'},
        },
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.style?.fontSize, 20);
      expect(field.style?.color, const Color(0xff112233));
    });

    testWidgets('decoration.is_dense가 TextField.decoration.isDense에 반영된다', (
      tester,
    ) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {
          'decoration': {'is_dense': true},
        },
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.decoration?.isDense, isTrue);
    });

    testWidgets('is_dense가 44px 행 안에서 EditableText를 세로 중앙에 맞춘다', (
      tester,
    ) async {
      await _pumpInCenteredRow(
        tester,
        decoration: const {
          'is_dense': true,
          'border': {'type': 'none'},
          'enabled_border': {'type': 'none'},
          'focused_border': {'type': 'none'},
          'content_padding': [0, 0],
        },
      );
      final rowCenter = tester.getRect(find.byType(Row)).center.dy;
      final editableCenter = tester
          .getRect(find.byType(EditableText))
          .center
          .dy;
      expect(editableCenter, closeTo(rowCenter, 0.5));
    });

    testWidgets('is_dense 없으면 48px 최소 높이 때문에 EditableText가 중앙을 벗어난다', (
      tester,
    ) async {
      await _pumpInCenteredRow(
        tester,
        decoration: const {
          'border': {'type': 'none'},
          'enabled_border': {'type': 'none'},
          'focused_border': {'type': 'none'},
          'content_padding': [0, 0],
        },
      );
      final rowCenter = tester.getRect(find.byType(Row)).center.dy;
      final editableCenter = tester
          .getRect(find.byType(EditableText))
          .center
          .dy;
      expect((editableCenter - rowCenter).abs(), greaterThan(1.0));
    });

    testWidgets('expands: true는 max_lines 기본값(1)일 때 무시되어 예외가 없다', (
      tester,
    ) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'expands': true},
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.expands, isFalse);
      expect(tester.takeException(), isNull);
    });

    testWidgets('expands: true는 multiline이고 max_lines/min_lines가 없으면 적용된다', (
      tester,
    ) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'input_type': 'multiline', 'expands': true},
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.expands, isTrue);
      expect(field.maxLines, isNull);
      expect(field.minLines, isNull);
      expect(tester.takeException(), isNull);
    });

    testWidgets(
      'expands: true는 obscure_text가 maxLines/minLines를 덮어써도 예외 없이 무시된다',
      (tester) async {
        await _pumpBound(
          tester,
          TextFieldWidget.build,
          props: const {
            'input_type': 'multiline',
            'obscure_text': true,
            'expands': true,
          },
        );
        final field = tester.widget<TextField>(find.byType(TextField));
        expect(field.expands, isFalse);
        expect(field.maxLines, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets('cursor_color와 cursor_radius가 TextField에 반영된다', (tester) async {
      await _pumpBound(
        tester,
        TextFieldWidget.build,
        props: const {'cursor_color': '#ff0000', 'cursor_radius': 4},
      );
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.cursorColor, const Color(0xffff0000));
      expect(field.cursorRadius, const Radius.circular(4));
    });
  });

  testWidgets('slider — enabled false면 변경 콜백이 없다', (tester) async {
    await _pumpBound(
      tester,
      SliderWidget.build,
      props: const {'enabled': false},
      onChanged: (_) {},
    );

    expect(tester.widget<Slider>(find.byType(Slider)).onChanged, isNull);
  });

  testWidgets('slider — 뒤집힌 min/max를 정렬하고 값을 범위 안으로 클램프한다', (tester) async {
    await _pumpBound(
      tester,
      SliderWidget.build,
      props: const {'min': 10, 'max': 5},
      value: 20,
    );

    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.min, lessThanOrEqualTo(slider.max));
    expect(slider.min, 5);
    expect(slider.max, 10);
    expect(slider.value, 10);
    expect(tester.takeException(), isNull);
  });

  testWidgets('slider — label과 비활성·thumb 색을 전달한다', (tester) async {
    await _pumpBound(
      tester,
      SliderWidget.build,
      props: const {
        'label': '50',
        'inactive_color': '#112233',
        'thumb_color': '#445566',
      },
    );
    final slider = tester.widget<Slider>(find.byType(Slider));
    expect(slider.label, '50');
    expect(slider.inactiveColor, const Color(0xff112233));
    expect(slider.thumbColor, const Color(0xff445566));
  });
}
