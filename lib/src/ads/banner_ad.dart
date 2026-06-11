import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';

const _viewType = 'com.exelbid/flutter/banner';

/// [ExelbidBannerAd]를 명령형으로 제어하는 핸들. 배너를 수동으로 제어하려면
/// [ExelbidBannerAd.controller]로 인스턴스를 전달한다:
///
/// * [load] — 광고를 요청(또는 재요청)한다. `autoLoad: false`와 함께 사용해
///   첫 요청을 지연시킬 수 있다(예: ATT가 결정될 때까지).
/// * [stop] — 진행 중인 요청을 취소하고 자동 갱신을 중단한다.
///
/// 컨트롤러는 기반 플랫폼 뷰가 생성되기 전까지는 동작하지 않으며, 그 이전에
/// 호출한 내용은 조용히 무시된다.
class ExelbidBannerController {
  MethodChannel? _channel;

  void _attach(MethodChannel channel) => _channel = channel;
  void _detach() => _channel = null;

  /// 컨트롤러가 활성 배너 뷰에 바인딩되어 있는지 여부.
  bool get isReady => _channel != null;

  /// 광고를 요청한다. 배너가 `autoLoad: false`로 생성된 경우 첫 로드를
  /// 트리거하며, 그렇지 않으면 새 요청을 강제로 수행한다.
  Future<void> load() async => _channel?.invokeMethod<void>('load');

  /// 현재 요청을 취소하고 자동 갱신을 중단한다.
  Future<void> stop() async => _channel?.invokeMethod<void>('stop');
}

class ExelbidBannerAd extends StatefulWidget {
  const ExelbidBannerAd({
    required this.adUnitId,
    required this.size,
    this.autoRefresh = true,
    this.autoLoad = true,
    this.fullWebView = false,
    this.controller,
    this.options,
    this.onLoad,
    this.onFail,
    this.onClick,
    this.onLeaveApp,
    this.onClickFinish,
    super.key,
  });

  final String adUnitId;
  final Size size;
  final bool autoRefresh;
  final bool autoLoad;

  /// `true`이면 크리에이티브가 선호 크기(서버에서 보고한 크기)에 맞춰지지 않고
  /// 배너 영역 전체를 채운다.
  final bool fullWebView;

  /// 수동 `load()` / `stop()` 제어를 위한 선택적 핸들.
  final ExelbidBannerController? controller;

  final AdOptions? options;

  final VoidCallback? onLoad;
  final void Function(AdError error)? onFail;
  final VoidCallback? onClick;
  final VoidCallback? onLeaveApp;
  final VoidCallback? onClickFinish;

  @override
  State<ExelbidBannerAd> createState() => _ExelbidBannerAdState();
}

class _ExelbidBannerAdState extends State<ExelbidBannerAd> {
  StreamSubscription<Object?>? _eventSub;
  MethodChannel? _methodChannel;

  @override
  void didUpdateWidget(ExelbidBannerAd oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.controller, widget.controller)) {
      oldWidget.controller?._detach();
      if (_methodChannel != null) widget.controller?._attach(_methodChannel!);
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    _eventSub?.cancel();
    super.dispose();
  }

  void _onPlatformViewCreated(int viewId) {
    _methodChannel = MethodChannel('com.exelbid/flutter/banner/$viewId');
    widget.controller?._attach(_methodChannel!);
    final channel = EventChannel('com.exelbid/flutter/banner/$viewId/events');
    _eventSub = channel.receiveBroadcastStream().listen(_dispatch);
  }

  void _dispatch(Object? event) {
    if (event is! Map) return;
    final name = event['event'] as String?;
    switch (name) {
      case 'onLoad':
        widget.onLoad?.call();
      case 'onFail':
        final raw = event['error'];
        if (raw is Map) {
          widget.onFail?.call(AdError.fromMap(raw.cast<Object?, Object?>()));
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
      'autoRefresh': widget.autoRefresh,
      'autoLoad': widget.autoLoad,
      'fullWebView': widget.fullWebView,
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
