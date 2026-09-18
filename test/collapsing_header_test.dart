import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';

import 'support/engine_harness.dart';

/// builder 위젯(§4) end-to-end — `collapsingHeader`가 델리게이트의 `shrinkOffset`/`progress`를 자식
/// scope에 주입하고, 자식이 `${progress}`로 바인딩해 스크롤에 반응한다. builder 계약(NodeBuilder의
/// on-demand 자식 build) + `_provides` validator 지원이 둘 다 있어야 통과한다.
void main() {
  group('collapsingHeader (builder 위젯 — shrinkOffset 주입)', () {
    const template = {
      '_type': 'custom_scroll_view',
      '_children': [
        {
          '_type': 'collapsing_header',
          'pinned': true,
          'max_extent': 200,
          'min_extent': 50,
          '_provides': ['shrink_offset', 'progress'],
          '_child': {'_type': 'text', 'value': r'p=${progress > 0.3}'},
        },
        {
          '_type': 'sliver_to_box_adapter',
          '_child': {'_type': 'sizedbox', 'height': 2000},
        },
      ],
    };

    testWidgets('스크롤로 접히면 자식이 shrinkOffset(progress)에 반응한다', (tester) async {
      await pumpEngineTemplate(tester, template);
      expect(find.text('p=false'), findsOneWidget); // 처음엔 안 접힘 → progress=0

      await tester.drag(find.byType(CustomScrollView), const Offset(0, -160));
      await tester.pumpAndSettle();

      expect(find.text('p=true'), findsOneWidget); // 접혀서 progress>0.3
      expect(find.text('p=false'), findsNothing);
    });

    testWidgets('_provides 없이 주입 변수를 바인딩하면 마운트-치명 (validator)', (tester) async {
      // shrinkOffset/progress는 collapsingHeader가 주입하지만, `_provides`로 선언 안 하면 자식의
      // ${progress}가 미선언 바인딩으로 걸린다(선언해야 validator가 자식 사슬에 더한다).
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EngineRunner(
              template: {
                '_type': 'custom_scroll_view',
                '_children': [
                  {
                    '_type': 'collapsing_header',
                    'max_extent': 100,
                    '_child': {'_type': 'text', 'value': r'${progress}'},
                  },
                ],
              },
            ),
          ),
        ),
      );
      expect(tester.takeException(), isA<InvalidTemplateException>());
    });
  });
}
