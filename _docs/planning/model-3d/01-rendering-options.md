# Filament를 지키고, 부족한 동작은 위에 얹어라

**권장안은 지금 렌더러인 Filament(thermion)를 유지하고 thermion_flutter 0.6.x(Filament 1.77.2)로 올리는 것이다.** 옷 갈아입히기는 "공용 스켈레톤 하나 + 의상 메시 토글/머티리얼 교체 + 리지드 소품의 본 부착" 구조로 설계한다. thermion에 없는 기능은 따로 채운다. IK·spring bone은 Dart 절차 코드, 교체 전환은 커스텀 dissolve 머티리얼로 만들고, 파티클은 Flutter 쪽 2D 오버레이로 처리한다. 이렇게 고르는 이유는 세 가지다. 첫째, 이 조합만 이미 리포에 들어와 있다. 둘째, 위젯처럼 합성되는 Flutter `Texture`로 그려 PlatformView 비용이 없다. 셋째, Flutter의 Impeller 백엔드 선택과 분리되어 있어 저가 Mali 기기의 Impeller 회귀를 직접 맞지 않는다. 대안을 보면 flutter_scene은 기능 목록(가중치 블렌딩, 파티클, 큰 후처리 스택)이 가장 풍부하지만 1.0 전 단계라 API가 자주 바뀌고, Flutter 3.47 Impeller에 묶여 Galaxy A32급 Mali GLES 폴백 위험을 그대로 진다. WebView(three.js/Babylon.js)는 표현력은 최고지만 이 리포가 이미 걷어낸 경로이고, 저가 Android에서 합성·메모리 비용이 가장 크다. Unity/Godot 임베드는 dress-up 뷰어에 과하다. **대안(fallback)은 두 갈래다.** 카메라를 고정 각도로 묶어도 되면 Spine(2D 스켈레탈)이 비용과 기기 부담 모두 가장 낮다. 3D를 유지하면서 Filament 위 커스텀 작업이 감당할 수 없을 만큼 커지면 flutter_scene이 차선이다. 한 가지는 미리 밝혀 둔다. **Galaxy A32급 기기에서 어느 방식이든 측정한 공개 벤치마크는 하나도 없다.** 아래 성능·메모리 판단의 대부분은 추론이며, 결정 전에 실기기로 확인해야 한다.

## 판정 기준은 "기능 상한"이 아니라 "직접 써야 하는 코드의 양"이다

요청한 기능 목록(스켈레탈 클립, 블렌딩, 모프, IK, 2차 모션, 파티클, 교체 전환)을 기본 제공으로 모두 갖춘 후보는 Unity, Godot, three.js/Babylon.js뿐이다. 셋 다 Flutter 바깥에 두 번째 런타임을 얹어야 한다. Flutter 안쪽 렌더러(thermion, flutter_scene)는 기본 기능이 모두 있다. glTF 스켈레탈 클립, 크로스페이드, 모프 타깃, 커스텀 머티리얼, 후처리다. 반대로 **IK와 spring bone은 어느 쪽에도 없어서 매 프레임 본 변환을 직접 써야 한다**. 그래서 실제 비교 축은 "무엇이 되나"가 아니라 "빠진 부분을 얼마나 싸게 채우나"와 "그 대가로 기기에 무엇을 얹나"가 된다.

