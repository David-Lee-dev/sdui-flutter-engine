import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/log/engine_log.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

/// Compiles [template] and validates it, as a mount does.
Directive _compile(Map<String, Object?> template) {
  final root = TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));
  TemplateValidator.validate(root, {});
  return root;
}

Widget _host(Widget child) => Directionality(
  textDirection: TextDirection.ltr,
  child: MediaQuery(
    data: const MediaQueryData(),
    child: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(width: 300, height: 400, child: child),
    ),
  ),
);

void main() {
  late List<String> lines;
  setUp(() {
    lines = [];
    EngineLog.configure(output: lines.add);
    WidgetFactory.register(
      'app_box',
      EagerSpec(
        (context, props, children) =>
            const SizedBox(width: 40, height: 20, child: Text('app')),
      ),
    );
  });
  tearDown(() {
    EngineLog.configure(output: debugPrint);
    WidgetFactory.reset();
  });

  Iterable<String> skeletonWarnings() =>
      lines.where((line) => line.contains('_skeleton'));

  group('skeleton 은 선언된 출력으로만 판정한다 (presence 정책과 무관)', () {
    testWidgets('container(_scope._skeleton) > box 앱 위젯은 bones 를 유지한다', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'container',
              '_scope': {
                '_skeleton': {'_type': 'text', 'value': 'bones'},
              },
              '_child': {'_type': 'app_box'},
            }),
          ),
        ),
      );

      expect(tester.widget<Scope>(find.byType(Scope)).skeleton, isNotNull);
      expect(skeletonWarnings(), isEmpty);
    });

    testWidgets('container(_skeleton) > box 앱 위젯은 load 동안 bones 를 보인다', (
      tester,
    ) async {
      final loading = ValueNotifier(true);
      addTearDown(loading.dispose);
      await tester.pumpWidget(
        _host(
          LoadingScope(
            loading: loading,
            child: NodeBuilder.build(
              _compile({
                '_type': 'container',
                '_skeleton': {'_type': 'text', 'value': 'bones'},
                '_child': {'_type': 'app_box'},
              }),
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('bones'), findsOneWidget);
      expect(skeletonWarnings(), isEmpty);
      loading.value = false;
      await tester.pumpAndSettle();
      expect(find.text('app'), findsOneWidget);
    });

    testWidgets('parent data 로 선언한 앱 위젯을 감싼 container 의 `_scope._skeleton` 은 '
        '경고와 함께 건너뛴다', (tester) async {
      WidgetFactory.register(
        'app_flex',
        EagerSpec(
          (context, props, children) => const Expanded(child: Text('app')),
          parentData: true,
        ),
      );
      final root = TemplateCompiler.buildRoot(
        TemplateParser.buildUiTree({
          '_type': 'column',
          '_children': [
            {
              '_type': 'container',
              '_scope': {
                '_skeleton': {'_type': 'text', 'value': 'bones'},
              },
              '_child': {'_type': 'app_flex'},
            },
          ],
        }),
      );
      await tester.pumpWidget(_host(NodeBuilder.build(root)));

      expect(tester.takeException(), isNull);
      expect(tester.widget<Scope>(find.byType(Scope)).skeleton, isNull);
      expect(skeletonWarnings(), isNotEmpty);
    });
  });
}
