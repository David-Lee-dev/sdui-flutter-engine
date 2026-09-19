import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/contract/telemetry_sink.dart';
import 'package:sdui_engine/src/engine_runner.dart';
import 'package:sdui_engine/src/compile/invalid_template_exception.dart';
import 'package:sdui_engine/src/runtime/motion/_base.dart';
import 'package:sdui_engine/src/runtime/motion/motion_factory.dart';
import 'package:sdui_engine/src/runtime/telemetry/telemetry.dart';
import 'package:sdui_engine/src/runtime/widget/factory.dart';
import 'package:sdui_engine/src/runtime/wrapper/motion.dart';

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

Future<void> _pump(WidgetTester tester, Widget widget) => tester.pumpWidget(
  Directionality(textDirection: TextDirection.ltr, child: widget),
);

/// 배선 검증용 테스트 motion — 등록되면 assemble이 MotionWrapper로 감싼다.
class _MarkMotion extends Motion {
  const _MarkMotion();

  @override
  String get type => 'mark';

  @override
  MotionPlan plan(MotionParams params) =>
      const MotionPlan(duration: Duration.zero);

  @override
  Widget frame(BuildContext context, double t, Widget child, MotionParams p) =>
      child;
}

void main() {
  group('EngineRunner', () {
    // 전역 static 레지스트리라 register 뒤엔 반드시 되돌린다.
    tearDown(WidgetFactory.reset);

    testWidgets('compile-fatal은 화면을 blank로 두지 않고 에러 경계를 그린다 (§7)', (
      tester,
    ) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'text',
            'value': r'${undeclared}',
          }, // 미선언 바인딩=compile-fatal
        ),
      );
      // build가 안 터지고(빨간 화면 방지) fallback이 뜬다 — compile-fatal은 로그로 보고됨.
      expect(find.text('This screen could not be loaded.'), findsOneWidget);
      expect(tester.takeException(), isA<InvalidTemplateException>());
    });

    testWidgets('errorBuilder가 주어지면 compile-fatal에서 그 위젯을 렌더한다', (
      tester,
    ) async {
      await _pump(
        tester,
        EngineRunner(
          template: const {'_type': 'text', 'value': r'${undeclared}'},
          errorBuilder: (context, error) =>
              Text('custom-fallback:${error.runtimeType}'),
        ),
      );

      expect(find.text('This screen could not be loaded.'), findsNothing);
      expect(
        find.text('custom-fallback:InvalidTemplateException'),
        findsOneWidget,
      );
      expect(tester.takeException(), isA<InvalidTemplateException>());
    });

    testWidgets('에러 경계는 유효 template로 재컴파일 시 회복한다 (§7 recovery)', (
      tester,
    ) async {
      await _pump(
        tester,
        const EngineRunner(template: {'_type': 'text', 'value': r'${bad}'}),
      );
      expect(find.text('This screen could not be loaded.'), findsOneWidget);
      expect(tester.takeException(), isA<InvalidTemplateException>());

      // 같은 위치에 유효 template로 재pump → didUpdateWidget이 재컴파일, 경계 해제·내용 렌더.
      await _pump(
        tester,
        const EngineRunner(template: {'_type': 'text', 'value': '정상'}),
      );
      expect(find.text('This screen could not be loaded.'), findsNothing);
      expect(find.text('정상'), findsOneWidget);
    });

    testWidgets(
      'register한 커스텀 위젯이 EngineRunner 통해 렌더된다 (S2 정적 레지스트리 end-to-end)',
      (tester) async {
        // WidgetFactory(static) ↔ NodeBuilder ↔ observer 왕복을 실제 마운트로 검증한다.
        // 레지스트리 단위테스트만으론 이 배선이 끊겨도 통과할 수 있다.
        WidgetFactory.register(
          'badge',
          EagerSpec(
            (context, props, children) => Text('badge:${props['value']}'),
          ),
        );

        await _pump(
          tester,
          const EngineRunner(template: {'_type': 'badge', 'value': 'NEW'}),
        );

        expect(find.text('badge:NEW'), findsOneWidget);
      },
    );

    testWidgets('템플릿 in → 위젯 out (container > column > text 2개)', (
      tester,
    ) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'container',
            'padding': 8,
            '_child': {
              '_type': 'column',
              '_children': [
                {'_type': 'text', 'value': 'first'},
                {'_type': 'text', 'value': 'second'},
              ],
            },
          },
        ),
      );

      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Column), findsOneWidget);
      expect(find.text('first'), findsOneWidget);
      expect(find.text('second'), findsOneWidget);
    });

    testWidgets('rootData의 바인딩을 값으로 푼다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {'_type': 'text', 'value': r'${title}'},
          rootData: {'title': 'Bound'},
        ),
      );

      expect(find.text('Bound'), findsOneWidget);
    });

    testWidgets('prop의 표현식(산술·인덱싱)이 렌더된다 — 값 방언은 하나(Expression)', (
      tester,
    ) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'column',
            '_children': [
              {'_type': 'text', 'value': r'${count + 1}'},
              {'_type': 'text', 'value': r'${items[0]}'},
            ],
          },
          rootData: {
            'count': 5,
            'items': ['first'],
          },
        ),
      );

      expect(find.text('6'), findsOneWidget);
      expect(find.text('first'), findsOneWidget);
    });

    testWidgets('_on 탭이 set driver를 실행해 상태를 갱신한다 (인터랙션 end-to-end)', (
      tester,
    ) async {
      // _on → InteractionWrapper → Scope.actionHost → ActionHost.handle → set driver →
      // env.set → 구독 경계 재빌드. 마운트~탭~반영 왕복을 실제로 건다(set은 빌트인 driver).
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'container',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'increment': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
            '_child': {
              '_type': 'text',
              '_on': {'tap': 'increment'},
              'value': r'${count}',
            },
          },
        ),
      );

      expect(find.text('0'), findsOneWidget);

      await tester.tap(find.text('0'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsNothing);
    });

    testWidgets(
      '_on 탭이 modal driver로 modalTemplates를 열어 렌더한다 (foreground 채널 회귀 가드)',
      (tester) async {
        // 회귀 방어: 일반(비-background) 커맨드가 modal을 열 때 ActionHost가 DriverContext에
        // modalTemplates를 넘겨야 한다. background lane만 넘기면 foreground 모달 open이 늘
        // MODAL_NOT_FOUND로 실패한다(2026-08-11 검토 §0.1, 만장일치 최우선). 단위 modal 테스트는
        // DriverContext를 손으로 만들어 이 배선을 못 잡으므로 여기서 EngineRunner→ActionHost→Modal 왕복을 건다.

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: EngineRunner(
                template: {
                  '_type': 'container',
                  '_scope': {
                    '_action': {
                      'open': {'_type': 'modal', 'modal': 'confirm'},
                    },
                  },
                  '_child': {
                    '_type': 'text',
                    '_on': {'tap': 'open'},
                    'value': '열기',
                  },
                },
                modalTemplates: {
                  'confirm': {'_type': 'text', 'value': '모달내용'},
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('열기'));
        await tester.pumpAndSettle();

        expect(find.text('모달내용'), findsOneWidget);
      },
    );

    testWidgets('EngineRunner 언마운트가 열린 모달을 거둔다 (owner-teardown 통합 stab #1)', (
      tester,
    ) async {
      // ScopeState.dispose → ActionHost.dispose → 등록된 _abandon 발화까지의 전 배선을 실제로 건다.
      // Overlay(Scaffold)는 유지하고 EngineRunner 서브트리만 언마운트한다.
      final show = ValueNotifier<bool>(true);
      addTearDown(show.dispose);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<bool>(
              valueListenable: show,
              builder: (_, visible, _) => visible
                  ? const EngineRunner(
                      template: {
                        '_type': 'container',
                        '_scope': {
                          '_action': {
                            'open': {'_type': 'modal', 'modal': 'confirm'},
                          },
                        },
                        '_child': {
                          '_type': 'text',
                          '_on': {'tap': 'open'},
                          'value': '열기',
                        },
                      },
                      modalTemplates: {
                        'confirm': {'_type': 'text', 'value': '모달내용'},
                      },
                    )
                  : const SizedBox(),
            ),
          ),
        ),
      );

      await tester.tap(find.text('열기'));
      await tester.pumpAndSettle();
      expect(find.text('모달내용'), findsOneWidget);

      show.value = false; // EngineRunner만 언마운트 (Overlay는 살아 있음)
      await tester.pumpAndSettle();

      expect(find.text('모달내용'), findsNothing); // owner 소멸에 모달이 따라 거둬짐
    });

    testWidgets('_on doubleTap이 액션을 발화한다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'container',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'bump': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
            '_child': {
              '_type': 'text',
              '_on': {'double_tap': 'bump'},
              'value': r'${count}',
            },
          },
        ),
      );

      // 더블탭 = 두 번의 탭(최소 간격 이후, 더블탭 타임아웃 이내). 마지막 pump는 인식기의
      // 잔여 타이머(kDoubleTapMinTime)를 flush해 dispose assert를 피한다.
      await tester.tap(find.text('0'));
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.text('0'));
      await tester.pump(const Duration(milliseconds: 350));

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('_on longPress가 액션을 발화한다', (tester) async {
      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'container',
            '_scope': {
              '_state': {'count': 0},
              '_action': {
                'bump': {'_type': 'set', 'count': r'${count + 1}'},
              },
            },
            '_child': {
              '_type': 'text',
              '_on': {'long_press': 'bump'},
              'value': r'${count}',
            },
          },
        ),
      );

      await tester.longPress(find.text('0'));
      await tester.pump();

      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('템플릿 교체가 액션표를 스왑한다 — 재사용된 Scope도 최신 flow 실행', (tester) async {
      // 액션표는 마운트 불변이 아니라 seed처럼 controlled다 — 같은 위치에서 템플릿이
      // 바뀌면 didUpdateWidget이 최신 컴파일 표로 스왑해, 옛 flow가 유령 실행되지 않는다.
      Map<String, Object?> template(String incrementExpr) => {
        '_type': 'container',
        '_scope': {
          '_state': {'count': 0},
          '_action': {
            'increment': {'_type': 'set', 'count': incrementExpr},
          },
        },
        '_child': {
          '_type': 'text',
          '_on': {'tap': 'increment'},
          'value': r'${count}',
        },
      };

      await _pump(tester, EngineRunner(template: template(r'${count + 1}')));
      await tester.tap(find.text('0'));
      await tester.pump();
      expect(find.text('1'), findsOneWidget);

      // 같은 위치·타입 → Scope State 재사용(didUpdateWidget 경로), 액션만 달라짐.
      await _pump(tester, EngineRunner(template: template(r'${count + 10}')));
      await tester.tap(find.text('1'));
      await tester.pump();

      expect(find.text('11'), findsOneWidget); // 옛 flow(+1)면 2가 됐을 것
    });

    testWidgets('_motion이 위젯을 MotionWrapper로 감싼다', (tester) async {
      MotionFactory.register(const _MarkMotion());
      addTearDown(MotionFactory.reset);

      await _pump(
        tester,
        const EngineRunner(
          template: {
            '_type': 'text',
            'value': 'hi',
            '_motion': {'type': 'mark'},
          },
        ),
      );

      expect(find.text('hi'), findsOneWidget);
      // assemble이 catalog(Motion)를 wrapper(MotionWrapper)로 감쌌으면 배선 성공.
      expect(find.byType(MotionWrapper), findsOneWidget);
    });

    group('텔레메트리 (TELEMETRY.md §3 item 6, §7 screen_leave)', () {
      tearDown(Telemetry.reset);

      testWidgets('screenId/screenViewId가 없으면 아무 것도 기록하지 않는다', (tester) async {
        final sink = _FakeSink();
        Telemetry.install(sink);

        await tester.pumpWidget(
          const MaterialApp(
            home: EngineRunner(template: {'_type': 'text', 'value': 'hi'}),
          ),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        expect(sink.recorded, isEmpty);
      });

      testWidgets('dispose 시 foreground_ms와 함께 screen_leave를 기록한다', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);

        await tester.pumpWidget(
          const MaterialApp(
            home: EngineRunner(
              template: {'_type': 'text', 'value': 'hi'},
              screenId: 'home',
              screenViewId: 'sv-1',
            ),
          ),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        expect(sink.recorded, hasLength(1));
        final leave = sink.recorded.single;
        expect(leave.event, 'screen_leave');
        expect(leave.screenId, 'home');
        expect(leave.screenViewId, 'sv-1');
        expect(leave.properties['foreground_ms'], isNotNull);
        expect(leave.properties['max_depth'], 0);
        expect(leave.properties['reached_end'], isFalse);
        expect(leave.properties['scroll_sessions'], 0);
        // 라우터 관측 없이는 pop/push/deeplink_out을 구분할 수 없어 unset으로 둔다.
        expect(leave.properties.containsKey('exit_reason'), isFalse);
      });

      testWidgets(
        'TickerMode가 꺼지면(탭 비활성) exit_reason:tab으로 즉시 leave하고, 이후 dispose에서는 중복 기록하지 않는다',
        (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);
          final active = ValueNotifier<bool>(true);
          addTearDown(active.dispose);

          await tester.pumpWidget(
            MaterialApp(
              home: ValueListenableBuilder<bool>(
                valueListenable: active,
                builder: (_, isActive, _) => TickerMode(
                  enabled: isActive,
                  child: const EngineRunner(
                    template: {'_type': 'text', 'value': 'hi'},
                    screenId: 'home',
                    screenViewId: 'sv-1',
                  ),
                ),
              ),
            ),
          );

          active.value = false; // 탭 비활성화와 동치
          await tester.pumpAndSettle();

          expect(sink.recorded, hasLength(1));
          expect(sink.recorded.single.properties['exit_reason'], 'tab');

          // 이후 완전 언마운트 — 이미 닫힌 방문이라 추가 기록이 없어야 한다.
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          expect(sink.recorded, hasLength(1));
        },
      );

      testWidgets('screenViewId가 바뀌면(탭 재방문) 새 방문으로 leave를 기록한다', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);

        await tester.pumpWidget(
          const MaterialApp(
            home: EngineRunner(
              template: {'_type': 'text', 'value': 'hi'},
              screenId: 'home',
              screenViewId: 'sv-1',
            ),
          ),
        );
        await tester.pumpWidget(
          const MaterialApp(
            home: EngineRunner(
              template: {'_type': 'text', 'value': 'hi'},
              screenId: 'home',
              screenViewId: 'sv-2',
            ),
          ),
        );
        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        // sv-1은 didUpdateWidget에서 조용히 리셋되고(이미 leave된 적 없음),
        // 최종 dispose는 현재 방문(sv-2) 하나만 닫는다.
        expect(sink.recorded, hasLength(1));
        expect(sink.recorded.single.screenViewId, 'sv-2');
      });

      group('resolveExitReason (라우터·모달이 아는 이탈 사유)', () {
        testWidgets('dispose 시 앱이 준 이탈 사유를 실어 보낸다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);

          await tester.pumpWidget(
            MaterialApp(
              home: EngineRunner(
                template: const {'_type': 'text', 'value': 'hi'},
                screenId: 'home',
                screenViewId: 'sv-1',
                resolveExitReason: () => 'pop',
              ),
            ),
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          expect(sink.recorded.single.properties['exit_reason'], 'pop');
        });

        testWidgets('앱이 null을 주면 여전히 키 자체를 남기지 않는다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);

          await tester.pumpWidget(
            MaterialApp(
              home: EngineRunner(
                template: const {'_type': 'text', 'value': 'hi'},
                screenId: 'home',
                screenViewId: 'sv-1',
                resolveExitReason: () => null,
              ),
            ),
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          expect(
            sink.recorded.single.properties.containsKey('exit_reason'),
            isFalse,
          );
        });

        testWidgets('가시성 상실 시에도 앱이 아는 사유가 로컬 추론보다 우선한다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);
          final active = ValueNotifier<bool>(true);
          addTearDown(active.dispose);

          await tester.pumpWidget(
            MaterialApp(
              home: ValueListenableBuilder<bool>(
                valueListenable: active,
                builder: (_, isActive, _) => TickerMode(
                  enabled: isActive,
                  child: EngineRunner(
                    template: const {'_type': 'text', 'value': 'hi'},
                    screenId: 'home',
                    screenViewId: 'sv-1',
                    resolveExitReason: () => 'deeplink_out',
                  ),
                ),
              ),
            ),
          );

          active.value = false;
          await tester.pumpAndSettle();

          expect(
            sink.recorded.single.properties['exit_reason'],
            'deeplink_out',
          );
        });

        // paused/hidden은 테스트 바인딩에서 프레임을 멈춰 unmount가 아예 안 도므로
        // 같은 분기(`_appForeground == false`)를 inactive로 태운다.
        testWidgets('포그라운드가 아닐 때 사라지면 background로 귀속한다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);

          await tester.pumpWidget(
            const MaterialApp(
              home: EngineRunner(
                template: {'_type': 'text', 'value': 'hi'},
                screenId: 'home',
                screenViewId: 'sv-1',
              ),
            ),
          );
          tester.binding.handleAppLifecycleStateChanged(
            AppLifecycleState.inactive,
          );
          await tester.pump();

          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          expect(sink.recorded.single.properties['exit_reason'], 'background');
        });
      });

      group('모달 표면 (TELEMETRY.md §2 모달)', () {
        testWidgets('surface_type·modal_id가 leave에 실린다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);

          await tester.pumpWidget(
            const MaterialApp(
              home: EngineRunner(
                template: {'_type': 'text', 'value': 'hi'},
                screenId: 'home',
                screenViewId: 'surface-1',
                surfaceType: 'modal',
                modalId: 'confirm',
              ),
            ),
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          final leave = sink.recorded.single;
          expect(leave.screenId, 'home');
          expect(leave.screenViewId, 'surface-1');
          expect(leave.properties['surface_type'], 'modal');
          expect(leave.properties['modal_id'], 'confirm');
        });

        testWidgets('화면 마운트에는 surface_type 키가 붙지 않는다', (tester) async {
          final sink = _FakeSink();
          Telemetry.install(sink);

          await tester.pumpWidget(
            const MaterialApp(
              home: EngineRunner(
                template: {'_type': 'text', 'value': 'hi'},
                screenId: 'home',
                screenViewId: 'sv-1',
              ),
            ),
          );
          await tester.pumpWidget(const SizedBox());
          await tester.pumpAndSettle();

          final leave = sink.recorded.single;
          expect(leave.properties.containsKey('surface_type'), isFalse);
          expect(leave.properties.containsKey('modal_id'), isFalse);
        });
      });

      testWidgets('세로 스크롤 depth를 추적하고 가로축은 무시한다 (primary vertical만)', (
        tester,
      ) async {
        final sink = _FakeSink();
        Telemetry.install(sink);

        Map<String, Object?> item(int i) => {
          '_type': 'text',
          'value': 'item-$i',
        };

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                height: 200,
                child: EngineRunner(
                  screenId: 'home',
                  screenViewId: 'sv-1',
                  template: {
                    '_type': 'column',
                    '_children': [
                      // 가로 캐러셀 먼저 — 세로 리스트와 나란히 depth==0으로 잡히는 형제.
                      {
                        '_type': 'container',
                        'height': 40,
                        '_child': {
                          '_type': 'list_view',
                          'scroll_direction': 'horizontal',
                          'item_extent': 100,
                          '_children': [for (var i = 0; i < 10; i++) item(i)],
                        },
                      },
                      {
                        '_type': 'expanded',
                        '_child': {
                          '_type': 'list_view',
                          'item_extent': 50,
                          '_children': [for (var i = 0; i < 20; i++) item(i)],
                        },
                      },
                    ],
                  },
                ),
              ),
            ),
          ),
        );

        // 가로 캐러셀을 먼저 드래그 — primary 선정에 끼어들면 안 된다. ListView 자체를
        // 드래그 지점으로 삼는다 — 아이템 텍스트를 잡으면 스크롤 뒤 offstage로 밀려나
        // finder가 못 찾는다.
        final horizontal = find.byType(ListView).at(0);
        final vertical = find.byType(ListView).at(1);

        await tester.drag(horizontal, const Offset(-80, 0));
        await tester.pumpAndSettle();

        // 세로 리스트를 끝까지 스크롤.
        await tester.drag(vertical, const Offset(0, -600));
        await tester.pumpAndSettle();
        await tester.drag(vertical, const Offset(0, -600));
        await tester.pumpAndSettle();

        await tester.pumpWidget(const SizedBox());
        await tester.pumpAndSettle();

        final leave = sink.recorded.single;
        expect(leave.properties['reached_end'], isTrue);
        expect(leave.properties['max_depth'], 100);
        expect((leave.properties['scroll_sessions'] as int) >= 1, isTrue);
      });
    });
  });
}
