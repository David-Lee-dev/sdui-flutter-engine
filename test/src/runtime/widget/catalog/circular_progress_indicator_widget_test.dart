import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/widget/catalog/primitive/circular_progress_indicator_widget.dart';
import 'package:sdui_engine/src/contract/error_observer.dart';
import 'package:sdui_engine/src/runtime/engine_errors.dart';

import '../../../../support/engine_harness.dart';

class _Errors implements SduiErrorObserver {
  final errors = <SduiError>[];
  @override
  void onError(SduiError error) => errors.add(error);
}

void main() {
  testWidgets('CAP-AC1', (tester) async {
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'stroke_cap': 'round',
      'value': 0.5,
    });
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      StrokeCap.round,
    );
  });
  testWidgets('resolves value and stroke width', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => CircularProgressIndicatorWidget.build(
            context,
            const {'value': 0.4, 'stroke_width': 6},
            const [],
          ),
        ),
      ),
    );
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.value, 0.4);
    expect(indicator.strokeWidth, 6);
  });
  testWidgets('CAP-AC2', (tester) async {
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'stroke_cap': 'butt',
      'value': 0.5,
    });
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      StrokeCap.butt,
    );
  });
  testWidgets('CAP-AC3', (tester) async {
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'stroke_cap': 'square',
    });
    final indicator = tester.widget<CircularProgressIndicator>(
      find.byType(CircularProgressIndicator),
    );
    expect(indicator.strokeCap, StrokeCap.square);
    expect(indicator.value, isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });
  testWidgets('CAP-AC4', (tester) async {
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'stroke_cap': r'${cap}',
      'value': 0.5,
      '_scope': {
        '_state': {'cap': 'round'},
        '_action': {
          'flip': {'_type': 'set', 'cap': 'butt'},
        },
      },
      '_on': {'tap': 'flip'},
    });
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      StrokeCap.round,
    );
    await tester.tap(find.byType(CircularProgressIndicator));
    await tester.pump();
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      StrokeCap.butt,
    );
  });
  testWidgets('CAP-AC5', (tester) async {
    final errors = _Errors();
    EngineErrors.observer = errors;
    addTearDown(EngineErrors.reset);
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'stroke_cap': 'pill',
      'value': 0.5,
    });
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      isNull,
    );
    expect(errors.errors, isEmpty);
  });
  testWidgets('CAP-AC6', (tester) async {
    await pumpEngineTemplate(tester, {
      '_type': 'circular_progress_indicator',
      'value': 0.5,
    });
    expect(
      tester
          .widget<CircularProgressIndicator>(
            find.byType(CircularProgressIndicator),
          )
          .strokeCap,
      isNull,
    );
  });
}
