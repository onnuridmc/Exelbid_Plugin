import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';
import '../models/waterfall_event.dart';

const _viewType = 'com.exelbid/flutter/mediated_banner';

/// 미디에이션 320×50 배너. 서버에서 정의한 워터폴 순서대로 각 네트워크를
/// 시도하고 가장 먼저 채워지는 광고를 표시한다. [ExelbidBannerAd]와 달리
/// `autoRefresh`가 없으며, 새 key로 다시 빌드하여 재로드한다.
class ExelbidMediatedBannerAd extends StatefulWidget {
  const ExelbidMediatedBannerAd({
    required this.adUnitId,
    required this.size,
    this.autoLoad = true,
    this.perNetworkTimeout,
    this.options,
    this.onLoad,
    this.onFail,
    this.onClick,
    this.onLeaveApp,
    this.onClickFinish,
    this.onWaterfall,
    this.onWinningNetwork,
    super.key,
  });

  final String adUnitId;
  final Size size;
  final bool autoLoad;

  /// 워터폴이 다음 네트워크로 넘어가기 전까지 각 네트워크에 대한 타임아웃(초).
  /// null이면 SDK 기본값을 사용한다.
  final double? perNetworkTimeout;
  final AdOptions? options;

  final VoidCallback? onLoad;
  final void Function(AdError error)? onFail;
  final VoidCallback? onClick;
  final VoidCallback? onLeaveApp;
  final VoidCallback? onClickFinish;
  final void Function(WaterfallEvent event)? onWaterfall;
  final void Function(String network)? onWinningNetwork;

  @override
  State<ExelbidMediatedBannerAd> createState() =>
      _ExelbidMediatedBannerAdState();
}

class _ExelbidMediatedBannerAdState extends State<ExelbidMediatedBannerAd> {
  StreamSubscription<Object?>? _eventSub;

  @override
  void dispose() {
    _eventSub?.cancel();
    super.dispose();
  }

  void _onPlatformViewCreated(int viewId) {
    final channel = EventChannel('$_viewType/$viewId/events');
    _eventSub = channel.receiveBroadcastStream().listen(_dispatch);
  }

  void _dispatch(Object? event) {
    if (event is! Map) return;
    final name = event['event'] as String?;
    switch (name) {
      case 'onLoad':
        final network = event['winningNetwork'] as String?;
        if (network != null) widget.onWinningNetwork?.call(network);
        widget.onLoad?.call();
      case 'onFail':
        final raw = event['error'];
        if (raw is Map) {
          widget.onFail?.call(AdError.fromMap(raw.cast<Object?, Object?>()));
        }
      case 'onWaterfall':
        final raw = event['waterfall'];
        if (raw is Map) {
          widget.onWaterfall
              ?.call(WaterfallEvent.fromMap(raw.cast<Object?, Object?>()));
        }
      case 'onClick':
        widget.onClick?.call();
      case 'onLeaveApp':
        widget.onLeaveApp?.call();
      case 'onClickFinish':
        widget.onClickFinish?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final params = <String, Object?>{
      'adUnitId': widget.adUnitId,
      'width': widget.size.width,
      'height': widget.size.height,
      'autoLoad': widget.autoLoad,
      if (widget.perNetworkTimeout != null)
        'perNetworkTimeout': widget.perNetworkTimeout,
      'options': widget.options?.toMap(),
    };

    return SizedBox(
      width: widget.size.width,
      height: widget.size.height,
      child: switch (defaultTargetPlatform) {
        TargetPlatform.iOS => UiKitView(
            viewType: _viewType,
            creationParams: params,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        TargetPlatform.android => AndroidView(
            viewType: _viewType,
            creationParams: params,
            creationParamsCodec: const StandardMessageCodec(),
            onPlatformViewCreated: _onPlatformViewCreated,
          ),
        _ => const SizedBox.shrink(),
      },
    );
  }
}
