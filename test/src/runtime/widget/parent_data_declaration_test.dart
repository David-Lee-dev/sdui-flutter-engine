import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/compile/schema/builtin_language.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/compile/template_validator.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/layout_protocol.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/interpreter/building/node_builder.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';

/// An app widget whose own build returns parent data, out of the engine's sight.
class _OpaqueExpanded extends StatelessWidget {
  const _OpaqueExpanded();

  @override
  Widget build(BuildContext context) =>
      const Expanded(child: Text('app content'));
}

Directive _compile(Map<String, Object?> template) =>
    TemplateCompiler.buildRoot(TemplateParser.buildUiTree(template));

void _validate(Map<String, Object?> template) =>
    TemplateValidator.validate(_compile(template), {});

final _rejected = throwsA(isA<InvalidTemplateException>());

const _noopScope = {
  '_state': {'x': 0},
  '_action': {
    'noop': {'_type': 'set', 'x': 1},
  },
};

Map<String, Object?> _column(Map<String, Object?> child) => {
  '_type': 'column',
  '_scope': _noopScope,
  '_children': [child],
};

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

void _registerOpaque({required ParentDataKind parentData}) =>
    WidgetFactory.register(
      'opaque_expanded',
      EagerSpec(
        (context, props, children) => const _OpaqueExpanded(),
        parentData: parentData,
      ),
    );

