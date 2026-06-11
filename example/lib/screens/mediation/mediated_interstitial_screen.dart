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

class MediatedInterstitialScreen extends StatefulWidget {
  const MediatedInterstitialScreen({super.key});

  @override
  State<MediatedInterstitialScreen> createState() =>
      _MediatedInterstitialScreenState();
}

class _MediatedInterstitialScreenState
    extends State<MediatedInterstitialScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  final LogController _waterfall = LogController();

  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';
  String _winner = '-';

  ExelbidMediatedInterstitialAd? _ad;
  StreamSubscription<MediatedInterstitialAdEventData>? _eventSub;
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
      _winner = '-';
      _canPresent = false;
      _isLoading = true;
    });
    _waterfall.append('─── load ───');

    await _eventSub?.cancel();
    await _ad?.dispose();

    try {
      final ad = await ExelbidMediatedInterstitialAd.create(
        adUnitId: AdUnitIds.interstitial,
        options: _options.buildOptions(),
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

  void _onEvent(MediatedInterstitialAdEventData data) {
    switch (data.event) {
      case MediatedInterstitialAdEvent.onLoad:
        setState(() {
          _isLoading = false;
          _canPresent = true;
          if (data.winningNetwork != null) _winner = data.winningNetwork!;
        });
        _set(AdStatus.ready, 'loaded — tap Present');
      case MediatedInterstitialAdEvent.onFail:
        setState(() {
          _isLoading = false;
          _canPresent = false;
        });
        _set(AdStatus.failed,
            'failed: ${data.error?.message ?? "unknown error"}');
      case MediatedInterstitialAdEvent.onWaterfall:
        if (data.waterfall != null) _waterfall.append(data.waterfall!.format());
      case MediatedInterstitialAdEvent.onWillAppear:
        _log.append('onWillAppear');
      case MediatedInterstitialAdEvent.onDidAppear:
        _set(AdStatus.impression, 'presented');
      case MediatedInterstitialAdEvent.onWillDisappear:
        _log.append('onWillDisappear');
      case MediatedInterstitialAdEvent.onDidDisappear:
        setState(() => _canPresent = false);
        _set(AdStatus.idle, 'dismissed — reload to show again');
      case MediatedInterstitialAdEvent.onClick:
        _set(AdStatus.clicked, 'clicked');
      case MediatedInterstitialAdEvent.onLeaveApp:
        _log.append('onLeaveApp');
      case MediatedInterstitialAdEvent.onClickFinish:
        _log.append('onClickFinish');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mediated Interstitial'),
        centerTitle: false,
      ),
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
        const SectionLabel('Mediated Interstitial'),
        Text(
          '미디에이션 전면 광고입니다. 광고를 불러온 뒤(load) 준비되면(isReady) '
          '노출합니다(present). 여러 네트워크를 순서대로 시도해 가장 먼저 '
          '응답한 광고를 보여줍니다.',
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
