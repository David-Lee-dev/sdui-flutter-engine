import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'package:sdui_engine/src/runtime/driver/_base.dart';
import 'package:sdui_engine/src/runtime/driver/driver_error.dart';
import 'package:sdui_engine/src/runtime/driver/modal/modal_driver.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/runtime/engine_host.dart';
import 'package:sdui_engine/src/runtime/engine_subtree.dart';
import 'package:sdui_engine/src/runtime/environment/state_writer.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';

class _NoState implements StateWriter {
  @override
  void commit(Map<String, Object?> changes) {}
}

class _FakeSink implements TelemetrySink {
  final List<TelemetryEvent> recorded = [];

  @override
  void record(TelemetryEvent event) => recorded.add(event);

  @override
  Future<TelemetryReservation> reserve(TelemetryEvent event) async =>
      _FakeReservation();
}

class _FakeReservation implements TelemetryReservation {
  @override
  void complete({Map<String, Object?> properties = const {}}) {}
}

/// 이 테스트의 마운트 host — open/close가 **같은 host의 modalStack**을 공유해야 close가 그 open을
/// 닫는다(전역 static 스택 폐기 — 이제 마운트-스코프 EngineHost.modalStack). 각 테스트가 [_mountOverlay]로
/// 세우고 tearDown이 정리한다.
EngineHost? _host;

DriverContext _ctx(
  Map<String, Object?> params, {
  void Function() Function(void Function())? onOwnerDispose,
}) => DriverContext(
  params: params,
  state: _NoState(),
  isCancelled: () => false,
  host: _host,
  onOwnerDispose: onOwnerDispose,
);

/// owner-정리 등록을 흉내내는 테스트 레지스트라 — 등록된 콜백을 [sink]에 담고, 등록해제 핸들이
/// 그 콜백을 다시 뺀다(정상 닫힘 시 누적 안 됨을 검증할 수 있게).
void Function() Function(void Function()) _recorder(
  List<void Function()> sink,
) => (cleanup) {
  sink.add(cleanup);
  return () => sink.remove(cleanup);
};

/// 루트 오버레이를 캡처해 마운트 host를 만든다(모달 본문은 [modalTemplates] 채널에서 id로 조회).
Future<void> _mountOverlay(
  WidgetTester tester, {
  Map<String, Object?> modalTemplates = const {},
  String? screenId,
}) async {
  await tester.pumpWidget(const MaterialApp(home: Scaffold(body: SizedBox())));
  final overlay = tester.firstState<OverlayState>(find.byType(Overlay));
  _host = EngineHost(
    modalTemplates: modalTemplates,
    overlay: OverlayHandle(overlay),
    screenId: screenId,
  );
}

/// 모달 본문은 인자가 아니라 채널(마운트-스코프)에서 id로 조회된다.
const _templates = <String, Object?>{
  'sample': {'_type': 'text', 'value': '모달내용'},
};

