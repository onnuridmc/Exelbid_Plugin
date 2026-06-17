import 'package:flutter/foundation.dart';

/// 데모 앱에서 사용하는 ExelBid 광고 단위 ID를 한곳에서 설정하는 클래스.
///
/// ExelBid는 **플랫폼마다 서로 다른 광고 단위 ID**를 발급하므로, 각 포맷은 앱이
/// 실행 중인 플랫폼에 따라 iOS 또는 Android 값으로 결정된다.
/// 각 값을 해당 플랫폼 + 포맷에 대해 ExelBid 콘솔에서 발급받은 광고 단위 ID로
/// 교체하면 된다. 모든 예제 화면은 여기에서 광고 단위 ID를 읽어온다
/// (현재 일반 화면과 미디에이션 화면은 동일한 ID를 공유한다).
class AdUnitIds {
  AdUnitIds._();

  /// 배너 광고 (320x50).
  static String get banner => _pick(
    ios: '08377f76c8b3e46c4ed36c82e434da2b394a4dfa',
    android: 'd9a9293958c6cd0189c01de18fcf1d02839befe9',
  );

  /// 네이티브 광고.
  static String get native => _pick(
    ios: '5792d262715cbd399d6910200437b40a95dcc0f6',
    android: 'd7b20997ed5f925e617c33a5b198bdce6fcf04b0',
  );

  /// 비디오.
  static String get video => _pick(
    ios: '3f548c41c3c6539ee7051aeb58ada2d4c039bc07',
    android: 'c73ca366de62a253f847b737c78a4b905d8825de',
  );

  /// 전면 광고 단위.
  static String get interstitial => _pick(
    ios: '615217b82a648b795040baee8bc81986a71d0eb7',
    android: '94ed378f4b99783cf9ff15e1f428bd2250191cc4',
  );

  /// 앱이 실행 중인 플랫폼에 맞는 값을 선택한다.
  static String _pick({required String ios, required String android}) =>
      defaultTargetPlatform == TargetPlatform.android ? android : ios;
}
