import 'dart:async';

import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../ad_unit_ids.dart';
import '../design/card.dart';
import '../design/primary_button.dart';
import '../design/tokens.dart';
import '../widgets/log_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/test_options_panel.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({super.key});

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();

  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';
  String _progressText = '-';

  ExelbidVideoAd? _ad;
  StreamSubscription<VideoAdEventData>? _eventSub;
  bool _canPresent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _options.dispose();
    _log.dispose();
    _eventSub?.cancel();
    _ad?.dispose();
    super.dispose();
  }

  void _set(AdStatus status, String text) {
    setState(() {
      _status = status;
      _statusText = text;
    });
    _log.append(text);
  }

  Future<void> _handleLoad() async {
    if (_isLoading) return;
    _set(AdStatus.loading, 'loading…');
    setState(() {
      _progressText = '-';
      _canPresent = false;
      _isLoading = true;
    });

    final options = _options.buildOptions(
      base: AdOptions(videoSkipMin: 10, videoSkipAfter: 5),
    );

    await _eventSub?.cancel();
    await _ad?.dispose();

    try {
      final ad = await ExelbidVideoAd.create(
        adUnitId: AdUnitIds.video,
        options: options,
      );
      _ad = ad;
      _eventSub = ad.events.listen(_onEvent);
      await ad.load();
    } catch (e) {
      setState(() => _isLoading = false);
      _set(AdStatus.failed, 'failed: $e');
    }
  }

  Future<void> _handlePresent() async {
    final ad = _ad;
    if (ad == null) {
      _set(AdStatus.failed, 'not ready — load first');
      return;
    }
    final ready = await ad.isReady;
    if (!ready) {
      _set(AdStatus.failed, 'not ready — load first');
      return;
    }
    await ad.present();
  }

  void _onEvent(VideoAdEventData data) {
    switch (data.event) {
      case VideoAdEvent.onLoad:
        setState(() {
          _isLoading = false;
          _canPresent = true;
        });
        _set(AdStatus.ready, 'loaded — tap Present');
      case VideoAdEvent.onFail:
        setState(() {
          _isLoading = false;
          _canPresent = false;
        });
        _set(
          AdStatus.failed,
          'failed: ${data.error?.message ?? "unknown error"}',
        );
      case VideoAdEvent.onProgress:
        final p = data.percent ?? 0;
        setState(() => _progressText = '$p%');
        _log.append('onProgress $p');
      case VideoAdEvent.onWillAppear:
        _log.append('onWillAppear');
      case VideoAdEvent.onDidAppear:
        _set(AdStatus.impression, 'playing');
      case VideoAdEvent.onWillDisappear:
        _log.append('onWillDisappear');
      case VideoAdEvent.onDidDisappear:
        setState(() => _canPresent = false);
        _set(AdStatus.idle, 'dismissed — reload to play again');
      case VideoAdEvent.onClick:
        _set(AdStatus.clicked, 'clicked');
      case VideoAdEvent.onLeaveApp:
        _log.append('onLeaveApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Video'), centerTitle: false),
      body: ListView(
        padding: AppInsets.screen.add(const EdgeInsets.only(top: 4)),
        children: [
          _introCard(),
          const SizedBox(height: Spacing.l),
          _statusCard(),
          const SizedBox(height: Spacing.l),
          TestOptionsPanel(controller: _options),
          const SizedBox(height: Spacing.l),
          _actionCard(),
          const SizedBox(height: Spacing.l),
          _logCard(),
        ],
      ),
    );
  }

  Widget _introCard() {
    return AppCard(
      children: [
        const SectionLabel('Video'),
        Text(
          '전체화면 동영상 광고입니다. 재생이 끝난 뒤 다시 보려면 '
          '광고를 새로 불러오세요(load).',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }

  Widget _statusCard() {
    return AppCard(
      children: [
        const SectionLabel('Status'),
        Align(
          alignment: Alignment.centerLeft,
          child: StatusBadge(status: _status, text: _statusText),
        ),
        InfoRow(label: '재생 진행률', value: _progressText),
      ],
    );
  }

  Widget _actionCard() {
    return AppCard(
      children: [
        const SectionLabel('Action'),
        Row(
          children: [
            Expanded(
              child: PrimaryTonalButton(
                label: 'Load',
                onPressed: _isLoading ? null : _handleLoad,
              ),
            ),
            const SizedBox(width: Spacing.m),
            Expanded(
              child: PrimaryFilledButton(
                label: 'Present',
                onPressed: _canPresent ? _handlePresent : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _logCard() {
    return AppCard(
      children: [
        const SectionLabel('Lifecycle log'),
        LogView(controller: _log),
      ],
    );
  }
}
