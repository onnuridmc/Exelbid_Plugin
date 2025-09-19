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
const String METHOD_SET_MAIN_VIDEO_VIEW = "setMainVideoView";
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
  final int? timer;
  final bool? coppa;
  final bool? isTest;
  final EBViewStyle? styles;

  final EBPNativeAdViewListener? listener;

  const EBNativeAdView({
    super.key,
    required this.child,
    required this.adUnitId,
    this.nativeAssets,
    this.timer,
    this.coppa,
    this.isTest,
    this.listener,
    this.styles,
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
  GlobalKey? _mainVideoKey;
  GlobalKey? _iconImageKey;
  GlobalKey? _callToActionKey;
  GlobalKey? _privacyInformationIconImageKey;

  EBNativeData? nativeData;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _methodChannel?.setMethodCallHandler(null);
    _methodChannel = null;

    _titleKey = null;
    _descriptionKey = null;
    _mainImageKey = null;
    _mainVideoKey = null;
    _iconImageKey = null;
    _callToActionKey = null;
    _privacyInformationIconImageKey = null;

    super.dispose();
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
      "timer": widget.timer,
      "coppa": widget.coppa,
      "is_test": widget.isTest,
      "styles": widget.styles?.toMap()
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
        debugPrint('No MethodChannel : $method');
      }
    } catch (e) {
      debugPrint('Error MethodChannel ${call.method} : $e');
    }
  }

  void updateViews() {
    updateView(_titleKey, METHOD_SET_TITLE_VIEW);
    updateView(_descriptionKey, METHOD_SET_DESCRIPTION_VIEW);
    updateView(_mainImageKey, METHOD_SET_MAIN_IMAGE_VIEW);
    updateView(_mainVideoKey, METHOD_SET_MAIN_VIDEO_VIEW);
    updateView(_iconImageKey, METHOD_SET_ICON_IMAGE_VIEW);
    updateView(_callToActionKey, METHOD_SET_CALL_TO_ACTION_VIEW);
    updateView(_privacyInformationIconImageKey,
        METHOD_SET_PRIVACY_INFORMATION_ICON_IMAGE_VIEW);
  }

  void updateView(GlobalKey? key, String method) {
    if (key == null || _methodChannel == null) return;

    final state = key.currentState as EBNativeAdBaseState?;
    if (state == null) return;

    Rect rect = _getViewFrame(state.rectKey);

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

    EBBaseStyle? baseStyle = state.widget.baseStyle;

    if (baseStyle != null) {
      params["styles"] = baseStyle.toMap();
    }

    _methodChannel?.invokeMethod(method, params);
  }

  Rect _getViewFrame(GlobalKey target) {
    RenderBox? renderBox =
        target.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox == null) return Rect.zero;
    Offset globalOffset = renderBox.localToGlobal(Offset.zero);
    RenderBox nativeRenderBox =
        _nativeAdKey.currentContext?.findRenderObject() as RenderBox;
    Offset nativeOffset = nativeRenderBox.globalToLocal(globalOffset);
    return nativeOffset & renderBox.size;
  }
}

abstract class EBNativeAdBaseWidget extends StatefulWidget {
  final EBBaseStyle? baseStyle;

  const EBNativeAdBaseWidget({super.key, this.baseStyle});
}

abstract class EBNativeAdBaseState<T extends EBNativeAdBaseWidget>
    extends State<T> {
  GlobalKey rectKey = GlobalKey();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context);
}

class EBNativeAdTitle extends EBNativeAdBaseWidget {
  EBNativeAdTitle({
    Key? key,
    EBTextStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdTitle> createState() => EBNativeAdTitleState();
}

class EBNativeAdTitleState extends EBNativeAdBaseState<EBNativeAdTitle> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._titleKey = widget.key as GlobalKey;

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
        key: rectKey,
        style: TextStyle(
          color: Colors.transparent,
          fontSize: widget.baseStyle?.fontSize,
          fontWeight: widget.baseStyle?.fontWeight,
        ),
      )),
    );
  }
}

