import 'dart:async';

import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../../ad_unit_ids.dart';
import '../../design/card.dart';
import '../../design/primary_button.dart';
import '../../design/tokens.dart';
import '../../widgets/log_view.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/test_options_panel.dart';

class MediatedVideoScreen extends StatefulWidget {
  const MediatedVideoScreen({super.key});

  @override
  State<MediatedVideoScreen> createState() => _MediatedVideoScreenState();
}

class _MediatedVideoScreenState extends State<MediatedVideoScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  final LogController _waterfall = LogController();

  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';
  String _progressText = '-';
  String _winner = '-';

  ExelbidMediatedVideoAd? _ad;
  StreamSubscription<MediatedVideoAdEventData>? _eventSub;
  bool _canPresent = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _options.dispose();
    _log.dispose();
    _waterfall.dispose();
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
      _winner = '-';
      _canPresent = false;
      _isLoading = true;
    });
    _waterfall.append('─── load ───');

    final options = _options.buildOptions(
      base: AdOptions(videoSkipMin: 10, videoSkipAfter: 5),
    );

    await _eventSub?.cancel();
    await _ad?.dispose();

    try {
      final ad = await ExelbidMediatedVideoAd.create(
        adUnitId: AdUnitIds.video,
        options: options,
        perNetworkTimeout: 5,
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

  void _onEvent(MediatedVideoAdEventData data) {
    switch (data.event) {
      case MediatedVideoAdEvent.onLoad:
        setState(() {
          _isLoading = false;
          _canPresent = true;
          if (data.winningNetwork != null) _winner = data.winningNetwork!;
        });
        _set(AdStatus.ready, 'loaded — tap Present');
      case MediatedVideoAdEvent.onFail:
        setState(() {
          _isLoading = false;
          _canPresent = false;
        });
        _set(
          AdStatus.failed,
          'failed: ${data.error?.message ?? "unknown error"}',
        );
      case MediatedVideoAdEvent.onProgress:
        final p = data.percent ?? 0;
        setState(() => _progressText = '$p%');
        _log.append('onProgress $p');
      case MediatedVideoAdEvent.onWaterfall:
        if (data.waterfall != null) _waterfall.append(data.waterfall!.format());
      case MediatedVideoAdEvent.onWillAppear:
        _log.append('onWillAppear');
      case MediatedVideoAdEvent.onDidAppear:
        _set(AdStatus.impression, 'playing');
      case MediatedVideoAdEvent.onWillDisappear:
        _log.append('onWillDisappear');
      case MediatedVideoAdEvent.onDidDisappear:
        setState(() => _canPresent = false);
        _set(AdStatus.idle, 'dismissed — reload to play again');
      case MediatedVideoAdEvent.onClick:
        _set(AdStatus.clicked, 'clicked');
      case MediatedVideoAdEvent.onLeaveApp:
        _log.append('onLeaveApp');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mediated Video'), centerTitle: false),
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
          _waterfallCard(),
          const SizedBox(height: Spacing.l),
          _logCard(),
        ],
      ),
    );
  }

  Widget _introCard() {
    return AppCard(
      children: [
        const SectionLabel('Mediated Video'),
        Text(
          '미디에이션 동영상 광고입니다. 광고를 불러온 뒤(load) 준비되면 '
          '노출하며(present), 재생이 끝나면 다시 불러와야 합니다. 재생 '
          '진행률(0/25/50/75/100%)이 콜백으로 전달됩니다.',
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
        InfoRow(label: 'Winning network', value: _winner),
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

  Widget _waterfallCard() {
    return AppCard(
      children: [
        const SectionLabel('Waterfall'),
        LogView(controller: _waterfall),
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