void main() {
  tearDown(WidgetFactory.reset);

  test('내장 parent-data 위젯은 spec 과 compile schema 가 같이 선언한다', () {
    final declared = {
      for (final MapEntry(:key, :value) in BuiltinLanguage.widgets.entries)
        if (value.parentData != ParentDataKind.none) key: value.parentData,
    };

    expect(declared, {
      'expanded': ParentDataKind.flex,
      'flexible': ParentDataKind.flex,
      'positioned': ParentDataKind.stack,
      'positioned_fill': ParentDataKind.stack,
      'spacer': ParentDataKind.flex,
    });
    for (final type in BuiltinLanguage.widgets.keys) {
      expect(
        WidgetFactory.specFor(type)!.parentData,
        BuiltinLanguage.widgets[type]!.parentData,
        reason: type,
      );
    }
  });

  test('선언하지 않은 spec 은 parent data 가 아니다', () {
    WidgetFactory.register(
      'opaque_expanded',
      EagerSpec((context, props, children) => const _OpaqueExpanded()),
    );

    expect(
      WidgetFactory.specFor('opaque_expanded')!.parentData,
      ParentDataKind.none,
    );
    expect(
      WidgetFactory.schemaOf('opaque_expanded')!.parentData,
      ParentDataKind.none,
    );
  });

  group('parent data 로 선언한 앱 위젯', () {
    setUp(() => _registerOpaque(parentData: ParentDataKind.flex));

    final decorations = <String, Object?>{
      '_motion': {'type': 'fade'},
      '_on': {'tap': 'noop'},
    };
    for (final MapEntry(key: name, value: value) in decorations.entries) {
      test('$name 은 컴파일 오류', () {
        expect(
          () => _validate(_column({'_type': 'opaque_expanded', name: value})),
          _rejected,
        );
      });

      test('감싼 bare container 의 $name 도 컴파일 오류', () {
        expect(
          () => _validate(
            _column({
              '_type': 'container',
              name: value,
              '_child': {'_type': 'opaque_expanded'},
            }),
          ),
          _rejected,
        );
      });
    }

    test('`_skeleton` 은 컴파일 오류', () {
      expect(
        () => _validate(
          _column({
            '_type': 'opaque_expanded',
            '_skeleton': {'_type': 'sizedbox'},
          }),
        ),
        _rejected,
      );
    });

    testWidgets('lifecycle scope 아래에서 경계 없이 놓인다', (tester) async {
      await tester.pumpWidget(
        _host(
          NodeBuilder.build(
            _compile({
              '_type': 'column',
              '_children': [
                {
                  '_type': 'opaque_expanded',
                  '_scope': {
                    ..._noopScope,
                    '_lifecycle': [
                      {'on': 'mount', 'action': 'noop'},
                    ],
                  },
                },
              ],
            }),
          ),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Expanded)).height, 400);
    });

    testWidgets('`_if` 의 presence 에서 제자리에 놓인다', (tester) async {
      final key = GlobalKey<ScopeState>();
      await tester.pumpWidget(
        _host(
          Scope(
            key: key,
            config: const ScopeConfig(state: {'show': true}),
            child: NodeBuilder.build(
              _compile({
                '_type': 'column',
                '_children': [
                  {'_type': 'opaque_expanded', '_if': r'${show}'},
                ],
              }),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Expanded)).height, 400);

      key.currentState!.set('show', false);
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('app content'), findsNothing);
    });
  });

  group('scope 아래 container > expanded', () {
    Widget scoped() => _host(
      NodeBuilder.build(
        _compile({
          '_type': 'column',
          '_children': [
            {
              '_type': 'container',
              '_scope': {
                ..._noopScope,
                '_lifecycle': [
                  {'on': 'mount', 'action': 'noop'},
                ],
              },
              '_child': {
                '_type': 'expanded',
                '_child': {'_type': 'text', 'value': 'x'},
              },
            },
          ],
        }),
      ),
    );

    testWidgets('내장 container 는 expanded 를 넘기고 경계 없이 놓인다', (tester) async {
      await tester.pumpWidget(scoped());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(Expanded)).height, 400);
      expect(
        find.ancestor(
          of: find.byType(Expanded),
          matching: find.byType(RepaintBoundary),
        ),
        findsNothing,
      );
    });

    testWidgets('다시 등록한 container 는 보통 box 로 자기 경계를 갖는다', (tester) async {
      WidgetFactory.register(
        'container',
        EagerSpec((context, props, children) => Row(children: children)),
      );

      await tester.pumpWidget(scoped());
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(
        find.ancestor(
          of: find.byType(Row),
          matching: find.byType(RepaintBoundary),
        ),
        findsOneWidget,
      );
    });
  });

  group('maintain_* 없는 visibility 는 자식의 parent data 를 넘긴다', () {
    const text = {'_type': 'text', 'value': 'x'};
    final layouts = <String, (Map<String, Object?>, Map<String, Object?>)>{
      'row > visibility > expanded': (
        {'_type': 'row'},
        {'_type': 'expanded', '_child': text},
      ),
      'stack > visibility > positioned': (
        {'_type': 'stack', 'fit': 'expand'},
        {'_type': 'positioned', 'left': 0, 'top': 0, '_child': text},
      ),
      'row > visibility > expanded(_motion)': (
        {'_type': 'row'},
        {
          '_type': 'expanded',
          '_motion': {'type': 'fade'},
          '_child': text,
        },
      ),
    };

    for (final MapEntry(key: name, value: (parent, child)) in layouts.entries) {
      testWidgets('`_if` 의 presence 에서 $name 을 띄우고 내린다', (tester) async {
        final key = GlobalKey<ScopeState>();
        final root = _compile({
          ...parent,
          '_children': [
            {
              '_type': 'visibility',
              'visible': r'${shown}',
              '_if': r'${show}',
              '_child': child,
            },
          ],
        });
        TemplateValidator.validate(root, {'show', 'shown'});
        await tester.pumpWidget(
          _host(
            Scope(
              key: key,
              config: const ScopeConfig(state: {'show': true, 'shown': true}),
              child: NodeBuilder.build(root),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);
        expect(find.text('x'), findsOneWidget);

        key.currentState!.set('shown', false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('x'), findsNothing);

        key.currentState!.set('shown', true);
        await tester.pumpAndSettle();
        key.currentState!.set('show', false);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('x'), findsNothing);

        key.currentState!.set('show', true);
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        expect(find.text('x'), findsOneWidget);
      });
    }
  });

  test('선언하지 않은 앱 위젯의 `_motion` 은 그대로 허용', () {
    _registerOpaque(parentData: ParentDataKind.none);

    _validate(
      _column({
        '_type': 'opaque_expanded',
        '_motion': {'type': 'fade'},
      }),
    );
  });
}
