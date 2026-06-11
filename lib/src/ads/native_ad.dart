import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';
import '../models/native_ad_data.dart';
import '../models/native_asset.dart';
import '../models/native_slot_style.dart';
import '../models/waterfall_event.dart';

const _viewType = 'com.exelbid/flutter/native';
const _mediatedViewType = 'com.exelbid/flutter/mediated_native';

const _methodSetTitle = 'setTitleView';
const _methodSetDescription = 'setDescriptionView';
const _methodSetMedia = 'setMediaView';
const _methodSetIcon = 'setIconImageView';
const _methodSetCallToAction = 'setCallToActionView';
const _methodSetSponsored = 'setSponsoredView';
const _methodSetDisplayUrl = 'setDisplayUrlView';
const _methodSetLogo = 'setLogoImageView';
const _methodSetPrivacyIcon = 'setPrivacyInformationIconImage';

/// 호스트가 렌더링하는 네이티브 광고 컨테이너.
///
/// 호스트 앱이 [child]를 통해 레이아웃을 그린다. 각 슬롯 위젯
/// ([ExelbidNativeAdTitle], [ExelbidNativeAdMedia] 등)은 SDK가 해당
/// 에셋을 렌더링할 영역을 표시한다. 플러그인은 각 슬롯의 프레임을 측정해
/// iOS/Android 네이티브 렌더링 뷰로 전달한다.
class ExelbidNativeAdView extends StatefulWidget {
  const ExelbidNativeAdView({
    required this.adUnitId,
    required this.child,
    this.desiredAssets = const <NativeAsset>{},
    this.options,
    this.onLoad,
    this.onFail,
    this.onImpression,
    this.onImpression50,
    this.onImpression100,
    this.onClick,
    this.onLeaveApp,
    this.onClickFinish,
    this.onData,
    super.key,
  })  : viewType = _viewType,
        perNetworkTimeout = null,
        onWinningNetwork = null,
        onWaterfall = null;

  /// 미디에이션 변형과 공유하는 내부 생성자. 동일한 슬롯/측정 메커니즘으로
  /// 다른 플랫폼 뷰를 구동할 수 있게 한다.
  const ExelbidNativeAdView.internal({
    required this.adUnitId,
    required this.child,
    required this.viewType,
    this.desiredAssets = const <NativeAsset>{},
    this.options,
    this.perNetworkTimeout,
    this.onLoad,
    this.onFail,
    this.onImpression,
    this.onImpression50,
    this.onImpression100,
    this.onClick,
    this.onLeaveApp,
    this.onClickFinish,
    this.onWinningNetwork,
    this.onWaterfall,
    this.onData,
    super.key,
  });

  final String adUnitId;
  final Widget child;
  final Set<NativeAsset> desiredAssets;
  final AdOptions? options;

  /// 플랫폼 뷰 타입 — 표준 서피스는 `native`, 미디에이션 서피스는
  /// `mediated_native`.
  final String viewType;

  /// 네트워크별 워터폴 타임아웃(초). 미디에이션 서피스에서만 의미가 있다.
  final double? perNetworkTimeout;

  final VoidCallback? onLoad;
  final void Function(AdError error)? onFail;
  final VoidCallback? onImpression;
  final VoidCallback? onImpression50;
  final VoidCallback? onImpression100;
  final VoidCallback? onClick;
  final VoidCallback? onLeaveApp;
  final VoidCallback? onClickFinish;

  /// 로드 시 낙찰 네트워크 이름과 함께 호출된다(미디에이션 서피스 전용).
  final void Function(String network)? onWinningNetwork;

  /// 로드 중 각 워터폴 단계마다 호출된다(미디에이션 서피스 전용).
  final void Function(WaterfallEvent waterfall)? onWaterfall;

  /// 로드 시 광고의 에셋 값과 함께 호출된다. 렌더링 슬롯이 없는 데이터 전용
  /// 에셋(`secondaryBody`, `phone`, `rating`, …)에 유용하다.
  final void Function(ExelbidNativeAdData data)? onData;

  @override
  State<ExelbidNativeAdView> createState() => ExelbidNativeAdViewState();
}

