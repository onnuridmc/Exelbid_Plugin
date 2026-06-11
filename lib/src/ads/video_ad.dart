import 'dart:async';
import 'dart:math';

import 'package:flutter/services.dart';

import '../models/ad_error.dart';
import '../models/ad_options.dart';

enum VideoAdEvent {
  onLoad,
  onFail,
  onProgress,
  onWillAppear,
  onDidAppear,
  onWillDisappear,
  onDidDisappear,
  onClick,
  onLeaveApp,
}

class VideoAdEventData {
  const VideoAdEventData(this.event, {this.error, this.percent});

  final VideoAdEvent event;
  final AdError? error;
  final int? percent;
}

class ExelbidVideoAd {
  ExelbidVideoAd._(this._id)
      : _methodChannel = MethodChannel('com.exelbid/flutter/video/$_id'),
        _eventChannel = EventChannel('com.exelbid/flutter/video/$_id/events');

  static const _globalChannel = MethodChannel('com.exelbid/flutter');

  final String _id;
  final MethodChannel _methodChannel;
  final EventChannel _eventChannel;

  Stream<VideoAdEventData>? _events;
  bool _disposed = false;

  static Future<ExelbidVideoAd> create({
    required String adUnitId,
    AdOptions? options,
  }) async {
    final id = _generateId();
    await _globalChannel.invokeMethod<void>('video.create', {
      'id': id,
      'adUnitId': adUnitId,
      'options': options?.toMap(),
    });
    return ExelbidVideoAd._(id);
  }

  Stream<VideoAdEventData> get events {
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

  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    await _methodChannel.invokeMethod<void>('dispose');
  }

  void _ensureAlive() {
    if (_disposed) {
      throw StateError('ExelbidVideoAd($_id) has already been disposed.');
    }
  }

  static String _generateId() {
    final rand = Random.secure();
    final bytes = List<int>.generate(16, (_) => rand.nextInt(256));
    return bytes
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join();
  }

  VideoAdEventData _parse(Object? raw) {
    final map = (raw as Map).cast<Object?, Object?>();
    final name = map['event'] as String?;
    switch (name) {
      case 'onLoad':
        return const VideoAdEventData(VideoAdEvent.onLoad);
      case 'onFail':
        final err = map['error'];
        return VideoAdEventData(
          VideoAdEvent.onFail,
          error: err is Map
              ? AdError.fromMap(err.cast<Object?, Object?>())
              : null,
        );
      case 'onProgress':
        return VideoAdEventData(
          VideoAdEvent.onProgress,
          percent: map['percent'] as int?,
        );
      case 'onWillAppear':
        return const VideoAdEventData(VideoAdEvent.onWillAppear);
      case 'onDidAppear':
        return const VideoAdEventData(VideoAdEvent.onDidAppear);
      case 'onWillDisappear':
        return const VideoAdEventData(VideoAdEvent.onWillDisappear);
      case 'onDidDisappear':
        return const VideoAdEventData(VideoAdEvent.onDidDisappear);
      case 'onClick':
        return const VideoAdEventData(VideoAdEvent.onClick);
      case 'onLeaveApp':
        return const VideoAdEventData(VideoAdEvent.onLeaveApp);
      default:
        throw StateError('Unknown VideoAd event: $name');
    }
  }
}