/// open은 modal id만 지목한다 — 본문은 안 싣는다.
const _open = <String, Object?>{'modal': 'sample', 'variant': 'dialog'};

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
  group('ModalDriver', () {
    tearDown(() {
      _host?.overlay?.dispose();
      _host = null;
    });

    testWidgets('open이 modal id로 modalTemplates를 조회해 렌더한다', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);

      const ModalDriver().run(_ctx(_open)).ignore();
      await tester.pumpAndSettle();

      expect(find.text('모달내용'), findsOneWidget);
    });

    testWidgets('params가 모달 자기 scope의 rootData로 시드돼 바인딩된다', (tester) async {
      // 회귀 방어: 본문 템플릿의 `${…}`가 부모 scope에서 미리 평가돼 뭉개지지 않고, 채널로 raw가
      // 흘러 EngineRunner가 모달 scope에서 fresh 컴파일·바인딩해야 한다(params → rootData 시드).
      const templates = <String, Object?>{
        'greet': {'_type': 'text', 'value': r'${msg}'},
      };
      await _mountOverlay(tester, modalTemplates: templates);

      const ModalDriver()
          .run(
            _ctx({
              'modal': 'greet',
              'params': {'msg': '안녕'},
            }),
          )
          .ignore();
      await tester.pumpAndSettle();

      expect(find.text('안녕'), findsOneWidget);
    });

    testWidgets('미등록 id는 MODAL_NOT_FOUND throw', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);

      await expectLater(
        const ModalDriver().run(_ctx({'modal': 'ghost'})),
        throwsA(
          isA<DriverError>().having((e) => e.code, 'code', 'MODAL_NOT_FOUND'),
        ),
      );
    });

    testWidgets('owner dispose가 열린 모달을 강제로 거두고 open future를 푼다 (stab #1)', (
      tester,
    ) async {
      await _mountOverlay(tester, modalTemplates: _templates);
      final cleanups = <void Function()>[];
      final opened = const ModalDriver().run(
        _ctx(_open, onOwnerDispose: _recorder(cleanups)),
      );
      await tester.pumpAndSettle();
      expect(find.text('모달내용'), findsOneWidget);

      // 여는 scope host가 dispose되는 상황 — 등록된 owner-정리를 발화한다.
      for (final cleanup in cleanups.toList()) {
        // 복사본 순회 — cleanup(=_abandon)이 등록해제로 cleanups를 제자리 수정한다.
        cleanup();
      }
      await tester.pumpAndSettle();

      expect(find.text('모달내용'), findsNothing); // 오버레이 강제 제거(누수 없음)
      expect(await opened, isNull); // 매달리지 않고 조용히 완료(취소)
    });

    testWidgets('abandon 뒤 close는 크래시 없이 무동작 — 스택도 비었다 (멱등 stab #7)', (
      tester,
    ) async {
      await _mountOverlay(tester, modalTemplates: _templates);
      final cleanups = <void Function()>[];
      const driver = ModalDriver();
      final opened = driver.run(
        _ctx(_open, onOwnerDispose: _recorder(cleanups)),
      );
      await tester.pumpAndSettle();

      for (final cleanup in cleanups.toList()) {
        // 복사본 순회 — cleanup(=_abandon)이 등록해제로 cleanups를 제자리 수정한다.
        cleanup();
      }
      await tester.pumpAndSettle();
      await opened;

      // 이미 거둬진 모달에 close를 쏴도 이중 제거·크래시 없이 no-op(스택이 비어 있다).
      driver.run(_ctx({'method': 'close', 'return': 'x'})).ignore();
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    });

    testWidgets('정상 닫힘은 owner-정리 등록을 뗀다 (콜백 누적 방지)', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);
      final cleanups = <void Function()>[];
      const driver = ModalDriver();
      final opened = driver.run(
        _ctx(_open, onOwnerDispose: _recorder(cleanups)),
      );
      await tester.pumpAndSettle();
      expect(cleanups, hasLength(1)); // 열 때 등록

      driver.run(_ctx({'method': 'close', 'return': 'ok'})).ignore();
      await tester.pumpAndSettle();
      await opened;

      expect(cleanups, isEmpty); // 정상 닫힘에 등록해제 → owner가 살아도 누적 안 됨
    });

    testWidgets('close(return)이 여는 쪽 \$data로 온다', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);
      const driver = ModalDriver();

      final opened = driver.run(_ctx(_open));
      await tester.pumpAndSettle();

      driver.run(_ctx({'method': 'close', 'return': 'picked'})).ignore();
      await tester.pumpAndSettle();

      expect(find.text('모달내용'), findsNothing);
      expect(await opened, 'picked');
    });

    testWidgets('backdrop 탭 dismiss → DriverError(DISMISSED)', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);

      final opened = const ModalDriver().run(_ctx(_open));
      // dismiss가 pumpAndSettle 중에 opened를 에러로 끝내므로, 핸들러를 미리 붙인다.
      final assertion = expectLater(
        opened,
        throwsA(isA<DriverError>().having((e) => e.code, 'code', 'DISMISSED')),
      );
      await tester.pumpAndSettle();

      await tester.tapAt(const Offset(20, 20)); // backdrop
      await tester.pumpAndSettle();

      expect(find.text('모달내용'), findsNothing);
      await assertion;
    });

    testWidgets('변형별 기본 motion과 명시적 override가 적용된다', (tester) async {
      await _mountOverlay(tester, modalTemplates: _templates);
      const driver = ModalDriver();

      driver.run(_ctx(_open)).ignore();
      await tester.pump();
      expect(
        find.byType(MotionWrapper),
        findsNothing,
      ); // dialog: presence fade only

      driver.run(_ctx({'method': 'close'})).ignore();
      await tester.pumpAndSettle();

      driver.run(_ctx({'modal': 'sample', 'variant': 'bottom_sheet'})).ignore();
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('modal-sheet-slide')),
        findsOneWidget,
      ); // native full slide
      expect(find.byType(MotionWrapper), findsNothing); // no preset wrapper

      driver.run(_ctx({'method': 'close'})).ignore();
      await tester.pumpAndSettle();

      driver
          .run(
            _ctx({
              'modal': 'sample',
              'variant': 'bottom_sheet',
              'motion': 'fade',
            }),
          )
          .ignore();
      await tester.pump();
      expect(
        find.byKey(const ValueKey<String>('modal-sheet-slide')),
        findsNothing,
      ); // native slide replaced
      expect(find.byType(MotionWrapper), findsNothing); // fade adds no wrapper
    });

    testWidgets('dialog content가 cap을 넘으면 전체를 스크롤로 감싼다', (tester) async {
      const tall = <String, Object?>{
        'tall': {
          '_type': 'column',
          '_children': [
            {'_type': 'sizedbox', 'height': 3000},
            {'_type': 'text', 'value': '바닥'},
          ],
        },
      };
      await _mountOverlay(tester, modalTemplates: tall);

      const ModalDriver()
          .run(_ctx({'modal': 'tall', 'variant': 'dialog'}))
          .ignore();
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.text('바닥'),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull); // 3000 > 90%h인데 스크롤이라 overflow 없음
    });

    testWidgets('bottom sheet content가 cap을 넘어도 template 위를 스크롤로 감싸지 않는다', (
      tester,
    ) async {
      const tall = <String, Object?>{
        'tall': {
          '_type': 'column',
          '_children': [
            {'_type': 'sizedbox', 'height': 3000},
            {'_type': 'text', 'value': '바닥'},
          ],
        },
      };
      await _mountOverlay(tester, modalTemplates: tall);

      const ModalDriver()
          .run(_ctx({'modal': 'tall', 'variant': 'bottom_sheet'}))
          .ignore();
      await tester.pumpAndSettle();

      expect(
        tester.takeException(),
        isA<FlutterError>(),
      ); // template에 scroll 영역이 없으면 overflow 노출
      expect(
        find.ancestor(
          of: find.text('바닥'),
          matching: find.byType(SingleChildScrollView),
        ),
        findsNothing,
      );
    });

    testWidgets('오버레이 미연결이면 NO_OVERLAY throw', (tester) async {
      // 오버레이 없는 host(엔진이 Overlay 밖) — insert 불가.
      _host = EngineHost(modalTemplates: _templates);
      await expectLater(
        const ModalDriver().run(_ctx(_open)),
        throwsA(isA<DriverError>().having((e) => e.code, 'code', 'NO_OVERLAY')),
      );
    });

    testWidgets('close는 자기 host의 modalStack만 닫는다 — 마운트 격리 (§1)', (
      tester,
    ) async {
      // 두 마운트 host가 같은 오버레이를 공유하되 스택은 따로. hostA의 close는 hostA 스택 top만 닫는다 —
      // 전역 스택이면 나중에 연 B모달(top)을 닫는다. 마운트별 스택이라 A만 닫히고 B는 산다(§1 스택 소유권).
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: SizedBox())),
      );
      final overlay = OverlayHandle(
        tester.firstState<OverlayState>(find.byType(Overlay)),
      );
      final hostA = EngineHost(
        modalTemplates: const {
          'a': {'_type': 'text', 'value': 'A모달'},
        },
        overlay: overlay,
      );
      final hostB = EngineHost(
        modalTemplates: const {
          'b': {'_type': 'text', 'value': 'B모달'},
        },
        overlay: overlay,
      );
      DriverContext ctx(Map<String, Object?> p, EngineHost h) => DriverContext(
        params: p,
        state: _NoState(),
        isCancelled: () => false,
        host: h,
      );
      const driver = ModalDriver();

      driver.run(ctx({'modal': 'a'}, hostA)).ignore();
      driver.run(ctx({'modal': 'b'}, hostB)).ignore(); // B를 나중에 — 전역이면 top=B
      await tester.pumpAndSettle();
      expect(find.text('A모달'), findsOneWidget);
      expect(find.text('B모달'), findsOneWidget);

      driver.run(ctx({'method': 'close'}, hostA)).ignore(); // hostA의 close
      await tester.pumpAndSettle();

      expect(find.text('A모달'), findsNothing); // 자기 스택 top만
      expect(find.text('B모달'), findsOneWidget); // 남의 것은 안 닫힘 (§1)

      overlay.dispose(); // 남은 B 정리
    });

    testWidgets('모달 내부 close 버튼이 자기 모달을 닫는다 (여는 host 공유)', (tester) async {
      // 모달 body는 별도 EngineRunner지만 여는 host를 물려받아, 내부 close가 그 모달을 담은 스택에 닿는다.
      await _mountOverlay(
        tester,
        modalTemplates: const {
          'confirm': {
            '_type': 'column',
            '_scope': {
              '_action': {
                'ok': {'_type': 'modal', 'method': 'close', 'return': 'yes'},
              },
            },
            '_children': [
              {'_type': 'text', 'value': '확인?'},
              {
                '_type': 'text',
                '_on': {'tap': 'ok'},
                'value': '닫기',
              },
            ],
          },
        },
      );

      final opened = const ModalDriver().run(_ctx({'modal': 'confirm'}));
      await tester.pumpAndSettle();
      expect(find.text('확인?'), findsOneWidget);

      await tester.tap(find.text('닫기')); // 모달 내부 close 버튼
      await tester.pumpAndSettle();

      expect(find.text('확인?'), findsNothing);
      expect(await opened, 'yes'); // close(return)이 여는 쪽 $data로
    });

    test('미지 method는 throw', () async {
      await expectLater(
        const ModalDriver().run(_ctx({'method': 'nope'})),
        throwsArgumentError,
      );
    });
    group('모달 표면 식별 (TELEMETRY.md §2 모달)', () {
      tearDown(Telemetry.reset);

      testWidgets('open이 자기 surface_view_id로 screen_view를 기록한다', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        await _mountOverlay(
          tester,
          modalTemplates: _templates,
          screenId: 'home',
        );

        const ModalDriver().run(_ctx(_open)).ignore();
        await tester.pumpAndSettle();

        final view = sink.recorded.single;
        expect(view.event, 'screen_view');
        expect(view.screenId, 'home');
        expect(view.screenViewId, isNotNull);
        expect(view.properties['surface_type'], 'modal');
        expect(view.properties['modal_id'], 'sample');
        expect(view.properties['from'], 'home');
      });

      testWidgets('close는 같은 표면의 screen_leave를 exit_reason:closed로 닫는다', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        await _mountOverlay(
          tester,
          modalTemplates: _templates,
          screenId: 'home',
        );

        const ModalDriver().run(_ctx(_open)).ignore();
        await tester.pumpAndSettle();
        const ModalDriver().run(_ctx({'method': 'close'})).ignore();
        await tester.pumpAndSettle();

        final view = sink.recorded.first;
        final leave = sink.recorded.last;
        expect(leave.event, 'screen_leave');
        expect(leave.screenViewId, view.screenViewId);
        expect(leave.screenId, 'home');
        expect(leave.properties['surface_type'], 'modal');
        expect(leave.properties['modal_id'], 'sample');
        expect(leave.properties['exit_reason'], 'closed');
      });

      testWidgets('배경 탭으로 닫히면 exit_reason:dismissed다', (tester) async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        await _mountOverlay(
          tester,
          modalTemplates: _templates,
          screenId: 'home',
        );

        const ModalDriver().run(_ctx(_open)).ignore();
        await tester.pumpAndSettle();
        await tester.tapAt(const Offset(10, 10));
        await tester.pumpAndSettle();

        final leave = sink.recorded.last;
        expect(leave.event, 'screen_leave');
        expect(leave.properties['exit_reason'], 'dismissed');
      });

      testWidgets('여는 화면을 모르면(호스트 screenId 없음) 아무 것도 기록하지 않는다', (tester) async {
        final sink = _FakeSink();
        Telemetry.install(sink);
        await _mountOverlay(tester, modalTemplates: _templates);

        const ModalDriver().run(_ctx(_open)).ignore();
        await tester.pumpAndSettle();

        expect(sink.recorded, isEmpty);
      });
    });
  });
}
