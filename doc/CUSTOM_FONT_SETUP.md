# 커스텀 폰트 설정 가이드 (Android / iOS)

Exelbid Plugin의 Native Ad에서 `font_family`를 사용하려면 Flutter 앱에 폰트를 등록하는 것만으로는 부족합니다. 네이티브(Android/iOS) 레이어가 폰트를 직접 렌더링하기 때문에, **각 플랫폼에 폰트 파일을 추가하고 등록**해야 합니다.

---

## 예시 시나리오

아래 가이드에서는 다음과 같이 4가지 weight를 가진 `NanumGothic` 폰트를 등록한다고 가정합니다.

| 파일명 | Weight |
|--------|--------|
| `NanumGothic-Light.ttf` | 300 |
| `NanumGothic-Regular.ttf` | 400 |
| `NanumGothic-Bold.ttf` | 700 |
| `NanumGothic-ExtraBold.ttf` | 800 |

Dart 코드에서 사용:
```dart
EBTextStyle(
  fontFamily: 'nanum_gothic',  // Android: font family XML name
                               // iOS: PostScript family name
  fontWeight: FontWeight.w700,
  fontSize: 16,
  color: Colors.black,
)
```

---

# Android 설정

Android는 `res/font/` 디렉터리의 **font family XML**을 통해 여러 weight를 하나의 family로 묶어 관리합니다.

## Step 1. 폰트 파일 배치

프로젝트의 `android/app/src/main/res/font/` 디렉터리에 폰트 파일을 복사합니다.

> 파일명은 **소문자 + 언더스코어**만 허용됩니다 (Android 리소스 규칙).

```
android/app/src/main/
└── res/
    └── font/
        ├── nanum_gothic_light.ttf
        ├── nanum_gothic_regular.ttf
        ├── nanum_gothic_bold.ttf
        └── nanum_gothic_extra_bold.ttf
```

## Step 2. Font Family XML 생성

`res/font/nanum_gothic.xml` 파일을 생성합니다. 이 파일명(`nanum_gothic`)이 바로 Dart에서 `fontFamily`로 전달할 값입니다.

```xml
<?xml version="1.0" encoding="utf-8"?>
<font-family xmlns:app="http://schemas.android.com/apk/res-auto">
    <font
        app:fontStyle="normal"
        app:fontWeight="300"
        app:font="@font/nanum_gothic_light" />
    <font
        app:fontStyle="normal"
        app:fontWeight="400"
        app:font="@font/nanum_gothic_regular" />
    <font
        app:fontStyle="normal"
        app:fontWeight="700"
        app:font="@font/nanum_gothic_bold" />
    <font
        app:fontStyle="normal"
        app:fontWeight="800"
        app:font="@font/nanum_gothic_extra_bold" />
</font-family>
```

> `xmlns:app`을 사용하면 AppCompat 호환성이 확보되어 API 14+에서 동작합니다.

## Step 3. 파일 구조 확인

```
android/app/src/main/res/font/
├── nanum_gothic.xml                  # ← Dart에서 fontFamily로 사용
├── nanum_gothic_light.ttf
├── nanum_gothic_regular.ttf
├── nanum_gothic_bold.ttf
└── nanum_gothic_extra_bold.ttf
```

## Step 4. Dart에서 사용

```dart
EBNativeAdTitle(
  style: EBTextStyle(
    fontFamily: 'nanum_gothic',        // XML 파일명 (확장자 제외)
    fontWeight: FontWeight.w700,       // → "bold" → 700
    fontSize: 18,
  ),
)
```

## Weight 매핑 참고

| Dart `FontWeight` | 전달 문자열 | Android 적용 값 |
|--------|--------|--------|
| w100 | ultraLight | 100 |
| w200 | thin | 200 |
| w300 | light | 300 |
| w400 | regular | 400 |
| w500 | medium | 500 |
| w600 | semibold | 600 |
| w700 | bold | 700 |
| w800 | heavy | 800 |
| w900 | black | 900 |

> **API 28 (Android 9) 미만**: `Typeface`가 BOLD/NORMAL 두 가지만 지원하므로, 700 이상은 BOLD, 미만은 NORMAL로 fallback됩니다.

---

# iOS 설정

iOS는 폰트 파일을 **Xcode 프로젝트에 추가**하고 **Info.plist에 등록**하는 과정이 필요합니다.

