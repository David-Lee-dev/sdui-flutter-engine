# Haptic preset catalog

The eight legacy names are engine-defined semantic rhythms or platform impulses. The 151 `basic` and `continuous` presets come from [Software Mansion Pulsar](https://github.com/software-mansion/pulsar), licensed under MIT, at commit `abdee706282598ab0194ba739dce835dc828f164`. The “feel / suggested use” phrases are editorial suggestions, not source metadata. Tap counts and durations are computed from the engine's preset definitions; duration is the later of the final cumulative tap time and final curve time.

Basic presets play their taps on devices with native tap support: iOS Core Haptics and Android API 30+ devices supporting `PRIMITIVE_CLICK`. Unsupported devices play nothing for these presets. Continuous presets play the curves and taps together on iOS Core Haptics and Android API 36+ devices supporting envelope effects; unsupported devices play nothing, and continuous preset taps are never played alone. Android never falls back to waveform, amplitude, or one-shot vibration.

## Legacy presets

| `variant` | Korean name | Tap version | Unsupported-device behavior |
| --- | --- | --- | --- |
| `success` | 성공 | Yes | Semantic two-pulse rhythm via platform feedback |
| `warning` | 경고 | Yes | Semantic two-pulse rhythm via platform feedback |
| `error` | 오류 | Yes | Semantic three-pulse rhythm via platform feedback |
| `light` | 가볍게 | Yes | Platform light impact |
| `medium` | 보통 | No | Platform medium impact |
| `heavy` | 강하게 | No | Platform strong impact |
| `selection` | 선택 | No | Platform selection feedback |
| `vibrate` | 진동 | No | Platform vibrate feedback |

## Basic presets (45)

| `variant` key | Korean name | Taps (count) | Duration (ms) | Continuous curve | Feel / suggested use |
| --- | --- | ---: | ---: | --- | --- |
| `afterglow` | 여운 | 3 | 150 | no | strong hit softening across three taps; confirm a heavy action |
| `aftershock` | 여진 | 4 | 500 | no | sharp hit followed by three softer taps; signal a warning |
| `barrage` | 연타 | 7 | 309 | no | seven rapid sharp hits; celebrate a major achievement |
| `bass_drop` | 베이스 드롭 | 2 | 71 | no | two strong hits, the second softer-edged; confirm a purchase |
| `bell_toll` | 종소리 | 3 | 399 | no | three strong hits with softening edges; announce an important reminder |
| `bongo` | 봉고 | 6 | 451 | no | two quick triplets, the second softer; celebrate a reward |
| `boulder` | 바위 | 1 | 0 | no | single strong soft-edged thud; confirm a heavy action |
| `breaking_wave` | 부서지는 파도 | 3 | 202 | no | two moderate taps ending in a soft-edged thud; complete a refresh |
| `buildup` | 고조 | 7 | 309 | no | seven strong taps growing sharper; signal countdown completion |
| `cadence` | 마침 | 2 | 199 | no | sharp tap followed by a stronger soft-edged hit; finish a task |
| `canter` | 구보 | 3 | 173 | no | strong soft thud followed by two lighter taps; snap a dragged item |
| `cascade` | 계단식 낙하 | 12 | 1863 | no | long descending groups of three taps; celebrate a milestone |
| `castanets` | 캐스터네츠 | 2 | 199 | no | two evenly spaced sharp hits; announce an incoming message |
| `cat_paw` | 고양이 발 | 2 | 75 | no | two moderate taps with a softer second edge; select a card |
| `chip` | 톡 | 1 | 0 | no | single crisp tap; press a button |
| `crescendo` | 점점 세게 | 7 | 601 | no | seven evenly spaced taps growing stronger and sharper; complete a countdown |
| `fade_out` | 점점 약하게 | 6 | 506 | no | six taps fading and softening; dismiss a completed notification |
| `finger_drum` | 손가락 두드림 | 3 | 231 | no | three moderate taps with a softer finish; acknowledge a message |
| `firecracker` | 폭죽 | 2 | 75 | no | two closely spaced sharp hits; reveal a reward |
| `gallop` | 질주 | 4 | 750 | no | two pairs of strong alternating sharp and soft taps; announce a reminder |
| `gavel` | 의사봉 | 2 | 201 | no | strong soft thud followed by a sharper hit; confirm a decision |
| `herald` | 예고 | 3 | 208 | no | two moderate taps followed by a sharp hit; announce success |
| `hoof_beat` | 말발굽 | 2 | 201 | no | two evenly spaced soft-edged strong hits; confirm a selection |
| `ignition` | 점화 | 3 | 173 | no | soft thud, lighter tap, then sharper hit; start a session |
| `jolt` | 덜컥 | 1 | 0 | no | single maximum sharp hit; signal an error |
| `murmur` | 속삭임 | 2 | 80 | no | two closely spaced soft taps; acknowledge a toggle |
| `patter` | 후두둑 | 3 | 179 | no | three moderate taps ending sharper; notify of a message |
| `piston` | 피스톤 | 2 | 73 | no | two close strong medium-edged hits; lock a control |
| `plunk` | 퐁 | 1 | 0 | no | single moderate soft thud; drop an item |
| `rap` | 똑똑 | 2 | 120 | no | moderate tap followed by a lighter tap; nudge a user |
| `ratchet` | 딸깍딸깍 | 3 | 398 | no | three evenly spaced sharp hits; signal a completed step |
| `rebound` | 튕김 | 2 | 80 | no | sharp hit followed by a softer-edged strong tap; snap into place |
| `rivet` | 리벳 박기 | 3 | 150 | no | three rapid sharp strong hits; confirm a critical action |
| `stampede` | 우르르 | 4 | 750 | no | two pairs of strong soft-edged hits; announce an urgent reminder |
| `stomp` | 쿵쿵 | 3 | 150 | no | three close strong soft-edged thuds; confirm a heavy action |
| `stone_skip` | 물수제비 | 3 | 181 | no | three similar taps with progressively softer edges; dismiss a card |
| `syncopate` | 엇박 | 3 | 399 | no | three strong taps alternating sharp, soft, sharp; announce a notification |
| `thump` | 쿵 | 1 | 0 | no | single strong medium-edged hit; confirm a drop |
| `thunder_roll` | 우르릉 | 13 | 670 | no | rapid strong taps sharpen then fade; celebrate a major win |
| `tick_tock` | 똑딱 | 4 | 1200 | no | long alternating strong and weak taps; mark an important countdown |
| `tidal_surge` | 밀물 | 6 | 455 | no | quick moderate triplet followed by stronger soft thuds; reveal a reward |
| `tide_swell` | 너울 | 14 | 727 | no | rapid taps sharpen then soften as intensity shifts; complete a level |
| `tremor` | 떨림 | 1 | 0 | no | single strong very soft-edged thud; confirm a heavy drop |
| `war_drum` | 전쟁 북 | 3 | 398 | no | three spaced strong soft-edged hits; announce an important event |
| `waterfall` | 폭포 | 7 | 309 | no | seven rapid strong taps with softening edges; finish a sequence |

## Continuous presets (106)

| `variant` key | Korean name | Taps (count) | Duration (ms) | Continuous curve | Feel / suggested use |
| --- | --- | ---: | ---: | --- | --- |
| `alarm` | 알람 | 6 | 1130 | yes | long six-pulse strong alternating texture; signal an urgent alert |
| `anvil` | 모루 | 2 | 500 | yes | strong soft impact with a fading tail; confirm a heavy action |
| `applause` | 박수 | 15 | 1530 | yes | long accelerating taps growing sharper; celebrate a milestone |
| `ascent` | 상승 | 7 | 2400 | yes | long accelerating rise into a sustained peak; celebrate an achievement |
| `balloon_pop` | 풍선 터짐 | 6 | 1700 | yes | long rising pulses ending in a sharp burst; reveal a rare reward |
| `batter` | 두들김 | 5 | 380 | yes | five rapid heavy hits ending stronger; signal a failed action |
| `blip` | 삑 | 1 | 0 | yes | moderate pulse with a short decay; acknowledge a button |
| `bloom` | 피어남 | 2 | 300 | yes | two rising taps with a soft tail; reveal a reward |
| `breath` | 숨결 | 0 | 3200 | yes | long gentle double swell; mark a guided breathing milestone |
| `burst` | 터짐 | 3 | 300 | yes | three rising taps with a sharp peak; reveal a prize |
| `buzz` | 윙 | 1 | 350 | yes | strong sharp buzz fading over time; signal an error |
| `camera_shutter` | 카메라 셔터 | 2 | 150 | yes | two quick crisp clicks, second stronger; confirm a photo |
| `charge` | 충전 | 3 | 2046 | yes | long spaced rising impacts with a sustained finish; announce completion |
| `chime` | 차임 | 2 | 380 | yes | two rising spaced taps with a fading tail; notify of success |
| `chirp` | 짹 | 3 | 360 | yes | three spaced taps growing stronger and sharper; announce a message |
| `clamor` | 소란 | 4 | 430 | yes | four evenly spaced strong crisp pulses; flag a warning |
| `clasp` | 맞물림 | 2 | 220 | yes | quick rising double click; confirm a clasped selection |
| `cleave` | 쪼갬 | 2 | 250 | yes | two sharp hits with a softer second; confirm a split action |
| `coil` | 감김 | 2 | 650 | yes | gradual rise ending in a strong snap; complete a long press |
| `coin_drop` | 동전 떨어짐 | 9 | 675 | yes | nine uneven bright taps; collect a coin reward |
| `combination_lock` | 다이얼 자물쇠 | 6 | 980 | yes | five steady clicks followed by a stronger click; unlock a screen |
| `dewdrop` | 이슬방울 | 2 | 130 | yes | two light rising taps; acknowledge a small reward |
| `dirge` | 장송곡 | 3 | 2600 | yes | long three soft pulses fading in strength; signal a rare failure |
| `dissolve` | 스러짐 | 2 | 1200 | yes | long soft vibration gradually fading; mark a session ending |
| `dog_bark` | 개 짖음 | 2 | 500 | yes | two strong soft-edged bursts; call attention to a notification |
| `drone` | 웅웅 | 4 | 1780 | yes | long four evenly spaced gentle pulses; signal an ongoing alert |
| `engine_rev` | 엔진 회전 | 2 | 1800 | yes | long two rising ramps ending strong; celebrate a launch |
| `exhale` | 날숨 | 3 | 1200 | yes | long fading vibration with three diminishing taps; mark a breathing milestone |
| `explosion` | 폭발 | 4 | 1000 | yes | strong impact and descending rumble; celebrate a major reward |
| `fanfare` | 팡파르 | 4 | 580 | yes | four rising taps with a lingering peak; celebrate success |
| `feather` | 깃털 | 1 | 0 | yes | light tap with a gentle tail; select a subtle option |
| `finale` | 피날레 | 1 | 680 | yes | two curve pulses followed by a stronger tap; finish a celebration |
| `fizz` | 보글보글 | 5 | 500 | yes | five quick pulses rising then easing; reveal a small reward |
| `flare` | 섬광 | 5 | 380 | yes | fast rise to a sharp peak then fade; highlight a reward |
| `flick` | 튕기기 | 1 | 0 | yes | brief light tap with a quick decay; dismiss a card |
| `flinch` | 움찔 | 3 | 280 | yes | sharp hit followed by two fading taps; signal a failure |
| `flourish` | 화려한 마무리 | 9 | 917 | yes | rising taps peak then trail away; celebrate an achievement |
| `flurry` | 휘몰아침 | 4 | 300 | yes | four accelerating taps growing stronger; complete a quick action |
| `flush` | 쏴아 | 4 | 380 | yes | quick swell and soft fade with four taps; complete a refresh |
| `glitch` | 지직 | 8 | 220 | yes | eight irregular alternating sharp and weak taps; signal a connection error |
| `guitar_strum` | 기타 스트럼 | 1 | 1400 | yes | long strong initial hit with a fading tail; celebrate a milestone |
| `hail` | 우박 | 13 | 370 | yes | thirteen rapid uneven sharp taps; signal an urgent warning |
| `hammer` | 망치 | 6 | 1050 | yes | long accelerating soft-edged hits growing stronger; announce a critical event |
| `heartbeat` | 심장 박동 | 4 | 1000 | yes | two pairs of strong then weaker soft pulses; signal an alert |
| `impact` | 충격 | 3 | 150 | yes | strong hit followed by two fading taps; confirm a drop |
| `keyboard_mechanical` | 기계식 키보드 | 2 | 55 | yes | two very close crisp clicks, second stronger; type a key |
| `keyboard_membrane` | 멤브레인 키보드 | 1 | 0 | yes | single soft tap with a gentle decay; type a key |
| `knell` | 조종 | 2 | 550 | yes | strong hit followed by a softer delayed pulse; announce a failure |
| `knock` | 노크 | 3 | 760 | yes | three evenly spaced soft-edged knocks; notify of a message |
| `lament` | 탄식 | 4 | 2450 | yes | long descending pulses ending in a sustained fade; signal a rare failure |
| `latch` | 걸쇠 | 2 | 230 | yes | firm click followed by a softer tap; close a panel |
| `lighthouse` | 등대 | 3 | 1050 | yes | long three evenly spaced moderate pulses; signal an important reminder |
| `lilt` | 경쾌한 가락 | 2 | 360 | yes | two spaced rising taps with a soft tail; acknowledge success |
| `lock` | 잠금 | 2 | 220 | yes | light tap followed by a strong click; lock a control |
| `lope` | 성큼성큼 | 5 | 450 | yes | five quick alternating strong and weak taps; advance a progress step |
| `march` | 행진 | 3 | 900 | yes | three steady soft-edged pulses; mark a countdown |
| `metronome` | 메트로놈 | 2 | 280 | yes | two evenly spaced moderate pulses; mark a timer beat |
| `nudge` | 툭 건드림 | 2 | 120 | yes | moderate tap followed by a lighter one; suggest an action |
| `passing_car` | 지나가는 차 | 0 | 1100 | yes | long smooth swell and fade without taps; mark a transition |
| `peal` | 종 울림 | 3 | 438 | yes | three evenly spaced firm pulses; announce a notification |
| `peck` | 콕 쪼기 | 1 | 0 | yes | single brief crisp tap; select an item |
| `pendulum` | 진자 | 4 | 2400 | yes | long oscillation fading through four weak taps; mark a session ending |
| `ping` | 핑 | 1 | 0 | yes | single crisp moderate pulse; acknowledge a message |
| `pip` | 삐 | 2 | 60 | yes | two light close taps, second weaker; confirm a small selection |
| `plink` | 팅 | 2 | 150 | yes | two evenly spaced moderate taps; collect a small reward |
| `plummet` | 곤두박질 | 1 | 1050 | yes | long quiet buildup ending in a strong hit; signal a rare failure |
| `poke` | 쿡 찌르기 | 3 | 280 | yes | three firm taps with a stronger finish; remind of an action |
| `pound` | 쾅쾅 | 3 | 265 | yes | three evenly spaced powerful hits; signal a serious error |
| `power_down` | 전원 꺼짐 | 1 | 1800 | yes | long steady fade from a strong start; mark a session ending |
| `propel` | 추진 | 2 | 300 | yes | two rising firm taps with a tail; start a task |
| `pulse` | 맥박 | 0 | 2000 | yes | long two gentle sustained pulses; mark a breathing milestone |
| `pummel` | 마구 두드림 | 5 | 450 | yes | five rapid sharp heavy hits; flag a critical error |
| `push` | 밀기 | 1 | 0 | yes | single moderate pulse with a short tail; press a control |
| `radar` | 레이더 | 4 | 2520 | yes | long four evenly spaced crisp pulses; signal an important reminder |
| `rain` | 비 | 12 | 950 | yes | twelve irregular light taps over a soft texture; complete a refresh |
| `ramp` | 경사 상승 | 4 | 650 | yes | four spaced rising hits ending in a tail; complete a countdown |
| `ripple` | 잔물결 | 4 | 420 | yes | four progressively weaker taps; dismiss a notification |
| `rustle` | 바스락 | 0 | 0 | yes | sharp curve pulse followed by a softer swell; open a panel |
| `shockwave` | 충격파 | 3 | 800 | yes | strong soft impact with diminishing echoes; celebrate a major unlock |
| `snap` | 딱 | 2 | 40 | yes | firm click followed by a quick lighter tap; toggle a switch |
| `sonar` | 소나 | 5 | 2000 | yes | long spaced light pulses ending with stronger taps; announce a discovery |
| `spark` | 불꽃 | 3 | 185 | yes | three quick taps rising to a sharp hit; reveal a reward |
| `spin` | 회전 | 8 | 1808 | yes | long eight evenly spaced moderate pulses; mark a special loading sequence |
| `stagger` | 비틀거림 | 4 | 320 | yes | four quick alternating strong and weak taps; signal an invalid move |
| `stamp` | 도장 쾅 | 2 | 150 | yes | two evenly spaced moderate hits; confirm an approved action |
| `strike` | 타격 | 1 | 0 | yes | single firm hit with a quick decay; confirm a selection |
| `summon` | 소환 | 3 | 500 | yes | strong pulse followed by two closer taps; announce a reminder |
| `surge` | 밀려옴 | 4 | 330 | yes | four accelerating sharp taps growing stronger; complete a progress step |
| `sway` | 흔들림 | 3 | 1900 | yes | long three soft evenly spaced pulses; mark a breathing milestone |
| `sweep` | 쓸기 | 4 | 2100 | yes | long four crisp pulses with fading tails; announce a scan result |
| `swell` | 부풀어 오름 | 2 | 350 | yes | two spaced taps with a stronger second; reveal a card |
| `throb` | 욱신 | 2 | 150 | yes | strong pulse followed by a weaker one; signal a warning |
| `thud` | 둔탁한 쿵 | 1 | 0 | yes | moderate soft-edged pulse with a slow decay; drop an item |
| `thunder` | 천둥 | 4 | 2000 | yes | long soft buildup to a heavy fading impact; celebrate a milestone |
| `trigger` | 방아쇠 | 3 | 280 | yes | sharp hit followed by two softer fading taps; confirm an action |
| `triumph` | 승리 | 7 | 1100 | yes | long rising taps ending in three strong hits; celebrate a major win |
| `trumpet` | 트럼펫 | 6 | 460 | yes | six accelerating taps rising to a sharp peak; celebrate success |
| `typewriter` | 타자기 | 3 | 200 | yes | strong soft-edged hit with two fading echoes; type a key |
| `unfurl` | 펼침 | 5 | 1180 | yes | long rising taps followed by a sustained fade; reveal a major reward |
| `vortex` | 소용돌이 | 1 | 1400 | yes | long accelerating swell ending in a strong snap; reveal a rare reward |
| `wane` | 이지러짐 | 0 | 0 | yes | moderate curve pulse gradually fading; dismiss a panel |
| `wave` | 파도 | 0 | 2800 | yes | long three gentle swells without taps; mark a breathing milestone |
| `wisp` | 한 줄기 | 1 | 0 | yes | single very light brief tap; select a subtle option |
| `wobble` | 흔들흔들 | 0 | 0 | yes | brief sharp curve pulse with a soft tail; signal an invalid selection |
| `woodpecker` | 딱따구리 | 10 | 405 | yes | ten rapid evenly spaced sharp taps; signal an urgent alert |
| `zipper` | 지퍼 | 12 | 430 | yes | rapid light sharp taps ending stronger; complete a drag gesture |
