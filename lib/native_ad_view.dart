import 'dart:async';

import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/ad_classes.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String EB_NATIVE_VIEW_TYPE = "exelbid_plugin/native_ad";

const String METHOD_SET_TITLE_VIEW = "setTitleView";
const String METHOD_SET_DESCRIPTION_VIEW = "setDescriptionView";
const String METHOD_SET_MAIN_IMAGE_VIEW = "setMainImageView";
const String METHOD_SET_ICON_IMAGE_VIEW = "setIconImageView";
const String METHOD_SET_CALL_TO_ACTION_VIEW = "setCallToActionView";
const String METHOD_SET_PRIVACY_INFORMATION_ICON_IMAGE_VIEW =
    "setPrivacyInformationIconImage";

class EBNativeState extends InheritedWidget {
  const EBNativeState({
    super.key,
    required EBNativeAdViewState nativeAdViewState,
    required super.child,
  }) : _state = nativeAdViewState;

  final EBNativeAdViewState _state;

  static EBNativeAdViewState of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<EBNativeState>()!._state;
  }

  @override
  bool updateShouldNotify(EBNativeState oldWidget) {
    return true;
  }
}

class EBNativeAdView extends StatefulWidget {
  final Widget child;
  final String adUnitId;
  final List<String>? nativeAssets;
  final bool? coppa;
  final bool? isTest;

  final EBPNativeAdViewListener? listener;

  const EBNativeAdView({
    super.key,
    required this.child,
    required this.adUnitId,
    this.nativeAssets,
    this.coppa,
    this.isTest,
    this.listener,
  });

  @override
  State<EBNativeAdView> createState() => EBNativeAdViewState();
}

class EBNativeAdViewState extends State<EBNativeAdView> {
  MethodChannel? _methodChannel;

  final GlobalKey _nativeAdKey = GlobalKey();
  GlobalKey? _titleKey;
  GlobalKey? _descriptionKey;
  GlobalKey? _mainImageKey;
  GlobalKey? _iconImageKey;
  GlobalKey? _callToActionKey;
  GlobalKey? _privacyInformationIconImageKey;

  EBNativeData? nativeData;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return EBNativeState(
        nativeAdViewState: this,
        child: SizedBox(
            key: _nativeAdKey,
            child: Stack(
              children: [
                LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return widget.child;
                  },
                ),
                if (defaultTargetPlatform == TargetPlatform.android)
                  AndroidView(
                    viewType: EB_NATIVE_VIEW_TYPE,
                    creationParams: createParams(),
                    creationParamsCodec: const StandardMessageCodec(),
                    onPlatformViewCreated: onPlatformViewCreated,
                  ),
                if (defaultTargetPlatform == TargetPlatform.iOS)
                  UiKitView(
                    viewType: EB_NATIVE_VIEW_TYPE,
                    creationParams: createParams(),
                    creationParamsCodec: const StandardMessageCodec(),
                    onPlatformViewCreated: onPlatformViewCreated,
                  )
              ],
            )));
  }

  Map<String, dynamic> createParams() {
    return {
      "ad_unit_id": widget.adUnitId,
      "native_assets": widget.nativeAssets,
      "coppa": widget.coppa,
      "is_test": widget.isTest
    };
  }

  void onPlatformViewCreated(int id) {
    _methodChannel = MethodChannel('${EB_NATIVE_VIEW_TYPE}_$id');
    _methodChannel?.setMethodCallHandler(handleMethodChannel);
    updateViews();
    _methodChannel?.invokeMethod("loadAd", createParams());
  }

  Future<void> handleMethodChannel(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      if ("onLoadAd" == method) {
        final result = arguments?['native_data'] as Map<dynamic, dynamic>?;
        if (result != null) {
          print(">>> handleMethodChannel onLoadAd : $result");
          setState(() {
            nativeData = EBNativeData.fromJson(result);
          });
        }

        updateViews();
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

  void updateViews() {
    updateView(_titleKey, METHOD_SET_TITLE_VIEW);
    updateView(_descriptionKey, METHOD_SET_DESCRIPTION_VIEW);
    updateView(_mainImageKey, METHOD_SET_MAIN_IMAGE_VIEW);
    updateView(_iconImageKey, METHOD_SET_ICON_IMAGE_VIEW);
    updateView(_callToActionKey, METHOD_SET_CALL_TO_ACTION_VIEW);
    updateView(_privacyInformationIconImageKey,
        METHOD_SET_PRIVACY_INFORMATION_ICON_IMAGE_VIEW);
  }

  void updateView(GlobalKey? key, String method) {
    if (key == null) return;
    Rect rect = getViewFrame(key);

    Map<String, dynamic> params;

    if (defaultTargetPlatform == TargetPlatform.android) {
      double devicePixelRatio = MediaQuery.of(context).devicePixelRatio;
      params = {
        'x': (rect.left * devicePixelRatio).round(),
        'y': (rect.top * devicePixelRatio).round(),
        'width': (rect.width * devicePixelRatio).round(),
        'height': (rect.height * devicePixelRatio).round(),
      };
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      params = {
        'x': rect.left,
        'y': rect.top,
        'width': rect.width,
        'height': rect.height,
      };
    } else {
      return;
    }

    _methodChannel?.invokeMethod(method, params);
  }

  Rect getViewFrame(GlobalKey key) {
    RenderBox? renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;
    Offset globalOffset = renderBox.localToGlobal(Offset.zero);
    RenderBox nativeRenderBox =
        _nativeAdKey.currentContext?.findRenderObject() as RenderBox;
    Offset nativeOffset = nativeRenderBox.globalToLocal(globalOffset);
    return nativeOffset & renderBox.size;
  }
}

class EBNativeAdTtitle extends StatelessWidget {
  final double? width;
  final double? height;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  const EBNativeAdTtitle(
      {super.key,
      this.width = double.infinity,
      this.height = double.infinity,
      this.style,
      this.textAlign,
      this.softWrap,
      this.overflow,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._titleKey =
        EBNativeState.of(context)._titleKey ?? GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._titleKey, METHOD_SET_TITLE_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Text(
          EBNativeState.of(context).nativeData?.title ?? '',
          key: EBNativeState.of(context)._titleKey,
          style: style,
          textAlign: textAlign,
          softWrap: softWrap,
          overflow: overflow,
          maxLines: maxLines,
        ),
      ),
    );
  }
}