class ExelbidNativeAdViewState extends State<ExelbidNativeAdView>
    with WidgetsBindingObserver {
  final GlobalKey _rootKey = GlobalKey();

  MethodChannel? _methodChannel;
  StreamSubscription<Object?>? _eventSub;

  /// 마운트된 슬롯 종류마다 하나의 바인딩. [_SlotKind]를 키로 사용한다.
  final Map<_SlotKind, _SlotBinding> _slots = <_SlotKind, _SlotBinding>{};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _eventSub?.cancel();
    _methodChannel = null;
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    _scheduleUpdate();
  }

  void _scheduleUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _updateAllSlots();
    });
  }

  void _onPlatformViewCreated(int viewId) {
    final viewType = widget.viewType;
    _methodChannel = MethodChannel('$viewType/$viewId');
    _eventSub = EventChannel('$viewType/$viewId/events')
        .receiveBroadcastStream()
        .listen(_dispatchEvent);
    _scheduleUpdate();
  }

  void _dispatchEvent(Object? event) {
    if (event is! Map) return;
    final name = event['event'] as String?;
    switch (name) {
      case 'onWaterfall':
        final wf = event['waterfall'];
        if (wf is Map) {
          widget.onWaterfall?.call(
              WaterfallEvent.fromMap(wf.cast<Object?, Object?>()));
        }
      case 'onLoad':
        final network = event['winningNetwork'] as String?;
        if (network != null) widget.onWinningNetwork?.call(network);
        final data = event['data'];
        if (data is Map) {
          widget.onData?.call(
              ExelbidNativeAdData.fromMap(data.cast<Object?, Object?>()));
        }
        _scheduleUpdate();
        widget.onLoad?.call();
      case 'onFail':
        final raw = event['error'];
        if (raw is Map) {
          widget.onFail?.call(AdError.fromMap(raw.cast<Object?, Object?>()));
        }
      case 'onImpression':
        widget.onImpression?.call();
      case 'onImpression50':
        widget.onImpression50?.call();
      case 'onImpression100':
        widget.onImpression100?.call();
      case 'onClick':
        widget.onClick?.call();
      case 'onLeaveApp':
        widget.onLeaveApp?.call();
      case 'onClickFinish':
        widget.onClickFinish?.call();
    }
  }

  /// 슬롯의 key와 style을 등록(또는 갱신)한다. 각 슬롯 위젯의 build에서
  /// 호출되므로, style이 변경되면 다시 빌드되어 다음 레이아웃에서 재전송된다.
  void _registerSlot(_SlotKind kind, GlobalKey key, ExelbidNativeSlotStyle? style) {
    _slots[kind] = _SlotBinding(key, _methodFor(kind), style);
  }

  void _updateAllSlots() {
    for (final kind in _slots.keys) {
      _updateSlot(kind);
    }
  }

  void _updateSlot(_SlotKind kind) {
    final channel = _methodChannel;
    final binding = _slots[kind];
    if (channel == null || binding == null) return;

    final rect = _measureSlot(binding.key);
    if (rect == null) return;

    channel.invokeMethod<void>(binding.method, <String, Object?>{
      'x': rect.left,
      'y': rect.top,
      'width': rect.width,
      'height': rect.height,
      if (binding.style != null) 'style': binding.style!.toMap(),
    });
  }

  static String _methodFor(_SlotKind kind) {
    switch (kind) {
      case _SlotKind.title:
        return _methodSetTitle;
      case _SlotKind.description:
        return _methodSetDescription;
      case _SlotKind.media:
        return _methodSetMedia;
      case _SlotKind.icon:
        return _methodSetIcon;
      case _SlotKind.callToAction:
        return _methodSetCallToAction;
      case _SlotKind.sponsored:
        return _methodSetSponsored;
      case _SlotKind.displayUrl:
        return _methodSetDisplayUrl;
      case _SlotKind.logo:
        return _methodSetLogo;
      case _SlotKind.privacyIcon:
        return _methodSetPrivacyIcon;
    }
  }

  Rect? _measureSlot(GlobalKey key) {
    final slotBox = key.currentContext?.findRenderObject() as RenderBox?;
    final rootBox = _rootKey.currentContext?.findRenderObject() as RenderBox?;
    if (slotBox == null || rootBox == null) return null;
    if (!slotBox.attached || !rootBox.attached) return null;

    final globalOffset = slotBox.localToGlobal(Offset.zero);
    final localOffset = rootBox.globalToLocal(globalOffset);
    return localOffset & slotBox.size;
  }

  Map<String, Object?> _creationParams() => {
        'adUnitId': widget.adUnitId,
        'desiredAssets':
            widget.desiredAssets.map((a) => a.rawValue).toList(growable: false),
        'options': widget.options?.toMap(),
        if (widget.perNetworkTimeout != null)
          'perNetworkTimeout': widget.perNetworkTimeout,
      };

  @override
  Widget build(BuildContext context) {
    return _ExelbidNativeAdScope(
      state: this,
      child: KeyedSubtree(
        key: _rootKey,
        child: Stack(
          children: [
            widget.child,
            if (defaultTargetPlatform == TargetPlatform.iOS)
              Positioned.fill(
                child: UiKitView(
                  viewType: widget.viewType,
                  creationParams: _creationParams(),
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                ),
              )
            // Android은 독립형 `native`와 `mediated_native` 서피스를 모두
            // 지원한다(두 팩토리 모두 플러그인이 등록함).
            else if (defaultTargetPlatform == TargetPlatform.android)
              Positioned.fill(
                child: AndroidView(
                  viewType: widget.viewType,
                  creationParams: _creationParams(),
                  creationParamsCodec: const StandardMessageCodec(),
                  onPlatformViewCreated: _onPlatformViewCreated,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExelbidNativeAdScope extends InheritedWidget {
  const _ExelbidNativeAdScope({
    required this.state,
    required super.child,
  });

  final ExelbidNativeAdViewState state;

  static ExelbidNativeAdViewState of(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<_ExelbidNativeAdScope>();
    assert(scope != null,
        'Slot widgets must be placed inside an ExelbidNativeAdView');
    return scope!.state;
  }

  @override
  bool updateShouldNotify(_ExelbidNativeAdScope oldWidget) =>
      state != oldWidget.state;
}

enum _SlotKind {
  title,
  description,
  media,
  icon,
  callToAction,
  sponsored,
  displayUrl,
  logo,
  privacyIcon,
}

/// 슬롯 종류를 측정 대상 key, 네이티브 메서드 이름, style에 바인딩한다.
class _SlotBinding {
  _SlotBinding(this.key, this.method, this.style);

  final GlobalKey key;
  final String method;
  final ExelbidNativeSlotStyle? style;
}

class _ExelbidNativeAdSlot extends StatefulWidget {
  const _ExelbidNativeAdSlot({
    required this.kind,
    this.width,
    this.height,
    this.style,
  });

  final _SlotKind kind;
  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  State<_ExelbidNativeAdSlot> createState() => _ExelbidNativeAdSlotState();
}

class _ExelbidNativeAdSlotState extends State<_ExelbidNativeAdSlot> {
  final GlobalKey _slotKey = GlobalKey();

  /// SDK가 에셋을 오버레이된 네이티브 `UILabel` 위에 텍스트로 그리는 슬롯들.
  /// Flutter 슬롯 자체는 빈 박스이므로 (네이티브) 텍스트에 맞춰 크기를 잡을 수
  /// 없다 — [_fallbackHeight] 참고.
  static const Set<_SlotKind> _textKinds = {
    _SlotKind.title,
    _SlotKind.description,
    _SlotKind.callToAction,
    _SlotKind.sponsored,
    _SlotKind.displayUrl,
  };

  /// 텍스트 슬롯의 style이 폰트 크기를 지정하지 않을 때 가정하는 기본 폰트
  /// 포인트 크기. 예약 높이가 SDK가 실제로 렌더링하는 값에 가깝게 유지되도록
  /// 플랫폼 `UILabel` 기본값을 따른다.
  static const double _defaultFontSize = 14;

  /// 폰트 포인트 크기를 한 줄의 박스 높이로 환산하는 배수.
  static const double _lineHeightFactor = 1.3;

  /// 호스트가 높이를 고정하지 않은 텍스트 슬롯에 예약할 높이.
  ///
  /// 텍스트 슬롯은 빈 플레이스홀더이며, SDK는 슬롯의 측정된 프레임 위에 놓인
  /// 네이티브 라벨에 에셋을 그린다. 명시적 높이가 없으면 박스가 0으로 무너져
  /// 네이티브 텍스트가 보이지 않으므로, style의 폰트 크기와 줄 수로부터
  /// 적절한 최소값을 도출한다. 이미지 슬롯(및 호스트가 크기를 지정한 슬롯)은
  /// `null`을 받아 자체 크기를 유지한다.
  double? get _fallbackHeight {
    if (widget.height != null) return widget.height;
    if (!_textKinds.contains(widget.kind)) return null;
    final fontSize = widget.style?.fontSize ?? _defaultFontSize;
    final maxLines = widget.style?.maxLines;
    // maxLines == 0은 "무제한"을 의미한다. 그래도 구체적인 최소값이 필요하므로
    // 한 줄을 예약하고 네이티브 라벨이 프레임 내에서 커지도록 둔다.
    final lines = (maxLines == null || maxLines <= 0) ? 1 : maxLines;
    final vPadding = widget.style?.padding?.vertical ?? 0;
    return (fontSize * _lineHeightFactor * lines + vPadding).ceilToDouble();
  }

  @override
  Widget build(BuildContext context) {
    final parent = _ExelbidNativeAdScope.of(context);
    parent._registerSlot(widget.kind, _slotKey, widget.style);

    return NotificationListener<SizeChangedLayoutNotification>(
      onNotification: (_) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          parent._updateSlot(widget.kind);
        });
        return false;
      },
      child: SizeChangedLayoutNotifier(
        child: SizedBox(
          key: _slotKey,
          width: widget.width,
          height: _fallbackHeight,
        ),
      ),
    );
  }
}

class ExelbidNativeAdTitle extends StatelessWidget {
  const ExelbidNativeAdTitle({this.style, super.key});

  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) =>
      _ExelbidNativeAdSlot(kind: _SlotKind.title, style: style);
}

class ExelbidNativeAdDescription extends StatelessWidget {
  const ExelbidNativeAdDescription({this.style, super.key});

  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) =>
      _ExelbidNativeAdSlot(kind: _SlotKind.description, style: style);
}

/// 광고의 **메인 크리에이티브** 슬롯 — 메인 이미지 또는 VAST 비디오를 담는
/// 단일 영역. SDK의 통합 미디어 슬롯(iOS `nativeMediaView()`)을 따른다.
/// 호스트는 빈 박스를 제공하고, SDK(인하우스) 또는 낙찰된 미디에이션
/// 네트워크(AdMob `MediaView` / FAN `MediaView` / AdFit 이미지)가 이를 채운다.
class ExelbidNativeAdMedia extends StatelessWidget {
  const ExelbidNativeAdMedia({
    this.width,
    this.height,
    this.style,
    super.key,
  });

  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) => _ExelbidNativeAdSlot(
        kind: _SlotKind.media,
        width: width,
        height: height,
        style: style,
      );
}

/// [ExelbidNativeAdMedia]의 사용 중단(deprecated) 별칭. 메인 이미지 슬롯과
/// 미디어 슬롯이 단일 미디어 슬롯으로 통합되었다(SDK 3.0.x의
/// `nativeMediaView()`를 따름). [ExelbidNativeAdMedia]를 사용하라.
@Deprecated('Renamed to ExelbidNativeAdMedia (unified media slot).')
class ExelbidNativeAdMainImage extends ExelbidNativeAdMedia {
  const ExelbidNativeAdMainImage({
    super.width,
    super.height,
    super.style,
    super.key,
  });
}

class ExelbidNativeAdIconImage extends StatelessWidget {
  const ExelbidNativeAdIconImage({
    this.width,
    this.height,
    this.style,
    super.key,
  });

  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) => _ExelbidNativeAdSlot(
        kind: _SlotKind.icon,
        width: width,
        height: height,
        style: style,
      );
}