## Step 1. 폰트 파일 배치

`ios/Runner/` 하위에 폰트 파일을 저장할 디렉터리를 만듭니다.

```
ios/Runner/
└── assets/
    └── fonts/
        └── nanum_gothic/
            ├── NanumGothic-Light.ttf
            ├── NanumGothic-Regular.ttf
            ├── NanumGothic-Bold.ttf
            └── NanumGothic-ExtraBold.ttf
```

> 파일명은 iOS에서 대소문자/하이픈 그대로 사용 가능합니다.

## Step 2. Xcode 프로젝트에 추가

1. Xcode로 `ios/Runner.xcworkspace`를 엽니다.
2. 왼쪽 Project Navigator에서 `Runner` 폴더를 우클릭 → **Add Files to "Runner"...**
3. Step 1에서 만든 `assets/fonts/nanum_gothic/` 폴더 선택
4. 다음 옵션을 **반드시** 체크:
   - ✅ **Copy items if needed** (이미 ios/ 내부라면 불필요)
   - ✅ **Create folder references** (파란색 폴더 아이콘)
   - ✅ **Add to targets: Runner**

## Step 3. Info.plist에 폰트 등록

`ios/Runner/Info.plist` 파일에 `UIAppFonts` 키를 추가합니다.

```xml
<key>UIAppFonts</key>
<array>
    <string>NanumGothic-Light.ttf</string>
    <string>NanumGothic-Regular.ttf</string>
    <string>NanumGothic-Bold.ttf</string>
    <string>NanumGothic-ExtraBold.ttf</string>
</array>
```

> 경로는 Xcode 프로젝트 내 **상대 경로**입니다.

## Step 4. Copy Bundle Resources 확인

Step 2에서 `Add to targets: Runner`를 체크했다면 Xcode가 자동으로 **Build Phases → Copy Bundle Resources**에 폰트 파일을 등록합니다. 다만 번들에 실제 포함되었는지 반드시 확인하는 것이 좋습니다.

### 확인 방법

1. Xcode 왼쪽 Project Navigator에서 **Runner 프로젝트 파일** 선택
2. 중앙 패널에서 **TARGETS → Runner** 선택
3. 상단 탭에서 **Build Phases** 선택
4. **Copy Bundle Resources** 섹션을 펼쳐 Step 1에서 추가한 폰트 파일들이 모두 목록에 있는지 확인

```
▼ Copy Bundle Resources (N items)
    NanumGothic-Light.ttf         in Runner
    NanumGothic-Regular.ttf       in Runner
    NanumGothic-Bold.ttf          in Runner
    NanumGothic-ExtraBold.ttf     in Runner
    ...
```

### 누락된 경우

- 하단의 **`+`** 버튼 → **Add Other...** → 누락된 폰트 파일 선택하여 추가
- 또는 Project Navigator에서 해당 폰트 파일 선택 → 오른쪽 **File Inspector** → **Target Membership**에서 `Runner` 체크박스 활성화


## Step 5. PostScript 이름 확인

iOS는 `font_family`에 **PostScript family name**을 전달해야 합니다. 파일명과 PostScript name이 다를 수 있으므로 반드시 확인이 필요합니다.

### 방법 1: macOS Font Book 앱
1. Finder에서 ttf 파일을 더블클릭
2. Font Book이 열리면 폰트를 선택
3. **i** (정보) 버튼 → `Family` 항목 확인

### 방법 2: 런타임 로그로 확인
`ios/Runner/AppDelegate.swift`에 임시 코드 추가:

```swift
for family in UIFont.familyNames.sorted() {
    print("Family: \(family)")
    for name in UIFont.fontNames(forFamilyName: family) {
        print("  - \(name)")
    }
}
```

앱 실행 후 콘솔에서 `NanumGothic` 항목을 찾습니다.

```
Family: NanumGothic
  - NanumGothic
  - NanumGothic-Bold
  - NanumGothic-ExtraBold
  - NanumGothic-Light
```

→ `font_family` 값으로 **`NanumGothic`** 사용

## Step 6. Dart에서 사용

```dart
EBNativeAdTitle(
  style: EBTextStyle(
    fontFamily: 'NanumGothic',         // iOS PostScript family name
    fontWeight: FontWeight.w700,
    fontSize: 18,
  ),
)
```