| 방식 | 애니메이션 범위 | 옷 교체 | 기기 부담(추론 포함) | 개발 비용 | 판정 |
|---|---|---|---|---|---|
| Filament / thermion 0.6 | 클립·2클립 크로스페이드·모프·후처리 기본 제공. IK·spring·파티클은 직접 구현 | 토글·머티리얼·`setParent` 쉬움. 별도 GLB 스킨 공유는 Dart API에 없음 | 네이티브 6–14 MB/ABI, Texture 합성, Impeller와 분리 | 낮음(현행) + 고급 기능 중간 | **권장** |
| flutter_scene 0.24 | 가중치 N-클립 블렌딩·파티클·큰 후처리 스택 기본 제공. IK·spring 없음 | `KHR_materials_variants`, `Skin.joints` 재지정(미검증) | 네이티브 추가 거의 없음, Impeller Mali GLES 회귀 노출 | 재작성 + API 변동 | 차선(3D) |
| WebView three.js / Babylon.js | 사실상 전부(three-vrm, CCDIK, 파티클, NodeMaterial) | three.js 약 10줄로 스켈레톤 재바인딩 | WebView 프로세스·WebGL 컨텍스트·PlatformView 비용 | 브리지·컨텍스트 복구 유지 | 비권장(이미 제거됨) |
| `<model-viewer>` | 클립 하나·크로스페이드·레이어 추가 정도 | 단일 모델, variant·머티리얼만 | WebView 비용 동일 | 최저 | 부적합 |
| Unity as a Library | 전부(Mecanim, IK, VFX, Cloth) | 표준 패턴 | 런타임 1개, 모바일 전체 화면만 공식 지원, 언로드 후에도 80–180 MB 상주 | 두 번째 툴체인 | 과함 |
| Godot (LibGodot) | 대부분(AnimationTree, SkeletonIK3D, SpringBone) | 공용 Skeleton3D | Metal 경로는 iOS 16+ | Flutter 플러그인 직접 작성 | 과함 |
| Babylon Native / 네이티브 뷰 | 풍부하나 플랫폼별 이원화 | 플랫폼별 | PlatformView 비용 | 최고 | 비권장 |
| Spine 2D | 메시 변형·IK·물리(헤어·치마)·슬라이더 | 런타임 스킨 조합이 설계 목적 | 낮음(아틀라스 메모리 관리 필요) | 낮음 + 라이선스 | **대안(고정 각도)** |
| Rive | 스테이트 머신·본·메시. 물리 미확인 | 데이터 바인딩으로 아트보드 교체 | 저가 Mali에서 네이티브 렌더러 필레이트 문제 보고 | 낮음 | 조건부 |
| Lottie | 타임라인 재생만 | 고정 레이어 이미지 교체만 | 낮음 | 의상마다 재작업 | 효과용만 |
| 사전 렌더 영상/스프라이트 | 고정 | 조합 폭발 | 저장 용량 폭증 | 콘텐츠 비용 최대 | 히어로 연출만 |
| 서버 렌더 | 정지/짧은 클립 | 서버에서 자유 | 클라이언트 거의 0 | 서버 운영 | 썸네일 보조 |

## thermion은 기반이 갖춰져 있고, 빠진 곳이 분명하다