class EBNativeAdDescription extends EBNativeAdBaseWidget {
  EBNativeAdDescription({
    Key? key,
    EBTextStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdDescription> createState() =>
      EBNativeAdDescriptionState();
}

class EBNativeAdDescriptionState
    extends EBNativeAdBaseState<EBNativeAdDescription> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._descriptionKey = widget.key as GlobalKey;

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
          key: rectKey,
          style: TextStyle(
            color: Colors.transparent,
            fontSize: widget.baseStyle?.fontSize,
            fontWeight: widget.baseStyle?.fontWeight,
          ),
        ),
      ),
    );
  }
}

class EBNativeAdMainImage extends EBNativeAdBaseWidget {
  final double? width;
  final double? height;

  EBNativeAdMainImage({
    Key? key,
    this.width = double.infinity,
    this.height = double.infinity,
    EBImageStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdMainImage> createState() =>
      EBNativeAdMainImageState();
}

class EBNativeAdMainImageState
    extends EBNativeAdBaseState<EBNativeAdMainImage> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._mainImageKey = widget.key as GlobalKey;

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
        child: SizedBox(
          key: rectKey,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

class EBNativeAdMainVideo extends EBNativeAdBaseWidget {
  final double? width;
  final double? height;

  EBNativeAdMainVideo({
    Key? key,
    this.width = double.infinity,
    this.height = double.infinity,
    EBImageStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdMainVideo> createState() =>
      EBNativeAdMainVideoState();
}

class EBNativeAdMainVideoState
    extends EBNativeAdBaseState<EBNativeAdMainVideo> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._mainVideoKey = widget.key as GlobalKey;

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (SizeChangedLayoutNotification notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          EBNativeState.of(context).updateView(
              EBNativeState.of(context)._mainVideoKey,
              METHOD_SET_MAIN_VIDEO_VIEW);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox(
          key: rectKey,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

class EBNativeAdIconImage extends EBNativeAdBaseWidget {
  final double? width;
  final double? height;

  EBNativeAdIconImage({
    Key? key,
    this.width = double.infinity,
    this.height = double.infinity,
    EBImageStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdIconImage> createState() =>
      EBNativeAdIconImageState();
}

class EBNativeAdIconImageState
    extends EBNativeAdBaseState<EBNativeAdIconImage> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._iconImageKey = widget.key as GlobalKey;

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
          key: rectKey,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}

class EBNativeAdCallToAction extends EBNativeAdBaseWidget {
  EBNativeAdCallToAction({
    Key? key,
    EBButtonStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdCallToAction> createState() =>
      EBNativeAdCallToActionState();
}

class EBNativeAdCallToActionState
    extends EBNativeAdBaseState<EBNativeAdCallToAction> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._callToActionKey = widget.key as GlobalKey;

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
          key: rectKey,
          onPressed: () {},
          child: Text(
            EBNativeState.of(context).nativeData?.callToAction ?? "",
            style: TextStyle(
              color: Colors.transparent,
              fontSize: widget.baseStyle?.fontSize,
              fontWeight: widget.baseStyle?.fontWeight,
            ),
          ),
        ),
      ),
    );
  }
}

class EBNativeAdPrivacyInformationIconImage extends EBNativeAdBaseWidget {
  final double? width;
  final double? height;

  EBNativeAdPrivacyInformationIconImage({
    Key? key,
    this.width = double.infinity,
    this.height = double.infinity,
    EBImageStyle? styles,
  }) : super(
          key: key ?? GlobalKey(),
          baseStyle: styles,
        );

  @override
  EBNativeAdBaseState<EBNativeAdPrivacyInformationIconImage> createState() =>
      EBNativeAdPrivacyInformationIconImageState();
}

class EBNativeAdPrivacyInformationIconImageState
    extends EBNativeAdBaseState<EBNativeAdPrivacyInformationIconImage> {
  @override
  Widget build(BuildContext context) {
    EBNativeState.of(context)._privacyInformationIconImageKey =
        widget.key as GlobalKey;

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
        child: SizedBox(
          key: rectKey,
          width: widget.width,
          height: widget.height,
        ),
      ),
    );
  }
}
