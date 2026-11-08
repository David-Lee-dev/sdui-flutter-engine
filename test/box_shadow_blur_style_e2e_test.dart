import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/engine_harness.dart';

Map<String, Object?> _template(Map<String, Object?> decoration) => {
  '_type': 'column',
  '_scope': {
    '_state': {'style': 'inner'},
    '_action': {
      'flip': {'_type': 'set', 'style': 'outer'},
    },
  },
  '_children': [
    {
      '_type': 'decorated_box',
      'decoration': decoration,
      '_child': {
        '_type': 'container',
        'width': 40,
        'height': 40,
        '_on': {'tap': 'flip'},
      },
    },
  ],
};

BlurStyle? _blurStyle(WidgetTester tester) {
  final box = tester.widget<DecoratedBox>(
    find
        .ancestor(
          of: find.byType(Container),
          matching: find.byType(DecoratedBox),
        )
        .first,
  );
  return (box.decoration as BoxDecoration).boxShadow?.single.blurStyle;
}

void main() {
  testWidgets('바인딩된 blur_style 이 상태를 따라 BoxDecoration 에 실린다', (tester) async {
    await pumpEngineTemplate(
      tester,
      _template({
        'color': '#ffffff',
        'box_shadow': {'blur_radius': 6, 'blur_style': r'${style}'},
      }),
    );
    await tester.pump();
    expect(_blurStyle(tester), BlurStyle.inner);

    await tester.tap(find.byType(Container).first);
    await tester.pump();
    expect(_blurStyle(tester), BlurStyle.outer);
  });
}