thermion 문서와 소스가 확인해 주는 범위는 넓다. 재생은 `playGltfAnimation(index, {loop, crossfade, speed, startOffset})`로 하고, `setGltfAnimationTime`으로 스크럽하며, 0.6.0에서 들어온 `MorphTargetSet`으로 이름 기반 모프 가중치를 바꾼다. 본 하나를 직접 쓰는 `setBoneTransform`, 엔티티를 본에 붙이는 `setParent`, 프리미티브별 머티리얼을 바꾸는 `setMaterialInstanceAt`도 있다 ([thermion](https://github.com/nmfisher/thermion), [animations.mdx](https://github.com/nmfisher/thermion/blob/main/docs/src/content/docs/animations.mdx), [changelog](https://pub.dev/packages/thermion_flutter/changelog)). 빠진 곳도 분명하다. 하부 Filament `Animator`가 제공하는 블렌딩은 **`applyCrossFade` 두 클립 크로스페이드가 전부이고, 블렌드 트리·애디티브·마스크 레이어 API는 없다** ([Animator.h](https://github.com/google/filament/blob/main/libs/gltfio/include/gltfio/Animator.h)). 여러 모프 애니메이션이 같은 타깃을 건드리면 가장 최근 것이 덮어쓴다. 섞이지 않는다 ([animations.mdx](https://github.com/nmfisher/thermion/blob/main/docs/src/content/docs/animations.mdx)).

옷 교체에서 가장 어려운 경우는 별도 GLB로 받은 스킨드 의상을 몸 스켈레톤에 바인딩하는 일이다. Filament C++에는 `FilamentInstance::attachSkin`/`detachSkin`이 있다 ([FilamentInstance.h](https://github.com/google/filament/blob/main/libs/gltfio/include/gltfio/FilamentInstance.h)). **하지만 thermion의 Dart 공개 API에서는 이 바인딩이 grep으로 발견되지 않았다.** 길은 둘이다. thermion의 네이티브 층에 FFI 바인딩을 추가(포크 또는 업스트림 PR)하거나, 매 프레임 몸의 본 변환을 의상 스켈레톤에 복사하는 것이다. 뒤쪽은 본마다 FFI 호출이 생겨 저가 CPU에서 부담이 된다(추론). 그래서 권장 설계는 처음부터 이 경우를 피한다. 고정 카탈로그는 **한 GLB 안에 의상 변형을 모두 넣고 가시성 토글과 머티리얼 교체로 처리**한다. 모자·무기 같은 리지드 소품은 `setParent(item, boneEntity)`로 붙인다. thermion 자체 기즈모 코드가 이미 "가장 가까운 본에 부착"을 하므로 이 경로는 확인된 것이다 ([thermion](https://github.com/nmfisher/thermion)). 카탈로그가 커져 의상을 따로 받아야 하는 시점이 오면 그때 `attachSkin` 바인딩에 투자한다. 이 판단을 미뤄도 되는 근거가 있다. 어느 렌더러를 쓰든 **의상은 같은 본 이름·바인드 포즈로 내보내야 한다**는 아트 파이프라인 제약은 똑같고, 렌더러는 런타임 바인딩의 난이도만 바꾼다.

2차 모션이 Filament 위에서 실제로 된다는 증거도 있다. 2026년 10월 네이티브 Android Filament 프로토타입이 VRM 로딩, MToon 셰이딩, **spring-bone 물리**, look-at, 블렌드셰이프 표정을 모두 Filament 바깥의 커스텀 코드로 구현했다 ([moeru-ai/airi #2907](https://github.com/moeru-ai/airi/issues/2907)). 다만 그 구현은 네이티브 코드였다. Dart에서 계산해 `setBoneTransform`으로 미는 방식의 비용은 측정된 적이 없다. 파티클은 thermion이 제공하지 않는다. 장착 순간의 반짝임 정도라면 3D 파티클을 만들 필요 없이 Texture 위에 Flutter 위젯(Lottie 등)을 겹쳐 처리하는 편이 싸다. 이 2D 오버레이 접근은 합성 구조에서 끌어낸 추론이다. Lottie는 캐릭터 엔진으로는 부적합하지만 효과용으로는 맞는다.

## 다른 3D 후보는 각자 하나씩 결정적인 비용을 진다

**flutter_scene**은 기능 면에서 가장 매력적인 경쟁자다. `AnimationClip.weight`로 여러 클립을 정규화 블렌딩하고, 파티클 시스템, `.fmat` 커스텀 셰이더, bloom·SSR·DoF·LUT까지 기본 제공한다. `Skin.joints`가 공개된 가변 리스트라서 순수 Dart로 의상 관절을 몸 노드에 다시 연결할 수 있어 보인다 ([flutter_scene](https://github.com/bdero/flutter_scene), [pub.dev](https://pub.dev/packages/flutter_scene)). 이제 main 채널 전용도 아니고 Flutter 3.47 stable을 대상으로 한다. IK·spring을 직접 짤 때 FFI 왕복 없이 노드 변환만 쓰면 되니 thermion보다 싸다. 약점은 두 가지다. 첫째, 스스로 "1.0 전, 마이너 릴리스에서도 breaking change"를 밝히는 사실상 1인 유지 패키지다(0.20→0.24가 몇 달 만에 진행됐다). 둘째, Flutter 자체의 Impeller에 올라탄다. Flutter 3.47에서는 **Vulkan이 아닌 MediaTek/Mali 기기가 GLES로 폴백하면서 ANR·멈춤이 보고됐다** ([flutter#193428](https://github.com/flutter/flutter/issues/193428)). 같은 이슈의 검색 요약에는 그래픽 메모리 +40–90 MB라는 수치도 있지만 본문은 확인하지 못했다. Galaxy A32가 바로 이 위험 영역이다. 지금 렌더러를 버리고 재작성하면서 이 위험을 사는 것은 맞지 않다.

**WebView 경로**는 표현력만 보면 정답이다. three.js에서 별도 의상 GLB를 몸 스켈레톤에 붙이는 데 `shirt.bind(character.skeleton, ...)` 몇 줄이면 되고, three-vrm이 spring bone을 준다 ([three.js forum](https://discourse.threejs.org/t/three-js-share-skeleton-between-skinnedmeshes-using-same-bones-structure/18536), [three-vrm](https://github.com/pixiv/three-vrm)). 그러나 대가가 기기와 합성 층에 쌓인다. Android 기본 `AndroidView`인 TLHC는 "빠른 스크롤에서 jank"가 생긴다. HC는 raster와 platform 스레드를 합쳐 Flutter FPS를 떨어뜨린다. 둘을 해결하는 HCPP는 API 34+·Vulkan을 요구해 저가 기기 대부분이 빠진다 ([Flutter docs](https://docs.flutter.dev/platform-integration/android/platform-views)). iOS에서는 WebContent 프로세스가 WebGL 메모리 압박으로 따로 jetsam 종료되고 "WebGL context lost" 회귀가 반복된다 ([Apple forums 778735](https://developer.apple.com/forums/thread/778735), [WebKit bug 262628](https://bugs.webkit.org/show_bug.cgi?id=262628)). WebGL2는 iOS 15부터 기본 활성이라 **iOS 13–14는 WebGL1 위험**이 있다 ([WebKit](https://webkit.org/blog/11989/new-webkit-features-in-safari-15/)). Mali-G52는 Chrome WebGPU 하드웨어 하한 아래다 ([Chrome WebGPU 121](https://developer.chrome.com/blog/new-in-webgpu-121)). 같은 기기에서 비교한 측정도 있다. Redmi K20 Pro에서 three.js + three-vrm은 약 46 fps·약 1.05 GB였고, 네이티브 Filament는 60 fps(vsync 상한)·PSS 783 MB였다 ([airi #2907](https://github.com/moeru-ai/airi/issues/2907)). 이 리포는 2026-10-31 `<model-viewer>` 렌더러를 넣었다가 2026-11-03 제거하고 Filament만 남겼다(커밋 bec2cfa, d864a1d). Prouder 앱 개발자도 "성능, 로드 시간, 투명도" 때문에 같은 방향으로 옮겼다 ([HN](https://news.ycombinator.com/item?id=40818835)). `<model-viewer>`는 직접 본·모프 제어 API가 없어 dress-up 용도로는 처음부터 상한이 낮다 ([animation.ts](https://raw.githubusercontent.com/google/model-viewer/master/packages/model-viewer/src/features/animation.ts)).

**Unity as a Library**는 기능이 가장 완비된 대신 SDUI 카드와 맞지 않는 제약이 공식 문서에 적혀 있다. 프로세스당 런타임 하나만 띄울 수 있다. 모바일에서는 **전체 화면 렌더링만 지원**한다. `Application.Unload` 뒤에도 **80–180 MB가 남는다**. iOS에서는 quit 뒤 재로드가 불가하다 ([Unity Manual](https://docs.unity3d.com/6000.2/Documentation/Manual/UnityasaLibrary.html)). Flutter 브리지 원본은 단종됐고 Unity 6 지원은 1인 포크 `flutter_unity_widget_2`에 있다 ([pub.dev](https://pub.dev/packages/flutter_unity_widget_2)). **Godot**은 LibGodot로 임베드가 가능해졌지만 Flutter 패키지는 다운로드 수십 건 수준이거나 단종됐다. Metal 렌더러는 **iOS 16+**를 요구해 iOS 13 목표와 충돌한다 ([Godot 시스템 요구](https://docs.godotengine.org/en/stable/about/system_requirements.html), [flutter_godot](https://pub.dev/packages/flutter_godot)). **Babylon Native**는 소스 형태 프리뷰이고 파티클이 미완이며 Flutter 경로가 없다 ([BabylonNative](https://github.com/BabylonJS/BabylonNative)). **네이티브 플랫폼 뷰**도 남는 길이 좁다. SceneView는 Flutter 플러그인과 iOS(RealityKit) 패키지를 모두 폐기했고 SceneKit은 WWDC25에서 soft-deprecated됐다 ([sceneview-android](https://github.com/SceneView/sceneview-android), [WWDC25 288](https://developer.apple.com/videos/play/wwdc2025/288/)). 이 길을 가면 렌더러 둘, 에셋 형식 둘(glTF/USDZ), PlatformView 비용을 모두 직접 떠안는다.

## 고정 각도라면 2D가 비용·부담 양쪽에서 이긴다

자유 회전·AR이 필수가 아니면 계산이 달라진다. Spine의 스킨은 "슬롯→어태치먼트 맵"이고, 런타임에 빈 스킨을 만들어 셔츠·바지·신발을 조합하는 것이 문서의 기본 예제다. 모든 조합을 미리 만드는 방식보다 확장성이 좋다는 점을 공식 문서가 직접 강조한다 ([Spine Skins](https://esotericsoftware.com/spine-runtime-skins)). Professional 티어에는 메시 변형·IK·물리 제약(헤어·치마 2차 모션)이 들어 있다. 4.3에는 블렌드셰이프 비슷한 모핑을 하는 슬라이더가 추가됐다 ([Spine 4.3](https://en.esotericsoftware.com/blog/Spine-4.3-released)). 2D의 숨은 이점은 3D dress-up의 숨은 비용을 피한다는 데 있다. Roblox는 의상 레이어링을 위해 케이지 메시와 WrapDeformer라는 별도 기술을 만들었다 ([Roblox](https://create.roblox.com/docs/art/accessories/caging-best-practices)). 2D에서는 아티스트가 슬롯별로 그리면 끝난다. 확인할 위험은 세 가지다. spine_flutter는 Impeller 렌더링 이슈 이력이 있다(2023–2025 보고, 4.3.x에서 해결됐는지 미확인) ([flutter#160835](https://github.com/flutter/flutter/issues/160835)). 배포에는 라이선스가 필요하다(Professional $379, 매출·투자 $500K 초과 시 Enterprise $2,499 + $379/user/yr) ([Spine purchase](https://esotericsoftware.com/spine-purchase)). 이미 존재하는 3D GLB 자산과 Filament 렌더러를 버려야 한다.

Rive는 데이터 바인딩으로 아트보드 컴포넌트를 런타임에 교체할 수 있어 구조상 dress-up에 맞는다 ([Rive data binding](https://rive.app/blog/data-binding-supercharged-lists-images-and-artboards)). 그러나 2026-10-24에 열린 이슈가 있다. Mali GPU 기기에서 전체 화면 `Factory.rive`가 **약 10 FPS, `Factory.flutter`는 60 FPS**였다(raster p50 80.9 ms 대 6.9 ms) ([rive-flutter #667](https://github.com/rive-app/rive-flutter/issues/667)). 물리 제약이 있는지도 확인하지 못했다. 사전 렌더 영상은 슬롯 4개 × 아이템 10개만 돼도 클립당 1만 조합이 나오므로(산술 추론) 히어로 연출에만 맞는다. 서버 렌더도 대화형 편집기의 대안은 아니다. Snap Bitmoji는 GLB를 GPU로 렌더해 P90 91 ms를 낸다 ([AWS](https://aws.amazon.com/blogs/media/snap-optimizes-bitmoji-rendering-with-nvidia-l4-and-amazon-g6-instances)). 대신 피드·목록 썸네일을 서버 PNG로 돌려 화면당 3D 뷰를 하나로 줄이는 보조 수단으로는 가치가 크다.

## 결정 전에 실기기에서 확인할 것, 그리고 측정과 추론의 경계

측정이라고 부를 수 있는 근거는 많지 않다. 이 리포가 Galaxy S25에서 모델 두 개로 잰 수치(GPU busy 약 79%→66%, 약 125 fps, 커밋 f8e1362)는 고급 기기 측정이다. airi의 Filament 측정(Redmi K20 Pro, 60 fps, CPU 약 1.1코어, PSS 783 MB 중 그래픽 611 MB, 아바타까지 6.8 s)과 three.js 비교 측정도 중상급 기기다 ([airi #2907](https://github.com/moeru-ai/airi/issues/2907)). Filament 네이티브 라이브러리 크기는 arm64 기준 filament-jni 2.50 MB, gltfio-jni 2.66 MB, 런타임 머티리얼 컴파일용 filamat-jni 7.79 MB다 ([filament #6687](https://github.com/google/filament/discussions/6687)). Rive #667과 Snap 수치도 해당 조건에서의 측정이다. 반면 다음은 모두 **추론**이다. thermion이 Impeller 회귀에서 분리된다는 판단, Dart→FFI 본 쓰기가 저가 CPU에서 비싸다는 예상, 메모리를 좌우하는 것은 엔진보다 텍스처·IBL·드라이버 풀이라는 판단, WebView 한 개당 100 MB+ 추가, Unity·Godot 앱 크기 증가 추정이 그렇다. **Galaxy A32 / Mali-G52, iOS 13 실기기, 배터리**에 대한 측정은 어느 방식에도 없다.

그래서 thermion 0.6 업그레이드를 확정하기 전에 다음을 실기기에서 재야 한다. 대표 캐릭터 한 벌(공용 스켈레톤, 압축 텍스처 KTX2/ASTC/ETC2, 작은 IBL, SSR/DoF 없음)로 측정한다.

| 확인 항목 | 기기 | 통과 기준(제안) |
|---|---|---|
| 0.6.1 업그레이드 후 Vulkan/GLES 초기화·첫 프레임 시간 | Galaxy A32, 최저 지원 iPhone | 크래시 없음, 첫 프레임 시간 기록 |
| idle 루프 + 크로스페이드 중 frame time·GPU 사용률·PSS(그래픽 포함) | Galaxy A32 | 30 fps 이상 안정, 전체 PSS 300 MB대 이하 |
| spring bone 본 20–40개를 Dart에서 계산해 `setBoneTransform`으로 쓸 때 CPU 증가 | Galaxy A32 | UI 스레드 jank 없음. 실패하면 네이티브 구현으로 전환 |
| 의상 토글·머티리얼 교체·dissolve 머티리얼 전환의 히칭 | Galaxy A32, iPhone | 교체 순간 프레임 드랍 없음 |
| Texture 위 Flutter 오버레이 파티클 + SDUI 스크롤 속 3D 카드 | Galaxy A32 | 스크롤 jank 없음 |
| 화면 이탈 시 렌더 정지 후 10분 배터리·발열 | Galaxy A32, iPhone | 정지 상태 GPU 0에 근접 |
| iOS 13 배포 타깃 빌드(thermion의 PlistBuddy 보정 포함)와 App Store 검증 | Xcode | 제출 통과 |
| 별도 GLB 의상이 필요해질 경우 `attachSkin` FFI 바인딩 시제품 | 개발 기기 | 몸과 동일하게 변형 |

iOS 13 항목에는 확인할 내용이 하나 더 있다. thermion 문서는 최소 iOS 13.0을 명시하면서 Flutter가 native assets 배포 타깃을 12.0으로 고정한다고 보정 절차를 안내한다 ([thermion docs](https://github.com/nmfisher/thermion/tree/main/docs/src/content/docs)). 다만 thermion 0.6이 요구하는 Flutter 3.44+ 자체의 iOS 최소 버전은 이번 조사에서 확인하지 못했다. 이것이 iOS 13 목표를 지킬 수 있는지 가르는 첫 번째 확인 사항이다.

## Conclusion

이번 조사에서 바뀐 관점이 하나 있다. dress-up의 진짜 비용은 렌더러가 아니라 **공용 리그와 의상 파이프라인**에 있고, 그 비용은 어느 3D 엔진을 고르든 같다. 렌더러 선택이 바꾸는 것은 런타임 바인딩 몇 줄과 기기 부담뿐이다. 따라서 지금 할 일은 렌더러를 갈아타는 것이 아니다. thermion 0.6 위에서 "한 GLB + 토글 + 본 부착"으로 카탈로그를 시작하고, A32 측정으로 Dart 절차 애니메이션의 한계를 확인하는 것이다. 한계가 드러나면 다음 투자 대상은 엔진 교체가 아니라 thermion 네이티브 층의 좁은 확장(`attachSkin`, 네이티브 spring bone)이다. Filament가 Google 유지 프로젝트라서 thermion이 멈춰도 포크가 유효하다는 점이 이 경로의 보험이다.

전략적으로 남는 분기점은 하나다. 제품이 자유 회전 3D를 정말 필요로 하는가. 필요하지 않다면 Spine으로 가는 것이 개발 비용·라이선스·저가 기기 부담을 모두 합쳐 가장 싼 길이다. 이 질문은 렌더러 벤치마크보다 먼저 기획에서 답해야 한다. flutter_scene은 지금 고를 대상이 아니라 지켜볼 대상이다. 1.0과 Impeller GLES 폴백 안정화가 나오면 IK·파티클 비용을 크게 줄여 줄 후보다.
