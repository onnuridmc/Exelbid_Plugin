import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';
import '../models/waterfall_event.dart';

enum MediatedVideoAdEvent {
  onLoad,
  onFail,
  onProgress,
  onWaterfall,
  onWillAppear,
  onDidAppear,
  onWillDisappear,
  onDidDisappear,
  onClick,
  onLeaveApp,
}

class MediatedVideoAdEventData {
  const MediatedVideoAdEventData(
    this.event, {
    this.error,
    this.percent,
    this.winningNetwork,
    this.waterfall,
  });

  final MediatedVideoAdEvent event;
  final AdError? error;
  final int? percent;
  final String? winningNetwork;
  final WaterfallEvent? waterfall;
}

/// 미디에이션 전체화면 비디오. `load()` → `present()`의 2단계, 일회성으로
/// 사용한다. 표준 [ExelbidVideoAd] 생명주기에 더해 워터폴 진행 상황과
/// 낙찰 네트워크를 보고한다.
class ExelbidMediatedVideoAd {
  ExelbidMediatedVideoAd._(this._id)
      : _methodChannel =
            MethodChannel('com.exelbid/flutter/mediated_video/$_id'),
        _eventChannel =
            EventChannel('com.exelbid/flutter/mediated_video/$_id/events');

  static const _globalChannel = MethodChannel('com.exelbid/flutter');

  final String _id;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<MediatedVideoAdEventData>? _events;
  bool _disposed = false;

  static Future<ExelbidMediatedVideoAd> create({
    required String adUnitId,
    AdOptions? options,
    double? perNetworkTimeout,
  }) async {
    final id = _generateId();
    await _globalChannel.invokeMethod<void>('mediatedVideo.create', {
      'id': id,
      'adUnitId': adUnitId,
      'options': options?.toMap(),
      if (perNetworkTimeout != null) 'perNetworkTimeout': perNetworkTimeout,
    });
    return ExelbidMediatedVideoAd._(id);
  }

  Stream<MediatedVideoAdEventData> get events {
    _events ??= _eventChannel.receiveBroadcastStream().map(_parse);
    return _events!;
  }

  Future<void> load() {
    _ensureAlive();
    return _methodChannel.invokeMethod<void>('load');
  }

  Future<bool> get isReady async {
    _ensureAlive();
    final result = await _methodChannel.invokeMethod<bool>('isReady');
    return result ?? false;
  }

  Future<void> present() {
    _ensureAlive();
    return _methodChannel.invokeMethod<void>('present');
  }

  Future<void> stop() {
    _ensureAlive();
    return _methodChannel.invokeMethod<void>('stop');
  }

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _methodChannel.invokeMethod<void>('dispose');
  }

  void _ensureAlive() {
    if (_disposed) {
      throw StateError('ExelbidMediatedVideoAd($_id) has already been disposed.');
    }
  }

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  MediatedVideoAdEventData _parse(Object? raw) {
    final map = (raw as Map).cast<Object?, Object?>();
    final name = map['event'] as String?;
    switch (name) {
      case 'onLoad':
        return MediatedVideoAdEventData(
          MediatedVideoAdEvent.onLoad,
          winningNetwork: map['winningNetwork'] as String?,
        );
      case 'onFail':
        final err = map['error'];
        return MediatedVideoAdEventData(
          MediatedVideoAdEvent.onFail,
          error: err is Map ? AdError.fromMap(err.cast<Object?, Object?>()) : null,
        );
      case 'onProgress':
        return MediatedVideoAdEventData(
          MediatedVideoAdEvent.onProgress,
          percent: map['percent'] as int?,
        );
      case 'onWaterfall':
        final wf = map['waterfall'];
        return MediatedVideoAdEventData(
          MediatedVideoAdEvent.onWaterfall,
          waterfall: wf is Map
              ? WaterfallEvent.fromMap(wf.cast<Object?, Object?>())
              : null,
        );
      case 'onWillAppear':
        return const MediatedVideoAdEventData(MediatedVideoAdEvent.onWillAppear);
      case 'onDidAppear':
        return const MediatedVideoAdEventData(MediatedVideoAdEvent.onDidAppear);
      case 'onWillDisappear':
        return const MediatedVideoAdEventData(
            MediatedVideoAdEvent.onWillDisappear);
      case 'onDidDisappear':
        return const MediatedVideoAdEventData(
            MediatedVideoAdEvent.onDidDisappear);
      case 'onClick':
        return const MediatedVideoAdEventData(MediatedVideoAdEvent.onClick);
      case 'onLeaveApp':
        return const MediatedVideoAdEventData(MediatedVideoAdEvent.onLeaveApp);
      default:
        throw StateError('Unknown MediatedVideoAd event: $name');
    }
  }
}