class ExelbidNativeAdCallToAction extends StatelessWidget {
  const ExelbidNativeAdCallToAction({
    this.width,
    this.height,
    this.style,
    super.key,
  });

  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) => _ExelbidNativeAdSlot(
        kind: _SlotKind.callToAction,
        width: width,
        height: height,
        style: style,
      );
}

/// "Sponsored"/광고주 라벨 에셋([NativeAsset.sponsored]) 슬롯. SDK가 한 줄짜리
/// [UILabel]로 렌더링한다.
class ExelbidNativeAdSponsored extends StatelessWidget {
  const ExelbidNativeAdSponsored({this.style, super.key});

  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) =>
      _ExelbidNativeAdSlot(kind: _SlotKind.sponsored, style: style);
}

/// 표시 URL 에셋([NativeAsset.displayUrl]) 슬롯. SDK가 한 줄짜리 [UILabel]로
/// 렌더링한다.
class ExelbidNativeAdDisplayUrl extends StatelessWidget {
  const ExelbidNativeAdDisplayUrl({this.style, super.key});

  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) =>
      _ExelbidNativeAdSlot(kind: _SlotKind.displayUrl, style: style);
}

/// 로고 이미지 에셋([NativeAsset.logo]) 슬롯. SDK가 [UIImageView]로
/// 렌더링한다.
class ExelbidNativeAdLogo extends StatelessWidget {
  const ExelbidNativeAdLogo({
    this.width,
    this.height,
    this.style,
    super.key,
  });

  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) => _ExelbidNativeAdSlot(
        kind: _SlotKind.logo,
        width: width,
        height: height,
        style: style,
      );
}

