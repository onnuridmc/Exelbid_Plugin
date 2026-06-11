/// iOS 14+의 `ATTrackingManager.AuthorizationStatus`를 따른다.
/// 구버전 iOS 또는 iOS가 아닌 플랫폼에서는 ATT가 존재하기 전까지 IDFA가 항상
/// 사용 가능했으므로 플러그인이 [authorized]를 반환한다.
enum TrackingAuthorizationStatus {
  notDetermined(0),
  restricted(1),
  denied(2),
  authorized(3);

  const TrackingAuthorizationStatus(this.rawValue);

  final int rawValue;

  static TrackingAuthorizationStatus fromRaw(int raw) {
    return switch (raw) {
      1 => TrackingAuthorizationStatus.restricted,
      2 => TrackingAuthorizationStatus.denied,
      3 => TrackingAuthorizationStatus.authorized,
      _ => TrackingAuthorizationStatus.notDetermined,
    };
  }
}
