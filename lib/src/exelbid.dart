import 'package:flutter/services.dart';

import 'models/log_level.dart';
import 'models/tracking_authorization_status.dart';

class Exelbid {
  Exelbid._();

  static const _channel = MethodChannel('com.exelbid/flutter');

  static Future<void> setLogLevel(LogLevel level) {
    return _channel.invokeMethod<void>('setLogLevel', {
      'level': level.rawValue,
    });
  }

  static Future<String> get sdkVersion async {
    final result = await _channel.invokeMethod<String>('getSdkVersion');
    return result ?? '';
  }

  /// 프롬프트를 띄우지 않고 현재 ATT 상태를 반환한다. iOS < 14 또는
  /// iOS가 아닌 플랫폼에서는 [TrackingAuthorizationStatus.authorized]를 반환한다.
  static Future<TrackingAuthorizationStatus>
      get trackingAuthorizationStatus async {
    final raw = await _channel.invokeMethod<int>('getTrackingAuthorizationStatus');
    return TrackingAuthorizationStatus.fromRaw(raw ?? 3);
  }

  /// 사용자에게 ATT 권한을 요청하고 그 결과 상태를 반환한다.
  /// 앱이 active 상태일 때 호출해야 한다(예: 첫 화면의 initState에서
  /// 첫 프레임 이후). iOS < 14에서는 시스템에 ATT 개념이 없으므로
  /// 즉시 [TrackingAuthorizationStatus.authorized]를 반환한다.
  static Future<TrackingAuthorizationStatus>
      requestTrackingAuthorization() async {
    final raw = await _channel.invokeMethod<int>('requestTrackingAuthorization');
    return TrackingAuthorizationStatus.fromRaw(raw ?? 3);
  }
}