class ExelbidNativeAdPrivacyIcon extends StatelessWidget {
  const ExelbidNativeAdPrivacyIcon({
    this.width,
    this.height,
    this.style,
    super.key,
  });

  final double? width;
  final double? height;
  final ExelbidNativeSlotStyle? style;

  @override
  Widget build(BuildContext context) => _ExelbidNativeAdSlot(
        kind: _SlotKind.privacyIcon,
        width: width,
        height: height,
        style: style,
      );
}

/// 미디에이션, 호스트 렌더링 네이티브 광고. [ExelbidNativeAdView]와 동일한
/// 슬롯 기반 레이아웃 API를 가진다 — [child] 안에서 동일한 `ExelbidNativeAd*`
/// 슬롯 위젯을 사용한다 — SDK의 미디에이션 워터폴로 구동된다. 각 워터폴
/// 단계는 [onWaterfall]로, 낙찰 네트워크는 [onWinningNetwork]로 보고한다.
class ExelbidMediatedNativeAdView extends StatelessWidget {
  const ExelbidMediatedNativeAdView({
    required this.adUnitId,
    required this.child,
    this.desiredAssets = const <NativeAsset>{},
    this.options,
    this.perNetworkTimeout,
    this.onLoad,
    this.onFail,
    this.onImpression,
    this.onImpression50,
    this.onImpression100,
    this.onClick,
    this.onLeaveApp,
    this.onClickFinish,
    this.onWinningNetwork,
    this.onWaterfall,
    this.onData,
    super.key,
  });

