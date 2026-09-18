import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/compile/compiler/template_compiler.dart';
import 'package:sdui_engine/src/ir/model/interaction_events.dart';
import 'package:sdui_engine/src/compile/template_parser.dart';
import 'package:sdui_engine/src/runtime/wrapper/interaction.dart';
import 'package:sdui_engine/src/runtime/wrapper/scroll_event_wrapper.dart';

void main() {
  test('all은 gesture/input/scroll의 합집합이다', () {
    expect(InteractionEvents.all, {
      ...InteractionEvents.gesture,
      ...InteractionEvents.input,
      ...InteractionEvents.scroll,
    });
  });

  test('compiler와 wrapper가 이벤트 카탈로그를 그대로 사용한다', () {
    expect(InteractionWrapper.events, same(InteractionEvents.gesture));
    expect(ScrollEventWrapper.events, same(InteractionEvents.scroll));

    for (final event in InteractionEvents.all) {
      expect(
        () => TemplateCompiler.buildDirectiveTree(
          TemplateParser.buildUiTree({
            '_type': 'text',
            '_on': {event: 'x'},
          }),
        ),
        returnsNormally,
      );
    }
  });
}
