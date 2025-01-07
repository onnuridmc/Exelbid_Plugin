import 'package:exelbid_plugin/ad_listener.dart';
import 'package:flutter/services.dart';

typedef MethodCallHandler = Future<dynamic> Function(MethodCall call);

class ExelbidPlugin {
  static final ExelbidPlugin shared = ExelbidPlugin._internal();

  MethodChannel? _channel;

  ExelbidPlugin._internal() {
    _channel = const MethodChannel('exelbid_plugin');
    _channel?.setMethodCallHandler(_handleMethodCall);
  }

  EBPInterstitialAdViewListener? _interstitialListener;

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      final methodHandlers = {
        "onLoadAd": () => _interstitialListener?.onLoadAd(),
        "onFailAd": () {
          final errorMessage = arguments?['error_message'] as String?;
          _interstitialListener?.onFailAd(errorMessage);
        },
        "onInterstitialShow": () =>
            _interstitialListener?.onInterstitialShow?.call(),
        "onInterstitialDismiss": () =>
            _interstitialListener?.onInterstitialDismiss?.call(),
        "onClickAd": () => _interstitialListener?.onClickAd?.call()
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
    String? yob,
    bool? gender,
    Map<String, dynamic>? keywords,
    bool? isTest,
  }) async {
    try {
      await _channel?.invokeMethod('loadInterstitial', {
        'ad_unit_id': adUnitId,
        'coppa': coppa,
        'yob': yob,
        'gender': gender,
        'keywords': keywords,
        'is_test': isTest,
      });
    } on PlatformException catch (e) {
      print("Failed to call method: '${e.message}'.");
    }
  }

  Future<void> showInterstitial() async {
    await _channel?.invokeMethod('showInterstitial');
  }

  void setInterstitialListener(EBPInterstitialAdViewListener? listener) {
    _interstitialListener = listener;
  }
}
