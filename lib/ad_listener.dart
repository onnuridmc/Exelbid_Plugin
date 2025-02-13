import 'package:exelbid_plugin/ad_classes.dart';

// 광고 리스너
abstract class EBPAdListener {
  // 광고 요청 성공
  final Function() onLoadAd;

  // 광고 요청 실패
  final Function(String? errorMessage) onFailAd;

  // 광고 클릭
  final Function()? onClickAd;

  const EBPAdListener(
      {required this.onLoadAd, required this.onFailAd, this.onClickAd});
}

// 배너 광고 콜백 리스너
class EBPBannerAdViewListener extends EBPAdListener {
  const EBPBannerAdViewListener(
      {required super.onLoadAd, required super.onFailAd, super.onClickAd});
}

// 전면 광고 콜백 리스너
class EBPInterstitialAdViewListener extends EBPAdListener {
  // 전면 광고가 화면에 표시된 후에 전송됩니다.
  final Function()? onInterstitialShow;

  // 전면 광고가 화면에서 해제 된 후 전송됩니다.
  final Function()? onInterstitialDismiss;

  const EBPInterstitialAdViewListener(
      {required super.onLoadAd,
      required super.onFailAd,
      super.onClickAd,
      this.onInterstitialShow,
      this.onInterstitialDismiss});
}

// 네이티브 광고 콜백 리스너
class EBPNativeAdViewListener extends EBPAdListener {
  const EBPNativeAdViewListener(
      {required super.onLoadAd, required super.onFailAd, super.onClickAd});
}

// 미디에이션 콜백 리스너
class EBPMediationListener {
  // 미디에이션 요청 성공
  final Function() onLoad;

  // 다음 순서 미디에이션 조회
  final Function(EBMediation mediation) onNext;

  // 미디에이션 목록이 비었을 경우 (순회 완료, 목록 없음)
  final Function() onEmpty;

  // 미디에이션 목록 조회 에러
  final Function(EBError error) onError;

  const EBPMediationListener(
      {required this.onLoad,
      required this.onNext,
      required this.onEmpty,
      required this.onError});
}