  final String adUnitId;
  final Widget child;
  final Set<NativeAsset> desiredAssets;
  final AdOptions? options;
  final double? perNetworkTimeout;

  final VoidCallback? onLoad;
  final void Function(AdError error)? onFail;
  final VoidCallback? onImpression;
  final VoidCallback? onImpression50;
  final VoidCallback? onImpression100;
  final VoidCallback? onClick;
  final VoidCallback? onLeaveApp;
  final VoidCallback? onClickFinish;
  final void Function(String network)? onWinningNetwork;

  /// 로드 중 각 워터폴 단계마다 호출된다.
  final void Function(WaterfallEvent waterfall)? onWaterfall;

  /// 로드 시 광고의 에셋 값(데이터 전용 에셋 포함)과 함께 호출된다.
  final void Function(ExelbidNativeAdData data)? onData;

  @override
  Widget build(BuildContext context) {
    return ExelbidNativeAdView.internal(
      adUnitId: adUnitId,
      viewType: _mediatedViewType,
      desiredAssets: desiredAssets,
      options: options,
      perNetworkTimeout: perNetworkTimeout,
      onLoad: onLoad,
      onFail: onFail,
      onImpression: onImpression,
      onImpression50: onImpression50,
      onImpression100: onImpression100,
      onClick: onClick,
      onLeaveApp: onLeaveApp,
      onClickFinish: onClickFinish,
      onWinningNetwork: onWinningNetwork,
      onWaterfall: onWaterfall,
      onData: onData,
      child: child,
    );
  }
}