class EBNativeAdDescription extends StatelessWidget {
  final double? width;
  final double? height;
  final TextStyle? style;
  final TextAlign? textAlign;
  final bool? softWrap;
  final TextOverflow? overflow;
  final int? maxLines;

  const EBNativeAdDescription(
      {super.key,
      this.width = double.infinity,
      this.height = double.infinity,
      this.style,
      this.textAlign,
      this.softWrap,
      this.overflow,
      this.maxLines});

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._descriptionKey =
        EBNativeState.of(context)._descriptionKey ?? GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._descriptionKey,
              METHOD_SET_DESCRIPTION_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Text(
          EBNativeState.of(context).nativeData?.description ?? '',
          key: EBNativeState.of(context)._descriptionKey,
        ),
      ),
    );
  }
}

class EBNativeAdMainImage extends StatelessWidget {
  final double? width;
  final double? height;

  const EBNativeAdMainImage({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._mainImageKey =
        EBNativeState.of(context)._mainImageKey ?? GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._mainImageKey,
              METHOD_SET_MAIN_IMAGE_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
            key: EBNativeState.of(context)._mainImageKey,
            width: width,
            height: height),
      ),
    );
  }
}

class EBNativeAdIconImage extends StatelessWidget {
  final double? width;
  final double? height;

  const EBNativeAdIconImage({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._iconImageKey =
        EBNativeState.of(context)._iconImageKey ?? GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._iconImageKey,
              METHOD_SET_ICON_IMAGE_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox(
            key: EBNativeState.of(context)._iconImageKey,
            width: width,
            height: height),
      ),
    );
  }
}

class EBNativeAdCallToAction extends StatelessWidget {
  final ButtonStyle? style;

  const EBNativeAdCallToAction({
    super.key,
    this.style,
  });

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._callToActionKey =
        EBNativeState.of(context)._callToActionKey ?? GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._callToActionKey,
              METHOD_SET_CALL_TO_ACTION_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: ElevatedButton(
          key: EBNativeState.of(context)._callToActionKey,
          style: style,
          onPressed: () {},
          child: Text(
            EBNativeState.of(context).nativeData?.callToAction ?? "",
          ),
        ),
      ),
    );
  }
}

class EBNativeAdPrivacyInformationIconImage extends StatelessWidget {
  final double? width;
  final double? height;

  const EBNativeAdPrivacyInformationIconImage({
    super.key,
    this.width = double.infinity,
    this.height = double.infinity,
  });

  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._privacyInformationIconImageKey =
        EBNativeState.of(context)._privacyInformationIconImageKey ??
            GlobalKey();

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._privacyInformationIconImageKey,
              METHOD_SET_PRIVACY_INFORMATION_ICON_IMAGE_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: Container(
            key: EBNativeState.of(context)._privacyInformationIconImageKey,
            width: width,
            height: height),
      ),
    );
  }
}
