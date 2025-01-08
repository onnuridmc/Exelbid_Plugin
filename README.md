# Exelbid SDK for Flutter
Flutter Plugin 가이드입니다.  

목차
==========

- [Version History](#version-history)
- [Plugin 정보](#plugin-정보)
- [SDK 정보](#sdk-정보)
- [시작하기](#시작하기)
    - [Flutter Plugin 추가하기](#flutter-plugin-추가하기)
    - [Android 설정](#android-설정)
    - [iOS 설정](#ios-설정)
- [광고 적용하기](#광고-적용하기)
    - [인스턴스 공통 메소드](#인스턴스-공통-메소드)
    - [배너 광고](#배너-광고)
    - [전면 광고](#전면-광고)

# Version History
### Version 1.0.0

- 1.0.0 Initial

<br/><br/>

# 시작하기 전에

- Exelbid에서는 광고 요청에 대한 응답 후 노출까지의 시간(노출 캐시 시간)을 30분 이내로 권장합니다.(IAB 권장)
- 광고 응답 이후 노출 시간 차이가 해당 시간보다 길어지면 광고 캠페인에 따라서 노출이 무효 처리될 수 있습니다.

<br/><br/>

# Plugin 정보

Flutter 1.0.0 버전

<br/><br/>

# SDK 정보
SDK 정보는 아래 링크를 참고해주세요.  

- [Android SDK 정보](https://github.com/onnuridmc/ExelBid-Android-SDK?tab=readme-ov-file#%EB%B9%8C%EB%93%9C-api-%EC%88%98%EC%A4%80)  
- [iOS SDK 정보](https://github.com/onnuridmc/ExelBid_iOS_Swift?tab=readme-ov-file#sdk-%EC%A0%95%EB%B3%B4)

<br/><br/>

# 시작하기

## Flutter Plugin 추가하기

### 명령어를 이용한 설치
다음 명령어로 종속성 추가 및 설치하세요.
```
flutter pub add exelbid_plugin
```

### 수동으로 설치
`pubspec.yaml` 파일에 종속성 설정을 해주세요.  
```
dependencies:
  exelbid_plugin: any
```

종속성 설정 후 다음 명령어로 설치하세요.  
```
flutter pub get
```

<br/>

## Android 설정

### Google Library 추가하기

1. Flutter 프로젝트에서 android/app/src/main/AndroidManifest.xml 파일을 엽니다.  
2. 아래 내용을 추가하세요.  

```xml
<meta-data
    android:name="com.google.android.gms.version"
    android:value="@integer/google_play_services_version" />
```

<br/>

### 프로가드 설정
```
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient{public *;}
-keep class com.google.android.gms.ads.identifier.AdvertisingIdClient$Info{public *;}
-keep class com.google.android.gms.common.api.GoogleApiClient { public *; }
-keep class com.google.android.gms.common.api.GoogleApiClient$* {public *;}
-keep class com.google.android.gms.location.LocationServices {public *;}
-keep class com.google.android.gms.location.FusedLocationProviderApi {public *;}

-keepattributes SourceFile,LineNumberTable,InnerClasses
-keep class com.onnuridmc.exelbid.** { *; }
```

<br/>

### AndroidManifest 설정

#### Activity 설정
```xml
<!-- 필수 -->
<activity android:name="com.onnuridmc.exelbid.common.ExelbidBrowser"
    android:configChanges="keyboardHidden|orientation|screenSize">
</activity>
<!-- 필수(전면 광고시) -->
<activity android:name="com.onnuridmc.exelbid.common.ExelBidActivity"
    android:configChanges="keyboardHidden|orientation|screenSize">
</activity>
```

#### 권한 설정

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />

// 구글 정책(2022.03.15 발표)에 따라 대상 API 수준을 32(Android 13)로 업데이트하는 앱은 다음과 같이 매니페스트 파일에서 Google Play 서비스 일반 권한을 선언해야 합니다.(정책 적용 2022년 말 예정)
<uses-permission android:name="com.google.android.gms.permission.AD_ID"/>
```

#### 권장 권한
```xml
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
<uses-permission android:name="android.permission.CHANGE_WIFI_STATE" />
```

#### HTTP 트래픽 허용 설정

Exelbid에서는 광고 요청등의 Api에 https를 사용하지만 Exelbid에 연결된 많은 광고주 플랫폼사들의 광고 소재 리소스(image, js등)의 원할한 활용을 위해 http사용 허가 설정이 필요합니다.

1. Flutter 프로젝트에서 android/app/src/main/res/xml/network_security_config.xml 파일을 생성 또는 열기.
2. 아래 내용을 추가하세요.  

```xml
<?xml version="1.0" encoding="utf-8"?>
    <network-security-config>
        <base-config cleartextTrafficPermitted="true" />
    </network-security-config>
```

1. Flutter 프로젝트에서 android/app/src/main/AndroidManifest.xml 파일을 엽니다.  
2. 아래 내용을 추가하세요.  

```xml
<application
    .
    .
    android:networkSecurityConfig="@xml/network_security_config"
    android:usesCleartextTraffic="true">
```

<br/>

## iOS 설정

### Info 설정
광고 식별자 및 HTTP 트래픽 허용을 위한 권한을 설정합니다.  

Exelbid에서는 광고 요청등의 Api에 https를 사용하지만 Exelbid에 연결된 많은 광고주 플랫폼사들의 광고 소재 리소스(image, js등)의 원할한 활용을 위해 http사용 허가 설정이 필요합니다.  

1. Flutter 프로젝트에서 ios/Runner/Info.plist 파일을 엽니다.  
2. 아래 내용을 추가하세요.  
```plist
<key>NSUserTrackingUsageDescription</key>
<string>이 앱은 사용자 맞춤 광고를 제공하기 위해 광고 식별자를 사용합니다.</string>

<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```
<br/>

### 광고식별자 권한 요청
사용자로부터 개인정보 보호에 관한 권한을 요청해야 합니다.  
앱 설치 후 한번만 요청되며, 사용자가 권한에 대해 응답 후 더 이상 사용자에게 권한 요청을 하지 않습니다.  
광고식별자를 수집하지 못하는 경우 광고 요청에 대해 응답이 실패할 수 있습니다.  

**※ 광고를 호출하기 전에 완료되어야 합니다.**  
**※ 앱이 실행될때 광고식별자 권한 요청을 권장합니다.**

1. Flutter 프로젝트에서 ios/Runner/AppDelegate.swift 파일을 엽니다.
2. 아래 내용을 추가하세요.  
```swift
import AppTrackingTransparency

...

func applicationDidBecomeActive(_ application: UIApplication) {
    if #available(iOS 14.0, *) {
        ATTrackingManager.requestTrackingAuthorization { _ in }
    }
} 
```

<br/><br/>

# 광고 적용하기

1. Exelbid 계정을 생성합니다.
2. Inventory -> App -> Create New App
   ![new app](./img/inventory_app.png)

3. Inventory -> Unit -> Create New Unit
   ![new app](./img/inventory_unit.png)

<br/>

## 인스턴스 공통 메소드
광고의 효율을 높이기 위해 나이, 성별을 설정하는 것이 좋습니다.

|Key|Type|Default|Desc|
|---|---|---|---|
|adUnitId|String||광고 아이디를 셋팅 합니다.|
|yob|String?|null|태어난 연도 4자리(2016)|
|gender|bool?|null|성별 (true : 남자, false : 여자)|
|keywords|Map<String, String>?|null|Custom 메타 데이터 (Key, Value)|
|isTest|bool?|false|광고의 테스트를 위해 설정하는 값입니다. 통계에 적용 되지 않으며 항상 광고가 노출되게 됩니다.|
|coppa|bool?|false|선택사항으로 미국 아동 온라인 사생활 보호법에 따라 13세 미만의 사용자를 설정하면 개인 정보를 제한하여 광고 입찰 처리됩니다. (IP, Device ID, Geo 정보등)|
|rewarded|bool?|false|지면의 리워드 여부를 설정한다.|
|listener|EBPAdListener?|null|콜백 이벤트 리스너.|


<br/>

## 배너 광고

### 배너 광고 인스턴스

|Key|Type|Default|Desc|
|---|---|---|---|
|isFullWebView|bool?|true|광고 안에 너비 100%로 웹뷰가 바인딩되게 설정.|

<br/>

```dart
EBBannerAdView({super.key,
                required this.adUnitId,
                this.isFullWebView,
                this.coppa,
                this.yob,
                this.gender,
                this.keywords,
                this.isTest,
                this.listener});
```

#### 예시)
```dart
EBBannerAdView(
    adUnitId: "<<Ad Unit Id>>",
    yob: "2014",
    gender: true,
    listener: EBPBannerAdViewListener(
        onLoadAd: () {
            print("Banner onLoadAd");
        }, onFailAd: (String? errorMessage) {
            print("Banner onFailAd");
        }, onClickAd: () {
            print("Banner onClickAd");
        }
    )
)
```

<br/>

### 배너 광고 이벤트 리스너
```dart
EBPBannerAdViewListener {
    /// 광고 요청 성공
    final Function() onLoadAd;

    /// 광고 요청 실패
    final Function(String? errorMessage) onFailAd;

    /// 광고 클릭
    final Function()? onClickAd;
}
```

<br/><br/>

## 전면 광고

### 배너 광고 이벤트 리스너
```dart
EBPInterstitialAdViewListener {
    /// 광고 요청 성공
    final Function() onLoadAd;

    /// 광고 요청 실패
    final Function(String? errorMessage) onFailAd;

    /// 광고 클릭
    final Function()? onClickAd;

    /// 전면 광고가 화면에 표시된 후에 전송됩니다.
    final Function()? onInterstitialShow;

    /// 전면 광고가 화면에서 해제 된 후 전송됩니다.
    final Function()? onInterstitialDismiss;
}
```

<br/>

### 전면 광고 콜백 리스너 설정
```dart
ExelbidPlugin.shared.setInterstitialListener(EBPInterstitialAdViewListener(
    onLoadAd: () {
        print("Interstitial onLoadAd");
    }, onFailAd: (String? errorMessage) {
        print("Interstitial onFailAd");
    }, onClickAd: () {
        print("Interstitial onClickAd");
    }, onInterstitialShow: () {
        print("onInterstitialShow");
    }, onInterstitialDismiss: () {
        print("onInterstitialDismiss"); 
    })
);
```

<br/>

### 전면 광고 초기화
```dart
Future<void> loadInterstitial({
    required String adUnitId,
    bool? coppa,
    String? yob,
    bool? gender,
    Map<String, dynamic>? keywords,
    bool? isTest,
  })
```

#### 예시)
```dart
ExelbidPlugin.shared.loadInterstitial(adUnitId: "<<Ad Unit Id>>", yob: "2014", gender: true);
```

<br/>

### 전면 광고 보기
전면 광고 초기화가 이루어진 후 광고 보기를 요청해야 합니다.  
```dart
ExelbidPlugin.shared.showInterstitial();
```
