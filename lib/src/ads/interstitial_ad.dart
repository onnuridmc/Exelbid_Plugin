import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';

enum InterstitialAdEvent {
  onLoad,
  onFail,
  onWillAppear,
  onDidAppear,
  onWillDisappear,
  onDidDisappear,
  onClick,
  onLeaveApp,
  onClickFinish,
}

class InterstitialAdEventData {
  const InterstitialAdEventData(this.event, {this.error});

  final InterstitialAdEvent event;
  final AdError? error;
}

class ExelbidInterstitialAd {
  ExelbidInterstitialAd._(this._id)
      : _methodChannel = MethodChannel('com.exelbid/flutter/interstitial/$_id'),
        _eventChannel =
            EventChannel('com.exelbid/flutter/interstitial/$_id/events');

  static const _globalChannel = MethodChannel('com.exelbid/flutter');

  final String _id;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<InterstitialAdEventData>? _events;
  bool _disposed = false;

  static Future<ExelbidInterstitialAd> create({
    required String adUnitId,
    AdOptions? options,
    bool fullWebView = false,
  }) async {
    final id = _generateId();
    await _globalChannel.invokeMethod<void>('interstitial.create', {
      'id': id,
      'adUnitId': adUnitId,
      'options': options?.toMap(),
      'fullWebView': fullWebView,
    });
    return ExelbidInterstitialAd._(id);
  }

  Stream<InterstitialAdEventData> get events {
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
          'ExelbidInterstitialAd($_id) has already been disposed.');
    }
  }

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  InterstitialAdEventData _parse(Object? raw) {
    final map = (raw as Map).cast<Object?, Object?>();
    final name = map['event'] as String?;
    switch (name) {
      case 'onLoad':
        return const InterstitialAdEventData(InterstitialAdEvent.onLoad);
      case 'onFail':
        final err = map['error'];
        return InterstitialAdEventData(
          InterstitialAdEvent.onFail,
          error: err is Map
              ? AdError.fromMap(err.cast<Object?, Object?>())
              : null,
        );
      case 'onWillAppear':
        return const InterstitialAdEventData(InterstitialAdEvent.onWillAppear);
      case 'onDidAppear':
        return const InterstitialAdEventData(InterstitialAdEvent.onDidAppear);
      case 'onWillDisappear':
        return const InterstitialAdEventData(
            InterstitialAdEvent.onWillDisappear);
      case 'onDidDisappear':
        return const InterstitialAdEventData(
            InterstitialAdEvent.onDidDisappear);
      case 'onClick':
        return const InterstitialAdEventData(InterstitialAdEvent.onClick);
      case 'onLeaveApp':
        return const InterstitialAdEventData(InterstitialAdEvent.onLeaveApp);
      case 'onClickFinish':
        return const InterstitialAdEventData(
            InterstitialAdEvent.onClickFinish);
      default:
        throw StateError('Unknown InterstitialAd event: $name');
    }
  }
}
