import 'package:exelbid_plugin/ad_listener.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class EBBannerAdView extends StatefulWidget {
  final String adUnitId;

  final bool? isFullWebView;
  final bool? coppa;
  final String? yob;
  final bool? gender;
  final Map<String, dynamic>? keywords;
  final bool? isTest;

  final EBPBannerAdViewListener? listener;

  const EBBannerAdView(
      {super.key,
      required this.adUnitId,
      this.isFullWebView,
      this.coppa,
      this.yob,
      this.gender,
      this.keywords,
      this.isTest,
      this.listener});

  /// @nodoc
  @override
  State<EBBannerAdView> createState() => EBBannerAdViewState();
}

class EBBannerAdViewState extends State<EBBannerAdView> {
  final String viewType = "exelbid_plugin/banner_ad";
  MethodChannel? methodChannel;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: viewType,
        creationParams: createParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: createParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }

    return Container();
  }

  Map<String, dynamic> createParams() {
    return {
      "ad_unit_id": widget.adUnitId,
      "is_full_web_view": widget.isFullWebView,
      "coppa": widget.coppa,
      "yob": widget.yob,
      "gender": widget.gender,
      "keywords": widget.keywords,
      "is_test": widget.isTest
    };
  }

  void onPlatformViewCreated(int id) {
    methodChannel = MethodChannel('${viewType}_$id');
    methodChannel?.setMethodCallHandler(handleMethodChannel);
  }

  Future<void> handleMethodChannel(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      if ("onLoadAd" == method) {
        widget.listener?.onLoadAd();
      } else if ("onFailAd" == method) {
        final errorMessage = arguments?['error_message'] as String?;
        widget.listener?.onFailAd(errorMessage);
      } else if ("onClickAd" == method) {
        widget.listener?.onClickAd?.call();
      } else {
        throw MissingPluginException('No MethodChannel : $method');
      }
    } catch (e) {
      debugPrint('Error MethodChannel ${call.method} (${call.arguments}) : $e');
    }
  }
}
