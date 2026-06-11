import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';
import '../models/waterfall_event.dart';

enum MediatedInterstitialAdEvent {
  onLoad,
  onFail,
  onWaterfall,
  onWillAppear,
  onDidAppear,
  onWillDisappear,
  onDidDisappear,
  onClick,
  onLeaveApp,
  onClickFinish,
}

class MediatedInterstitialAdEventData {
  const MediatedInterstitialAdEventData(
    this.event, {
    this.error,
    this.winningNetwork,
    this.waterfall,
  });

  final MediatedInterstitialAdEvent event;
  final AdError? error;
  final String? winningNetwork;
  final WaterfallEvent? waterfall;
}

/// 미디에이션 전면 전체화면 광고. `load()` → `present()`의 2단계, 일회성으로
/// 사용한다. 워터폴 진행 상황과 낙찰 네트워크를 보고한다.
class ExelbidMediatedInterstitialAd {
  ExelbidMediatedInterstitialAd._(this._id)
      : _methodChannel =
            MethodChannel('com.exelbid/flutter/mediated_interstitial/$_id'),
        _eventChannel = EventChannel(
            'com.exelbid/flutter/mediated_interstitial/$_id/events');

  static const _globalChannel = MethodChannel('com.exelbid/flutter');

  final String _id;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<MediatedInterstitialAdEventData>? _events;
  bool _disposed = false;

  static Future<ExelbidMediatedInterstitialAd> create({
    required String adUnitId,
    AdOptions? options,
    double? perNetworkTimeout,
  }) async {
    final id = _generateId();
    await _globalChannel.invokeMethod<void>('mediatedInterstitial.create', {
      'id': id,
      'adUnitId': adUnitId,
      'options': options?.toMap(),
      if (perNetworkTimeout != null) 'perNetworkTimeout': perNetworkTimeout,
    });
    return ExelbidMediatedInterstitialAd._(id);
  }

  Stream<MediatedInterstitialAdEventData> get events {
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
      throw StateError(
          'ExelbidMediatedInterstitialAd($_id) has already been disposed.');
    }
  }

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  MediatedInterstitialAdEventData _parse(Object? raw) {
    final map = (raw as Map).cast<Object?, Object?>();
    final name = map['event'] as String?;
    switch (name) {
      case 'onLoad':
        return MediatedInterstitialAdEventData(
          MediatedInterstitialAdEvent.onLoad,
          winningNetwork: map['winningNetwork'] as String?,
        );
      case 'onFail':
        final err = map['error'];
        return MediatedInterstitialAdEventData(
          MediatedInterstitialAdEvent.onFail,
          error: err is Map ? AdError.fromMap(err.cast<Object?, Object?>()) : null,
        );
      case 'onWaterfall':
        final wf = map['waterfall'];
        return MediatedInterstitialAdEventData(
          MediatedInterstitialAdEvent.onWaterfall,
          waterfall: wf is Map
              ? WaterfallEvent.fromMap(wf.cast<Object?, Object?>())
              : null,
        );
      case 'onWillAppear':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onWillAppear);
      case 'onDidAppear':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onDidAppear);
      case 'onWillDisappear':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onWillDisappear);
      case 'onDidDisappear':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onDidDisappear);
      case 'onClick':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onClick);
      case 'onLeaveApp':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onLeaveApp);
      case 'onClickFinish':
        return const MediatedInterstitialAdEventData(
            MediatedInterstitialAdEvent.onClickFinish);
      default:
        throw StateError('Unknown MediatedInterstitialAd event: $name');
    }
  }
}
