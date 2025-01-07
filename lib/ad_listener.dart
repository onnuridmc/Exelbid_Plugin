abstract class EBPAdListener {
  /// 광고 요청 성공
  final Function() onLoadAd;

  /// 광고 요청 실패
  final Function(String? errorMessage) onFailAd;

  /// 광고 클릭
  final Function()? onClickAd;

  const EBPAdListener(
      {required this.onLoadAd, required this.onFailAd, this.onClickAd});
}

/// 배너 광고 콜백 리스너
class EBPBannerAdViewListener extends EBPAdListener {
  const EBPBannerAdViewListener(
      {required super.onLoadAd, required super.onFailAd, super.onClickAd});
}

/// 전면 광고 콜백 리스너
class EBPInterstitialAdViewListener extends EBPAdListener {
  /// 전면 광고가 화면에 표시된 후에 전송됩니다.
  final Function()? onInterstitialShow;

  /// 전면 광고가 화면에서 해제 된 후 전송됩니다.
  final Function()? onInterstitialDismiss;

  const EBPInterstitialAdViewListener(
      {required super.onLoadAd,
      required super.onFailAd,
      super.onClickAd,
      this.onInterstitialShow,
      this.onInterstitialDismiss});
}
