import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/ir/expression.dart';
import 'package:sdui_engine/src/ir/model/directive/_base.dart';
import 'package:sdui_engine/src/ir/model/presence_config.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/scope.dart';
import 'package:sdui_engine/src/runtime/wrapper/scope/skeleton_scope.dart';

void main() {
  group('PresenceConfig default', () {
    test('is off; on and off name the two switches', () {
      expect(const PresenceConfig().enabled, isFalse);
      expect(PresenceConfig.off.enabled, isFalse);
      expect(PresenceConfig.on.enabled, isTrue);
      expect(PresenceConfig.on.space, isTrue);
      expect(PresenceConfig.on.sequential, isFalse);
      expect(PresenceConfig.on.durationMs, isNull);
      expect(PresenceConfig.on.curve, isNull);
    });

    test('directives built without a config are off', () {
      final body = TemplateCompiler.buildRoot(
        TemplateParser.buildUiTree({'_type': 'text', 'value': 'x'}),
      );
      final expression = Expression.compile('x');

      final presences = [
        ConditionDirective(branches: const [], path: 'p').presence,
        SwitchDirective(
          selector: expression,
          cases: const [],
          path: 'p',
        ).presence,
        LoopDirective(
          source: expression,
          as: 'it',
          index: 'i',
          keyExpression: expression,
          child: body,
          path: 'p',
        ).presence,
        ScopeDirective(
          config: const ScopeConfig(),
          child: body,
          path: 'p',
        ).presence,
        SkeletonDirective(bones: body, child: body, path: 'p').presence,
      ];

      for (final presence in presences) {
        expect(presence.enabled, isFalse);
      }
    });

    test('scope and skeleton widgets built without a config are off', () {
      const child = SizedBox();
      final presences = [
        const Scope(config: ScopeConfig(), child: child).presence,
        Scope.ofState(const {}, child: child).presence,
        SkeletonScope(
          loading: ValueNotifier(false),
          skeleton: child,
          child: child,
        ).presence,
        const SkeletonSlot(
          bones: child,
          boxed: true,
          path: 'p',
          child: child,
        ).presence,
      ];

      for (final presence in presences) {
        expect(presence.enabled, isFalse);
      }
    });
  });
}
