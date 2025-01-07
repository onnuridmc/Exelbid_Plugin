# Exelbid SDK for Flutter
Flutter Plugin 가이드입니다.  

목차
==========

- Version History
- Plugin 정보
- SDK 정보
- 시작하기
    - Flutter Plugin 추가하기
- 광고 적용하기
    - 인스턴스 공통 메소드
    - 배너 광고
    - 전면 광고

# Version History

## Version 1.0.0

- 1.0.0 Initial

# 시작하기 전에

- Exelbid에서는 광고 요청에 대한 응답 후 노출까지의 시간(노출 캐시 시간)을 30분 이내로 권장합니다.(IAB 권장)
- 광고 응답 이후 노출 시간 차이가 해당 시간보다 길어지면 광고 캠페인에 따라서 노출이 무효 처리될 수 있습니다.

# Plugin 정보

Flutter 1.0.0 버전

# SDK 정보
OS별 SDK 정보는 아래 링크를 참고해주세요.  

- [Android SDK 정보](https://github.com/onnuridmc/ExelBid-Android-SDK?tab=readme-ov-file#%EB%B9%8C%EB%93%9C-api-%EC%88%98%EC%A4%80)  
- [iOS SDK 정보](https://github.com/onnuridmc/ExelBid_iOS_Swift?tab=readme-ov-file#sdk-%EC%A0%95%EB%B3%B4)

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

# 광고 적용하기

1. Exelbid 계정을 생성합니다.
2. Inventory -> App -> Create New App
   ![new app](./img/inventory_app.png)

3. Inventory -> Unit -> Create New Unit
   ![new app](./img/inventory_unit.png)

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

## 배너 광고

### 배너 광고 인스턴스

|Key|Type|Default|Desc|
|---|---|---|---|
|isFullWebView|bool?|true|광고 안에 너비 100%로 웹뷰가 바인딩되게 설정.|

```
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
```
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

## 전면 광고

### 전면 광고 콜백 리스너 설정
```
ExelbidPlugin.shared.setInterstitialListener(EBPInterstitialAdViewListener(
    onLoadAd: () {
        print("Interstitial onLoadAd");
    }, onFailAd: (String? errorMessage) {
        print("Interstitial onFailAd");
    }, onClickAd: () {
        print("onInterstitialClick");
    }, onInterstitialShow: () {
        print("onInterstitialShow");
    }, onInterstitialDismiss: () {
        print("onInterstitialDismiss"); 
    })
);
```

### 전면 광고 초기화
```
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
```
ExelbidPlugin.shared.loadInterstitial(adUnitId: "<<Ad Unit Id>>", yob: "2014", gender: true);
```

### 전면 광고 보기
전면 광고 초기화가 이루어진 후 광고 보기를 요청해야 합니다.  
```
ExelbidPlugin.shared.showInterstitial();
```
