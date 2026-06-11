# exelbid_plugin

ExelBid 광고 SDK를 Flutter에서 사용하기 위한 플러그인입니다. 배너 · 네이티브 · 비디오 · 전면(Interstitial) 광고와 미디에이션(워터폴)을 지원합니다.

> **플랫폼 지원**
> | 광고 유형 | iOS | Android |
> |---|:---:|:---:|
> | Banner / Native / Video / Interstitial | ✅ | ✅ |
> | Mediation (Banner / Native / Video / Interstitial) | ✅ | ✅ |
>
> iOS·Android 모두 지원합니다. 최소 버전은 **iOS 13.0+ / Android 5.0+ (API 21)** 입니다.
> 같은 Dart 코드로 두 플랫폼이 동작하며, 광고 단위 ID만 플랫폼별로 다르게 관리하면 됩니다.

> **ExelBid 광고**는 추가 설정 없이 바로 사용할 수 있습니다.
> **미디에이션**으로 AdMob · FAN · AdFit 등 외부 네트워크를 함께 운영할 수 있습니다.

---

## 목차

1. [설치](#설치)
2. [iOS 프로젝트 설정](#ios-프로젝트-설정)
3. [Android 프로젝트 설정](#android-프로젝트-설정)
4. [배너 광고](#배너-광고)
5. [네이티브 광고](#네이티브-광고)
6. [비디오 광고](#비디오-광고)
7. [전면 광고 (Interstitial)](#전면-광고-interstitial)
8. [광고 옵션 (AdOptions)](#광고-옵션-adoptions)
9. [미디에이션](#미디에이션)
10. [에러 처리](#에러-처리)
11. [공통 API · API 요약](#공통-api--api-요약)
12. [부록: Android AdMob 전면/비디오 노치 채우기 (선택)](#부록-android-admob-전면비디오-노치-채우기-선택)

---

## 설치

`pubspec.yaml`에 추가합니다.

```yaml
dependencies:
  exelbid_plugin:
    git:
      url: https://github.com/onnuridmc/Exelbid_Plugin.git
```

```bash
flutter pub get
```

요구사항: **Flutter ≥ 3.16.0, Dart ≥ 3.2.0**. import는 단일 배럴 파일 하나면 됩니다.

```dart
import 'package:exelbid_plugin/exelbid_plugin.dart';
```

---

## iOS 프로젝트 설정

플러그인이 `ExelBidSDK`를 자동으로 가져옵니다. pod 설치만 하면 됩니다.

```bash
cd ios && pod install
```

### App Tracking Transparency (필수)

iOS에서 광고 식별자(IDFA)를 사용하려면 **ATT 권한 요청이 필요**합니다. 두 가지를 호스트 앱이 직접 처리해야 합니다.

**1. `Info.plist`에 권한 안내 문구 추가 (필수)**

```xml
<key>NSUserTrackingUsageDescription</key>
<string>맞춤형 광고를 제공하기 위해 사용자 활동을 추적합니다.</string>
```

**2. 적절한 시점(앱 활성화 직후 등)에 ATT 요청 (필수)**

플러그인은 ATT를 **자동으로 띄우지 않습니다.** 호출 시점은 앱이 결정합니다.

```dart
final status = await Exelbid.requestTrackingAuthorization();
if (status == TrackingAuthorizationStatus.authorized) {
  // IDFA 사용 가능
}
```

> iOS 14 미만에는 ATT 개념이 없어 항상 `authorized`를 반환합니다. Android에서도 항상 `authorized`를 반환하므로, 위 코드를 두 플랫폼 공통으로 호출해도 안전합니다.

### SKAdNetwork (권장, 준비중)

광고 성과 측정(어트리뷰션)을 위해 매체사에서 제공받은 SKAdNetwork ID 목록을 `Info.plist`에 등록하세요. (선택 사항이며, 정확한 성과 측정에 권장됩니다.)

```xml
<key>SKAdNetworkItems</key>
<array>
  <dict>
    <key>SKAdNetworkIdentifier</key>
    <string>xxxxxxxxxx.skadnetwork</string>
  </dict>
</array>
```

---

## Android 프로젝트 설정

ExelBid Android SDK와 필수 라이브러리·권한·광고 표시용 액티비티를 플러그인이 모두 번들하므로, 호스트 앱에서 별도 의존성 추가는 필요 없습니다.

### 최소 SDK (필수)

`minSdkVersion`은 **21 이상**이어야 합니다(`android/app/build.gradle`). AndroidX가 활성화되어 있어야 합니다(최신 Flutter 프로젝트는 기본 활성화).

> AdMob · FAN · AdFit 등 외부 네트워크를 함께 쓰려면 [미디에이션](#미디에이션) 섹션의 설정을 따르세요. **AdMob을 사용할 때만** AdMob 앱 ID 설정이 필요합니다.

---

## 배너 광고

`ExelbidBannerAd`는 위젯 트리에 직접 배치하는 임베디드 광고입니다.

```dart
ExelbidBannerAd(
  adUnitId: 'YOUR_BANNER_AD_UNIT_ID',
  size: const Size(320, 50),
  autoLoad: true,      // 생성 즉시 로드 (기본 true)
  fullWebView: false,  // true면 크리에이티브가 배너 영역을 꽉 채움 (기본 false)
  options: AdOptions(testing: true),
  onLoad: () => print('loaded'),
  onFail: (e) => print('failed: ${e.message}'),
  onClick: () => print('clicked'),
  onLeaveApp: () => print('left app'),
  onClickFinish: () => print('click finished'),
)
```

`size`로 지정한 영역만큼 차지하므로 `SizedBox`/레이아웃 제약 안에 두면 됩니다.

**배너 동작 파라미터**

| 파라미터 | 기본 | 설명 |
|---|:---:|---|
| `autoLoad` | `true` | 위젯 생성 즉시 첫 광고를 요청합니다. `false`면 [컨트롤러](#수동-제어-load--stop)의 `load()`로 직접 첫 로드를 트리거합니다(예: ATT 동의 이후로 미루기). |
| `fullWebView` | `false` | `true`면 크리에이티브가 배너 영역을 꽉 채웁니다. |

### 수동 제어 (load / stop)

`ExelbidBannerController`를 넘기면 배너를 직접 제어할 수 있습니다. ATT 동의 이후로 첫 로드를 미루거나, 화면 전환 시 갱신을 멈추는 용도로 유용합니다.

```dart
final controller = ExelbidBannerController();

ExelbidBannerAd(
  adUnitId: 'YOUR_BANNER_AD_UNIT_ID',
  size: const Size(320, 50),
  autoLoad: false,        // 첫 로드를 컨트롤러로 직접 트리거
  controller: controller,
)

// 준비가 끝난 뒤:
controller.load();   // 요청(또는 강제 재요청)
controller.stop();   // 진행 중 요청 취소 + 자동 갱신 중지
```

> 컨트롤러는 PlatformView가 생성되기 전(`isReady == false`)에는 호출이 무시됩니다.

---

## 네이티브 광고

네이티브 광고는 **호스트 앱이 레이아웃을 그리고, SDK가 각 자산(텍스트/이미지)을 네이티브 뷰에 채우는** 방식입니다. `child`에 원하는 레이아웃을 구성하고, 자산이 들어갈 위치마다 **슬롯 위젯**을 둡니다. 플러그인이 각 슬롯의 위치/크기를 측정해 네이티브로 전달하면 SDK가 그 자리에 자산을 렌더링합니다. (노출·클릭 추적이 실제 네이티브 뷰에 묶이도록 하는 구조)

```dart
ExelbidNativeAdView(
  adUnitId: 'YOUR_NATIVE_AD_UNIT_ID',
  desiredAssets: const {
    NativeAsset.title,
    NativeAsset.desc,
    NativeAsset.ctatext,
    NativeAsset.icon,
    NativeAsset.main,
  },
  options: AdOptions(testing: true),
  onLoad: () => print('attached'),
  onFail: (e) => print('failed: ${e.message}'),
  onImpression: () => print('impression'),
  onClick: () => print('clicked'),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Row(
        children: [
          ExelbidNativeAdIconImage(width: 40, height: 40),
          const SizedBox(width: 8),
          const Expanded(child: ExelbidNativeAdTitle()),
          const SizedBox(width: 8),
          SizedBox(width: 80, child: ExelbidNativeAdCallToAction()),
        ],
      ),
      const SizedBox(height: 8),
      const SizedBox(
        height: 180,
        child: ExelbidNativeAdMedia(),
      ),
      const SizedBox(height: 8),
      const SizedBox(height: 60, child: ExelbidNativeAdDescription()),
    ],
  ),
)
```

### 슬롯 위젯

| 위젯 | 자산 | 종류 |
|---|---|---|
| `ExelbidNativeAdTitle` | 제목 | 텍스트 |
| `ExelbidNativeAdDescription` | 본문 | 텍스트 |
| `ExelbidNativeAdCallToAction` | CTA 버튼 텍스트 | 텍스트 |
| `ExelbidNativeAdSponsored` | 광고주 표기 (Sponsored) | 텍스트 |
| `ExelbidNativeAdDisplayUrl` | 표시 URL | 텍스트 |
| `ExelbidNativeAdMedia` | 메인 크리에이티브 (이미지 또는 동영상) | 미디어 |
| `ExelbidNativeAdIconImage` | 아이콘 | 이미지 |
| `ExelbidNativeAdLogo` | 로고 이미지 | 이미지 |
| `ExelbidNativeAdPrivacyIcon` | 프라이버시 아이콘 | 이미지 |

- 이미지·미디어 슬롯은 `width`/`height`로 크기를 지정할 수 있습니다. `desiredAssets`에 요청한 자산만 SDK가 채웁니다.
- **메인 크리에이티브는 `ExelbidNativeAdMedia` 하나로 통합**되어 있습니다. 정적 이미지든 동영상이든 이 슬롯에 채워집니다(별도 메인 이미지 슬롯은 없습니다).

### 스타일 적용

네이티브 광고의 텍스트/이미지는 **네이티브 뷰가 그리므로**, 폰트·색·배경·둥글림은 `ExelbidNativeSlotStyle`로 네이티브에 전달해야 반영됩니다. (슬롯 위젯 자체는 빈 영역이라 Flutter `TextStyle`은 적용되지 않습니다.)

```dart
ExelbidNativeAdTitle(
  style: ExelbidNativeSlotStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    textColor: Colors.black87,
    maxLines: 2,
  ),
),
ExelbidNativeAdCallToAction(
  style: const ExelbidNativeSlotStyle(
    fontWeight: FontWeight.w600,
    textColor: Colors.white,
    textAlign: TextAlign.center,
    backgroundColor: Color(0xFF1565C0),
    cornerRadius: 8,
    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
  ),
),
ExelbidNativeAdMedia(
  style: const ExelbidNativeSlotStyle(
    contentMode: BoxFit.cover,
    cornerRadius: 8,
  ),
),
```

`ExelbidNativeSlotStyle` 필드(모두 선택, 설정한 것만 적용):

| 분류 | 필드 | 적용 대상 |
|---|---|---|
| 텍스트 | `textColor`, `fontFamily`, `fontSize`, `fontWeight`, `textAlign`, `maxLines`, `overflow`, `padding` | 제목 · 본문 · CTA 등 텍스트 슬롯 |
| 박스 | `backgroundColor`, `cornerRadius`, `borderWidth`, `borderColor` | 모든 슬롯 |
| 이미지 | `contentMode` (`BoxFit`) | 아이콘 · 메인 미디어 · 로고 · 프라이버시 |

- `overflow` (`TextOverflow`) — 텍스트가 넘칠 때 처리(`ellipsis`=말줄임표, `clip`=잘라냄 등).
- `padding` (`EdgeInsets`) — 텍스트 슬롯의 안쪽 여백. 배경/테두리는 슬롯 전체를 채우고 텍스트만 들여써집니다(CTA 버튼류에 유용).

### ⚠️ 커스텀 폰트는 iOS·Android 앱에도 등록해야 적용됩니다

광고의 글자는 Flutter가 아니라 **휴대폰 운영체제(iOS·Android)가 직접 그립니다.** 그래서 `fontFamily`로 폰트를 지정하려면, 그 폰트 파일이 **iOS 앱과 Android 앱 양쪽에 등록**되어 있어야 합니다. Flutter의 `pubspec.yaml`에 `fonts:`로만 선언하면 광고 글자에는 **반영되지 않고**, 등록되지 않은 폰트는 휴대폰 **기본 폰트로 대체**됩니다.

| 폰트 종류 | 동작 |
|---|---|
| 휴대폰에 기본 내장된 폰트 (`'Georgia'` 등) | 추가 등록 없이 바로 적용 ✅ |
| 직접 추가한 커스텀 폰트 | 아래처럼 iOS·Android 앱에 각각 등록해야 적용<br>· **iOS** — 폰트 파일을 앱(Runner)에 넣고 `Info.plist`의 `UIAppFonts`에 등록<br>· **Android** — 폰트 파일을 `res/font/` 폴더에 넣고 등록 |

> 📌 **단계별 설정 방법은 → [커스텀 폰트 설정 가이드 (doc/CUSTOM_FONT_SETUP.md)](doc/CUSTOM_FONT_SETUP.md) 를 꼭 확인하세요.**

### 데이터 전용 자산 (onData)

`rating`·`likes`·`downloads`·`price`·`salePrice`·`secondaryBody(desc2)`·`phone`·`address`처럼 **렌더 슬롯이 없는 자산**은 `onData` 콜백으로 값을 받아 직접 그립니다. `onLoad` 시점에 `ExelbidNativeAdData`가 전달됩니다.

```dart
ExelbidNativeAdView(
  adUnitId: '...',
  desiredAssets: const { NativeAsset.title, NativeAsset.rating, NativeAsset.price },
  onData: (data) {
    print('별점: ${data.rating}, 가격: ${data.price}');
    // setState로 보관해 평범한 Flutter 위젯으로 표시
  },
  child: /* 슬롯 레이아웃 */,
)
```

`ExelbidNativeAdData` 필드: `title`, `body`, `secondaryBody`, `callToAction`, `sponsored`, `displayUrl`, `phone`, `address`, `iconImageUrl`, `mainImageUrl`, `logoImageUrl`, `rating`, `likes`, `downloads`, `price`, `salePrice`, `hasVideo`.

---

## 비디오 광고

전면 모달로 재생되는 동영상 광고입니다. `create()` → `load()` → `present()` 순서로 사용하며, 이벤트는 `events` 스트림으로 수신합니다.

```dart
final ad = await ExelbidVideoAd.create(
  adUnitId: 'YOUR_VIDEO_AD_UNIT_ID',
  options: AdOptions(testing: true),
);

final sub = ad.events.listen((data) {
  switch (data.event) {
    case VideoAdEvent.onLoad:
      ad.present();                       // 로드 완료 후 표시
    case VideoAdEvent.onProgress:
      print('진행률: ${data.percent}%');
    case VideoAdEvent.onFail:
      print('실패: ${data.error?.message}');
    case VideoAdEvent.onDidDisappear:
      ad.dispose();                       // 닫힌 후 해제
    default:
      break;
  }
});

await ad.load();

// 사용 종료 시
await sub.cancel();
await ad.dispose();
```

이벤트: `onLoad` · `onFail` · `onProgress` · `onWillAppear` · `onDidAppear` · `onWillDisappear` · `onDidDisappear` · `onClick` · `onLeaveApp`

> `onProgress`(재생 진행률)는 **iOS에서만 발생**합니다. Android SDK에는 진행률 콜백이 없어 발생하지 않습니다.

`isReady`로 표시 가능 여부를 확인할 수 있습니다. **인스턴스는 1회용** — 사용 후 반드시 `dispose()`로 해제하세요.

---

## 전면 광고 (Interstitial)

전체화면 전면 광고입니다. 비디오와 동일한 `create/load/present` 패턴입니다.

```dart
final ad = await ExelbidInterstitialAd.create(
  adUnitId: 'YOUR_INTERSTITIAL_AD_UNIT_ID',
  fullWebView: false, // true면 크리에이티브가 화면을 꽉 채움 (기본 false)
);

final sub = ad.events.listen((data) {
  switch (data.event) {
    case InterstitialAdEvent.onLoad:
      ad.present();
    case InterstitialAdEvent.onFail:
      print('실패: ${data.error?.message}');
    case InterstitialAdEvent.onDidDisappear:
      ad.dispose();
    default:
      break;
  }
});

await ad.load();
```

이벤트: `onLoad` · `onFail` · `onWillAppear` · `onDidAppear` · `onWillDisappear` · `onDidDisappear` · `onClick` · `onLeaveApp` · `onClickFinish`

표시 중 강제 종료는 `stop()`, 해제는 `dispose()`를 사용합니다.

---

## 광고 옵션 (AdOptions)

모든 광고의 `options` 파라미터로 타깃팅/테스트 설정을 전달합니다. 모두 선택이며, 설정한 항목만 적용됩니다.

```dart
AdOptions(
  keywords: {'category': 'sports'},
  yearOfBirth: 1990,
  gender: Gender.male,           // unspecified / male / female
  location: const AdLocation(latitude: 37.5, longitude: 127.0),
  coppa: false,                  // 아동 대상 여부
  testing: true,                 // 테스트 광고 (개발 중 권장)
  videoSkipMin: 15,               // (비디오) 스킵 가능 최소 비디오 시간(초)
  videoSkipAfter: 10,             // (비디오) 스킵 버튼 표시 시점(초)
)
```

---

## 미디에이션

### 미디에이션이란?

하나의 광고 자리에 여러 광고 네트워크를 연결해 두고, **순서대로 시도해 가장 먼저 광고를 채우는 네트워크를 노출**하는 방식입니다(워터폴). 한 네트워크가 실패하면 다음 네트워크로 자동 폴백하므로, 단일 네트워크보다 노출률(필레이트)이 올라갑니다.

- **시도 순서(우선순위)는 ExelBid 콘솔(서버)에서 설정**합니다. 플러그인/앱은 그 순서를 그대로 따르며, 앱 코드로 순서를 정하지 않습니다.
- **ExelBid 네트워크는 기본 포함**(추가 설정 불필요)입니다. **AdMob · FAN · AdFit은 사용하려면 호스트 앱이 직접 연결**해야 합니다.
- 연결(등록)하지 않은 네트워크는 워터폴에서 자동으로 건너뜁니다(`adapterNotRegistered`).

> **왜 직접 연결해야 하나요?** 플러그인은 각 네트워크의 **어댑터 코드만 제공**하고, 실제 네트워크 SDK는 포함하지 않습니다. 그래서 쓰지 않는 네트워크의 SDK가 앱에 들어가지 않습니다(앱 용량·정책 부담 최소화). iOS의 어댑터 패키지 추가 방식과 동일합니다.

### 설정 순서

사용할 외부 네트워크(AdMob/FAN/AdFit)마다 아래를 진행합니다. ExelBid만 쓸 경우 1·5만 하면 됩니다.

1. **ExelBid 콘솔**에서 해당 광고 단위의 워터폴(네트워크·순서)을 구성
2. **네트워크 SDK 추가** — 앱에 해당 네트워크 SDK 의존성 추가 ([Android](#1단계--어댑터-연결--android) / [iOS](#2단계--어댑터-연결--ios))
3. **네트워크별 필수 설정** — 앱 ID 등 ([네트워크별 필수 설정](#3단계--네트워크별-필수-설정))
4. **어댑터 등록** — 플러그인이 제공하는 모듈을 등록
5. **코드 작성** — `ExelbidMediated*` 위젯/클래스로 광고 요청 ([코드에서 사용](#4단계--코드에서-사용))

> 2·4단계(SDK 추가 + 어댑터 등록)는 한 곳에서 같이 처리하므로, 아래 플랫폼별 안내에 묶어서 정리했습니다.

### 1단계 · 어댑터 연결 — Android

**(1) `android/app/build.gradle`에 사용할 네트워크 SDK만 추가**

```gradle
dependencies {
    implementation 'com.google.android.gms:play-services-ads:23.4.0'  // AdMob
    implementation 'com.facebook.android:audience-network-sdk:6.20.0' // FAN
    implementation 'com.kakao.adfit:ads-base:3.12.9'                  // AdFit
}
```

> AdFit을 쓸 경우 Kakao maven 저장소가 필요합니다 — 프로젝트의 `android/build.gradle`(또는 `settings.gradle`)의 저장소 목록에 추가:
> ```gradle
> maven { url 'https://devrepo.kakao.com/nexus/content/groups/public/' }
> ```

**(2) `MainActivity`에서 사용할 네트워크 모듈만 등록**

```kotlin
import com.exelbid.flutter.mediation.builtin.AdMobMediationModule
import com.exelbid.flutter.mediation.builtin.FanMediationModule
import com.exelbid.flutter.mediation.builtin.AdfitMediationModule
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        AdMobMediationModule.register()   // 사용할 네트워크만 골라서 등록
        FanMediationModule.register()
        AdfitMediationModule.register()
    }
}
```

> 각 모듈은 해당 네트워크가 지원하는 포맷(배너/전면/네이티브/비디오)을 한 번에 등록합니다.
> ⚠️ SDK를 추가하지 않고 모듈만 등록하면, 그 네트워크 광고를 로드하는 시점에 `ClassNotFoundError`가 발생합니다. (1)·(2)는 항상 같이 하세요.

### 2단계 · 어댑터 연결 — iOS

iOS는 어댑터 패키지를 추가하고 모듈을 등록합니다. **SwiftPM 또는 CocoaPods** 중 하나로 통합합니다. (example 앱의 `example/ios`에 적용되어 있습니다.) 최소 배포타깃은 **iOS 14**입니다.

**(1-A) SwiftPM** — Xcode에서 Runner 타깃에 `https://github.com/onnuridmc/ExelBid_iOS_Mediation_Adapter.git`를 추가하고, 사용할 네트워크의 product를 선택합니다.

| 네트워크 | SwiftPM product |
|---|---|
| AdMob | `ExelBidMediationAdMob` |
| FAN | `ExelBidMediationFAN` |
| AdFit | `ExelBidMediationAdFit` |

**(1-B) CocoaPods** — `ios/Podfile`의 Runner 타깃에 사용할 subspec을 추가하고 `pod install`. 팟 이름은 `ExelBid_Mediation_Adapter`, 버전 **1.1.5**.

```ruby
target 'Runner' do
  pod 'ExelBid_Mediation_Adapter/AdMob', '1.1.5'  # AdMob (Google-Mobile-Ads-SDK 포함)
  pod 'ExelBid_Mediation_Adapter/FAN', '1.1.5'    # FAN (FBAudienceNetwork 포함)
  # AdFit은 CocoaPods 미제공 → SwiftPM(1-A)으로 추가
end
```

> 어느 방식이든 플러그인과 동일한 `ExelBidSDK` 경로를 써서 중복 링크되지 않습니다. CocoaPods는 모든 subspec이 단일 모듈 `ExelBidMediationAdapter`로 노출되고, SwiftPM은 네트워크별 모듈로 노출됩니다(아래 import 차이 참고).

**(2) `AppDelegate`에서 사용할 모듈 등록**

```swift
import ExelBidSDK
import GoogleMobileAds          // AdMob 사용 시

// 어댑터 모듈 import — 통합 방식에 따라 한 줄만:
import ExelBidMediationAdMob    // SwiftPM (네트워크별 모듈)
// import ExelBidMediationAdapter  // CocoaPods (단일 모듈)

ExelBidMediationKit.shared.register(modules: [AdMobMediationModule.self])
MobileAds.shared.start(completionHandler: nil)  // AdMob 사용 시
```

> 모듈 타입명(`AdMobMediationModule` 등)과 등록 코드는 두 방식이 동일하며, `import` 줄만 다릅니다.

### 3단계 · 네트워크별 필수 설정

네트워크마다 앱에 추가로 넣어야 하는 식별자/설정이 다릅니다.

| 네트워크 | Android 필수 | iOS 필수 | 비고 |
|---|---|---|---|
| **AdMob** | `AndroidManifest.xml`에 `com.google.android.gms.ads.APPLICATION_ID` 메타데이터 ([설정](#android-프로젝트-설정)) | `Info.plist`에 `GADApplicationIdentifier`, `MobileAds.shared.start(...)`, 배포타깃 **14+** | 앱 ID는 AdMob 콘솔 발급(광고 단위 ID와 다름). 없으면 동작 안 함/크래시 |
| **FAN (Meta)** | 추가 식별자 없음 (AndroidX 필요) | 추가 식별자 없음 (`SKAdNetwork`·ATT 권장) | 앱 단위 ID 없이 **광고 단위(placement) ID**로 동작. 실기기 테스트는 Meta 테스트 디바이스 등록 필요 |
| **AdFit (Kakao)** | Kakao maven 저장소 ([1단계](#1단계--어댑터-연결--android)) | AdFit iOS SDK | 앱 단위 ID 없이 **광고 단위(client) ID**로 동작. 전면/비디오 미지원(배너·네이티브만) |

> 공통: 모든 네트워크의 실제 낙찰은 **ExelBid 콘솔 워터폴에 해당 네트워크 라인아이템이 등록**되어 있어야 발생합니다. 광고 단위 ID(placement/client ID 등)는 보통 콘솔 설정에 포함됩니다.

### 4단계 · 코드에서 사용

미디에이션 광고는 일반 광고와 **동일한 위젯/클래스에 `Mediated`가 붙은 버전**을 씁니다. Dart API는 iOS·Android 공통입니다.

공통 옵션:
- `perNetworkTimeout` — 네트워크당 타임아웃(초). 초과 시 다음 네트워크로 폴백.
- `onWinningNetwork` / `winningNetwork` — 낙찰(노출 성공)된 네트워크 이름.
- `onWaterfall` / `WaterfallEvent` — 워터폴 진행 추적(모든 미디에이션 광고 지원, [아래](#waterfallevent)).

**Mediated Banner**

```dart
ExelbidMediatedBannerAd(
  adUnitId: 'YOUR_AD_UNIT_ID',
  size: const Size(320, 50),
  perNetworkTimeout: 5,
  onWinningNetwork: (network) => print('낙찰: $network'),
  onWaterfall: (e) => print(e.format()),   // 예: "1/3 trying → exelbid"
  onLoad: () => print('loaded'),
  onFail: (e) => print('실패: ${e.message}'),
)
```

**Mediated Native** — 일반 네이티브와 **동일한 슬롯 위젯·스타일·`onData` API**에 `onWinningNetwork`·`onWaterfall`만 추가됩니다.

```dart
ExelbidMediatedNativeAdView(
  adUnitId: 'YOUR_AD_UNIT_ID',
  desiredAssets: const {NativeAsset.title, NativeAsset.main, NativeAsset.ctatext},
  perNetworkTimeout: 5,
  onWinningNetwork: (network) => print('낙찰: $network'),
  onWaterfall: (e) => print(e.format()),
  child: Column(children: [ /* 슬롯 위젯 배치 */ ]),
)
```

**Mediated Video / Interstitial** — `ExelbidVideoAd` · `ExelbidInterstitialAd`와 같은 `create/load/present/dispose` 패턴이며, 이벤트 데이터에 `winningNetwork`·`waterfall`이 추가됩니다.

```dart
final ad = await ExelbidMediatedVideoAd.create(
  adUnitId: 'YOUR_AD_UNIT_ID',
  perNetworkTimeout: 5,
);

ad.events.listen((data) {
  switch (data.event) {
    case MediatedVideoAdEvent.onWaterfall:
      print(data.waterfall?.format());
    case MediatedVideoAdEvent.onLoad:
      print('낙찰: ${data.winningNetwork}');
      ad.present();
    case MediatedVideoAdEvent.onDidDisappear:
      ad.dispose();
    default:
      break;
  }
});

await ad.load();
```

### WaterfallEvent

`onWaterfall` 콜백이 전달하는 sealed 클래스. `format()`으로 로그용 한 줄 문자열을 얻을 수 있어 워터폴 디버깅에 유용합니다.

| 타입 | 의미 | `format()` 예시 |
|---|---|---|
| `WaterfallFetching` | 워터폴 조회 시작 | `fetching…` |
| `WaterfallFetched` | 네트워크 목록 수신 | `fetched: [a, b]` |
| `WaterfallTrying` | 특정 네트워크 시도 | `1/3 trying → exelbid` |
| `WaterfallWon` | 낙찰 | `won: exelbid (120ms)` |
| `WaterfallLost` | 해당 네트워크 실패 | `lost: admob (adapterNotRegistered)` |
| `WaterfallNoFill` | 전체 실패 | `noFill — all networks failed` |

> 등록하지 않은 네트워크가 `lost: ... (adapterNotRegistered)`로 보이면, 해당 네트워크의 SDK 추가 + 모듈 등록이 빠진 것입니다([1단계](#1단계--어댑터-연결--android)/[2단계](#2단계--어댑터-연결--ios)).

---

## 에러 처리

`onFail` 콜백/`onFail` 이벤트로 전달되는 `AdError`는 sealed 클래스라 `switch`로 타입 분기할 수 있습니다.

```dart
onFail: (error) {
  final msg = switch (error) {
    InvalidAdUnitIdError() => '잘못된 광고 단위 ID',
    NoFillError() => '노출할 광고 없음',
    NetworkAdError() => '네트워크 오류',
    HttpStatusAdError(:final statusCode) => 'HTTP $statusCode',
    NotReadyAdError() => '아직 준비되지 않음',
    CanceledAdError() => '취소됨',
    _ => error.message,
  };
  print(msg);
}
```

| 타입 | 상황 |
|---|---|
| `InvalidAdUnitIdError` | 광고 단위 ID 오류 |
| `NoFillError` | 노출 가능한 광고 없음 |
| `NetworkAdError` | 네트워크 통신 실패 |
| `HttpStatusAdError` | HTTP 오류 (`statusCode` 포함) |
| `DecodingAdError` | 응답 파싱 실패 |
| `VastParsingAdError` | VAST 파싱 실패 (비디오) |
| `MediaFileUnavailableError` | 미디어 파일 없음 (비디오) |
| `PlaybackAdError` | 재생 오류 (비디오) |
| `NotReadyAdError` | 준비 전 `present()` 호출 |
| `CanceledAdError` | 취소됨 |
| `UnknownAdError` | 기타 (`code` 포함) |

---

## 공통 API · API 요약

`Exelbid` 정적 클래스로 전역 정보/ATT를 다룹니다.

```dart
final version = await Exelbid.sdkVersion;                    // 네이티브 SDK 버전
final status = await Exelbid.trackingAuthorizationStatus;    // ATT 상태 조회 (프롬프트 없음)
final result = await Exelbid.requestTrackingAuthorization(); // ATT 프롬프트 요청
```

`TrackingAuthorizationStatus`: `notDetermined` · `restricted` · `denied` · `authorized`

| 클래스 / 위젯 | 용도 |
|---|---|
| `Exelbid` | 전역 (SDK 버전, ATT) |
| `ExelbidBannerAd` / `ExelbidBannerController` | 임베디드 배너 (+ 수동 제어) |
| `ExelbidNativeAdView` + `ExelbidNativeAd*` 슬롯 | 호스트 렌더링 네이티브 |
| `ExelbidNativeSlotStyle` / `ExelbidNativeAdData` | 네이티브 슬롯 스타일 / 자산 값(`onData`) |
| `ExelbidVideoAd` / `ExelbidInterstitialAd` | 전면 비디오 / 전면 광고 |
| `ExelbidMediatedBannerAd` / `…NativeAdView` / `…VideoAd` / `…InterstitialAd` | 미디에이션 광고 |
| `AdOptions` / `AdLocation` / `Gender` | 타깃팅 옵션 |
| `AdError` (sealed) | 에러 타입 |
| `WaterfallEvent` (sealed) | 미디에이션 워터폴 추적 |
| `NativeAsset` / `TrackingAuthorizationStatus` | 네이티브 자산 종류 / ATT 상태 |

전체 동작 예시는 [`example/`](example/) 앱을 참고하세요. Home / Ads / Mediation 탭에서 각 광고 유형을 실행해 볼 수 있습니다.

---

## 부록: Android AdMob 전면/비디오 노치 채우기 (선택)

> 선택 사항입니다. AdMob 전면·비디오 광고는 Google Mobile Ads SDK가 자체 액티비티(`com.google.android.gms.ads.AdActivity`)에서 렌더링하며, 기본적으로 상단 **상태바/노치(디스플레이 컷아웃)** 영역을 비워 둡니다. 이 영역까지 광고로 채우고 싶다면 **호스트 앱**에서 해당 액티비티의 테마를 덮어쓸 수 있습니다(플러그인이 대신 설정할 수 없는 호스트 영역입니다).

`AdActivity`는 GMA SDK가 선언하므로, 호스트 앱의 `AndroidManifest.xml`에서 `tools:replace`로 테마만 교체합니다.

`android/app/src/main/res/values/styles.xml`:

```xml
<style name="AdCutoutTheme" parent="@android:style/Theme.Translucent.NoTitleBar.Fullscreen">
    <item name="android:windowLayoutInDisplayCutoutMode">shortEdges</item>
    <item name="android:windowFullscreen">true</item>
</style>
```

`android/app/src/main/AndroidManifest.xml` (`<manifest>`에 `xmlns:tools="http://schemas.android.com/tools"` 추가):

```xml
<application ...>
    <activity
        android:name="com.google.android.gms.ads.AdActivity"
        android:theme="@style/AdCutoutTheme"
        tools:replace="android:theme" />
</application>
```

- `windowFullscreen` → 상태바를 숨겨 광고가 상단까지 확장됩니다.
- `windowLayoutInDisplayCutoutMode = shortEdges` → 컷아웃(노치/펀치홀) 영역까지 진입합니다(**API 28+**, 하위는 무시). `always`(API 30+)는 더 넓게 채웁니다.

> GMA SDK 버전/기기에 따라 SDK가 런타임에 인셋을 직접 적용해 위 테마가 무시될 수 있습니다. 그 경우 **GMA SDK 업그레이드**가 근본 해법입니다. 적용 후 광고 표시/닫기 버튼 위치를 실기기에서 확인하세요.

---

## 라이선스

[LICENSE](LICENSE) 참조.
