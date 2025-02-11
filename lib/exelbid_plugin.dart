import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/ad_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class ExelbidPlugin {
  static final ExelbidPlugin shared = ExelbidPlugin._internal();

  late MethodChannel _channel;

  ExelbidPlugin._internal() {
    _channel = const MethodChannel('exelbid_plugin');
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  EBPInterstitialAdViewListener? _interstitialListener;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      final methodHandlers = {
        "onInterstitialLoadAd": () => _interstitialListener?.onLoadAd(),
        "onInterstitialFailAd": () => _interstitialListener
            ?.onFailAd(arguments?['error_message'] as String?),
        "onInterstitialShow": () =>
            _interstitialListener?.onInterstitialShow?.call(),
        "onInterstitialDismiss": () =>
            _interstitialListener?.onInterstitialDismiss?.call(),
        "onInterstitialClickAd": () => _interstitialListener?.onClickAd?.call(),
      };

      final handler = methodHandlers[method];
      if (handler != null) {
        handler();
      } else {
        throw MissingPluginException('No handler for method $method');
      }
    } catch (e) {
      print(
          'Error handling native method call ${call.method} with arguments ${call.arguments}: $e');
    }
  }

  Future<void> loadInterstitial({
    required String adUnitId,
    bool? coppa,
    bool? isTest,
  }) async {
    try {
      await _channel.invokeMethod('loadInterstitial', {
        'ad_unit_id': adUnitId,
        'coppa': coppa,
        'is_test': isTest,
      });
    } on PlatformException catch (e) {
      print("Failed to call method: '${e.message}'.");
    }
  }

  void showInterstitial() async {
    await _channel.invokeMethod('showInterstitial');
  }

  void setInterstitialListener(EBPInterstitialAdViewListener? listener) {
    _interstitialListener = listener;
  }

  void callInvokeMethod(String method, Map<dynamic, dynamic> arguments) async {
    await _channel.invokeMethod(method, arguments);
  }

  Future<ATTStatus> requestTrackingAuthorization() async {
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      int status = await _channel.invokeMethod("requestTrackingAuthorization");
      return status.toATTStatus();
    }

    return ATTStatus.Authorized;
  }
}
