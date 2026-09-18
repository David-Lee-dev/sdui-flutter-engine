import 'package:flutter_test/flutter_test.dart';
import 'package:sdui_engine/src/ir/model/scope_config.dart';

void main() {
  group('ScopeConfig', () {
    group('from_raw', () {
      test('_state 맵을 리터럴로 뽑는다', () {
        expect(
          ScopeConfig.fromRaw({
            '_state': {'count': 5},
          }).state,
          {'count': 5},
        );
      });

      test('맵·리스트 값도 언팩 없이 통째로 보존한다', () {
        final config = {
          '_state': {
            'product': {'value': 100, 'currency': 'KRW'},
            'tags': ['a', 'b'],
          },
        };
        expect(ScopeConfig.fromRaw(config).state, {
          'product': {'value': 100, 'currency': 'KRW'},
          'tags': ['a', 'b'],
        });
      });

      test('_state가 없으면 빈 맵', () {
        expect(
          ScopeConfig.fromRaw({
            '_action': {'tap': <String, Object?>{}},
          }).state,
          isEmpty,
        );
      });

      test('_state가 맵이 아니면 빈 맵', () {
        expect(ScopeConfig.fromRaw({'_state': 'nope'}).state, isEmpty);
      });

      test('_state 옆의 다른 조각(_action 등)은 상태에 새지 않는다', () {
        // S1의 핵심 계약 — config는 driver 설정을 더 실어 나르지만 상태엔 _state만.
        final config = {
          '_state': {'count': 1},
          '_action': {
            'tap': {'_set': 'count'},
          },
        };
        expect(ScopeConfig.fromRaw(config).state, {'count': 1});
      });
    });
  });
}
