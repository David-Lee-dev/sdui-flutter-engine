import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_driver.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_frame.dart';
import 'package:sdui_engine/src/runtime/driver/driver_registry.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

EngineHost? _host;

/// Mounts a bare frame under a viewport whose keyboard inset is [keyboard].
Future<void> _pumpFrame(
  WidgetTester tester, {
  required double keyboard,
  ModalVariant variant = ModalVariant.bottomSheet,
  String? align,
}) => tester.pumpWidget(
  MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(
        size: const Size(400, 800),
        viewInsets: EdgeInsets.only(bottom: keyboard),
      ),
      child: ModalFrame(
        content: const {
          '_type': 'sizedbox',
          'height': 120,
          '_child': {'_type': 'text', 'value': 'sheet'},
        },
        variant: variant,
        align: align,
        controller: ModalCloseController(),
        onClosed: (_, _) {},
      ),
    ),
  ),
);

/// Mounts the app shell the modal driver inserts into.
Future<void> _pumpApp(WidgetTester tester, double keyboard) =>
    tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(
          size: const Size(400, 800),
          viewInsets: EdgeInsets.only(bottom: keyboard),
        ),
        child: const MaterialApp(home: Scaffold(body: SizedBox())),
      ),
    );

void _captureHost(WidgetTester tester) {
  final overlay = tester.firstState<OverlayState>(find.byType(Overlay));
  _host = EngineHost(
    modalTemplates: const {
      'sheet': {
        '_type': 'sizedbox',
        'height': 120,
        '_child': {'_type': 'text', 'value': '시트'},
      },
    },
    overlay: OverlayHandle(overlay),
  );
}

void main() {
  // Bare frame mounts (no runner above) need the subtree seam installed.
  EngineSubtree.builder ??= (request) => EngineRunner(
    template: request.template,
    rootData: request.rootData,
    host: request.host,
    screenId: request.screenId,
    screenViewId: request.screenViewId,
    surfaceType: request.surfaceType,
    modalId: request.modalId,
    resolveExitReason: request.resolveExitReason,
  );
  WidgetFactory.ensureRegistered();
  DriverRegistry.ensureRegistered();

  // 선언한 MediaQuery 와 실제 테스트 서피스를 맞춘다 — 기본 서피스는 800x600 이라
  // 절대 좌표로 검증하면 숫자가 어긋난다.
  setUp(() {
    final view =
        TestWidgetsFlutterBinding.instance.platformDispatcher.views.first;
    view.physicalSize = const Size(400, 800);
    view.devicePixelRatio = 1.0;
  });

  tearDown(() {
    TestWidgetsFlutterBinding.instance.platformDispatcher.views.first
      ..resetPhysicalSize()
      ..resetDevicePixelRatio();
    _host?.overlay?.dispose();
    _host = null;
  });

  group('ModalFrame', () {
    testWidgets('키패드가 올라오면 바텀시트가 그 위로 올라온다', (tester) async {
      await _pumpFrame(tester, keyboard: 0);
      await tester.pumpAndSettle();
      final resting = tester.getRect(find.text('sheet')).bottom;

      await _pumpFrame(tester, keyboard: 300);
      await tester.pumpAndSettle();
      final lifted = tester.getRect(find.text('sheet')).bottom;

      expect(resting - lifted, closeTo(300, 1));
    });

    testWidgets('다이얼로그도 키패드가 남긴 영역 안에서 가운데 정렬된다', (tester) async {
      await _pumpFrame(tester, keyboard: 0, variant: ModalVariant.dialog);
      await tester.pumpAndSettle();
      final resting = tester.getRect(find.text('sheet')).center.dy;

      await _pumpFrame(tester, keyboard: 300, variant: ModalVariant.dialog);
      await tester.pumpAndSettle();
      final lifted = tester.getRect(find.text('sheet')).center.dy;

      // 보이는 영역이 800 → 500 이 되므로 중심도 그 절반만큼 올라온다.
      expect(resting - lifted, closeTo(150, 1));
    });

    testWidgets('하단 정렬 다이얼로그는 키패드 바로 위에 선다', (tester) async {
      await _pumpFrame(
        tester,
        keyboard: 300,
        variant: ModalVariant.dialog,
        align: 'bottom',
      );
      await tester.pumpAndSettle();

      // 다이얼로그 상자(스크롤 뷰)의 아래 모서리가 보이는 영역의 바닥에 닿아야 한다.
      final box = tester.getRect(find.byType(SingleChildScrollView).last);
      expect(box.bottom, closeTo(500, 1));
    });

    // 프레임만이 아니라 실제 열림 경로(드라이버 → 오버레이 삽입)에서도 성립해야 한다 —
    // 오버레이가 어느 MediaQuery 아래 꽂히느냐에 따라 인셋이 0으로 보일 수 있다.
    testWidgets('열려 있는 시트가 키패드가 올라오면 그 위로 비켜난다', (tester) async {
      await _pumpApp(tester, 0);
      _captureHost(tester);

      const ModalDriver()
          .run(
            DriverContext(
              params: const {'modal': 'sheet', 'variant': 'bottom_sheet'},
              state: _NoState(),
              isCancelled: () => false,
              host: _host,
            ),
          )
          .ignore();
      await tester.pumpAndSettle();
      final resting = tester.getRect(find.text('시트')).bottom;

      // 입력창에 포커스가 가면 기기가 이렇게 알려온다 — 시트는 그대로 열려 있다.
      await _pumpApp(tester, 300);
      await tester.pumpAndSettle();
      final lifted = tester.getRect(find.text('시트')).bottom;

      expect(resting - lifted, closeTo(300, 1));
    });
  });
}