> iOS는 `UIFontDescriptor`로 family + weight를 조합하므로, Flutter에서 전달된 weight가 해당 family의 변형으로 매핑됩니다.

---

# 크로스 플랫폼 공통 처리

Android와 iOS에서 `font_family` 값이 다를 수 있으므로 분기 처리가 필요합니다.

```dart
import 'dart:io';

String get adFontFamily {
  if (Platform.isAndroid) return 'nanum_gothic';
  if (Platform.isIOS) return 'NanumGothic';
  return '';
}

// 사용
EBTextStyle(
  fontFamily: adFontFamily,
  fontWeight: FontWeight.w700,
  fontSize: 16,
)
```

---

# 트러블슈팅

## Android

| 증상 | 원인 | 해결 |
|------|------|------|
| 폰트가 적용되지 않음 | `res/font/` 경로가 아님 | `android/app/src/main/res/font/`에 배치 확인 |
| Build 에러: Invalid file name | 파일명에 대문자/하이픈 사용 | 모두 소문자 + 언더스코어로 변경 |
| Light/Medium 등이 안 먹음 | API 28 미만 기기 | `minSdk 28`로 올리거나, bold/normal로만 설계 |
| XML 파싱 에러 | `xmlns:app` 누락 | 루트 태그에 추가 |

## iOS

| 증상 | 원인 | 해결 |
|------|------|------|
| 폰트가 시스템 폰트로 표시됨 | PostScript name 오류 | Font Book 또는 런타임 로그로 정확한 이름 확인 |
| Info.plist 경로 오류 | 상대경로 불일치 | Xcode Project Navigator에서 폴더 구조 재확인 |
| 번들에 폰트 파일이 포함되지 않음 | Target Membership 미체크 | 파일 선택 → File Inspector → **Target Membership: Runner** 체크 |
| Font Book에서 열리지 않음 | 폰트 파일 손상 | 원본 ttf 재다운로드 |

---

# 참고: Flutter `pubspec.yaml` 등록은 필요한가?

**필요 없습니다.** `pubspec.yaml`의 `fonts:` 섹션은 **Flutter 위젯(`Text`)**에만 적용되며, 네이티브 광고 뷰에는 영향을 주지 않습니다.

단, Flutter UI에서도 같은 폰트를 쓰려면 `pubspec.yaml`에도 별도로 등록해야 합니다:

```yaml
flutter:
  fonts:
    - family: NanumGothic
      fonts:
        - asset: assets/fonts/NanumGothic-Regular.ttf
        - asset: assets/fonts/NanumGothic-Bold.ttf
          weight: 700
```

→ 결과적으로 **Android `res/font/`**, **iOS `UIAppFonts`**, **Flutter `pubspec.yaml`** 세 곳에 각각 등록해야 3개 레이어(Flutter UI / Android Native Ad / iOS Native Ad) 모두에서 동일 폰트를 사용할 수 있습니다.

---

# 참고: 폰트 파일 구조에 따른 제약

iOS는 `font_family` + `font_weight` 조합으로 폰트 변형을 선택하는 방식을 사용합니다. 이 방식은 폰트 파일이 **하나의 Family name 아래에 여러 weight 변형을 포함**하고, 각 변형이 올바른 `usWeightClass` 값을 가지고 있다는 전제에서 정상 동작합니다.

일부 폰트(특히 일부 한글 폰트 시리즈)는 weight 별로 **서로 다른 Family name**으로 배포되는 경우가 있습니다. 예를 들어 Regular/Bold는 `FontName` family로, ExtraBold/Light는 `FontNameExtraBold`, `FontNameLight`처럼 독립된 family로 분리되어 있는 구조입니다. 이런 경우 iOS에서 family + weight 조합으로는 의도한 변형이 선택되지 않을 수 있습니다.

폰트가 정상적으로 적용되지 않는다면:

1. **런타임 로그로 Family name 확인** — Step 4의 `UIFont.familyNames` 출력을 참고하여 실제로 등록된 family 구조를 파악합니다.
2. **weight 별로 다른 `fontFamily` 값 전달** — 필요한 경우 weight마다 다른 family name(또는 PostScript name)을 `fontFamily`로 전달하여 특정 변형을 직접 선택합니다.

Android는 `res/font/*.xml`에서 개발자가 파일과 weight를 직접 매핑하므로 이 문제의 영향을 받지 않습니다.
