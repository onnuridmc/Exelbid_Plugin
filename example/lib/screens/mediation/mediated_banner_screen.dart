import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../../ad_unit_ids.dart';
import '../../design/card.dart';
import '../../design/primary_button.dart';
import '../../design/tokens.dart';
import '../../widgets/log_view.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/test_options_panel.dart';

class MediatedBannerScreen extends StatefulWidget {
  const MediatedBannerScreen({super.key});

  @override
  State<MediatedBannerScreen> createState() => _MediatedBannerScreenState();
}

class _MediatedBannerScreenState extends State<MediatedBannerScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  final LogController _waterfall = LogController();

  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';
  String _winner = '-';

  int _epoch = 0;
  bool _hasLoaded = false;

  @override
  void dispose() {
    _options.dispose();
    _log.dispose();
    _waterfall.dispose();
    super.dispose();
  }

  void _set(AdStatus status, String text) {
    setState(() {
      _status = status;
      _statusText = text;
    });
    _log.append(text);
  }

  void _handleLoad() {
    setState(() {
      _winner = '-';
      _epoch += 1;
      _hasLoaded = true;
    });
    _waterfall.append('─── load ───');
    _set(AdStatus.loading, 'loading…');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mediated Banner'), centerTitle: false),
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
          _creativeCard(),
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
        const SectionLabel('Mediated Banner'),
        Text(
          '여러 광고 네트워크를 정해진 순서대로 시도해 가장 먼저 응답한 '
          '광고를 노출합니다. 자동 새로고침은 지원하지 않습니다.',
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
        PrimaryTonalButton(
          label: 'Load mediated banner',
          onPressed: _handleLoad,
        ),
      ],
    );
  }

  Widget _creativeCard() {
    return AppCard(
      children: [
        const SectionLabel('Creative'),
        SizedBox(
          height: 50,
          child: Center(
            child: !_hasLoaded
                ? Text(
                    'Tap “Load mediated banner”',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  )
                : ExelbidMediatedBannerAd(
                    key: ValueKey('mediated-banner-$_epoch'),
                    adUnitId: AdUnitIds.banner,
                    size: const Size(320, 50),
                    perNetworkTimeout: 5,
                    options: _options.buildOptions(),
                    onWinningNetwork: (n) => setState(() => _winner = n),
                    onLoad: () => _set(AdStatus.ready, 'loaded'),
                    onFail: (e) =>
                        _set(AdStatus.failed, 'failed: ${e.message}'),
                    onClick: () => _set(AdStatus.clicked, 'clicked'),
                    onLeaveApp: () => _set(AdStatus.clicked, 'left app'),
                    onClickFinish: () => _set(AdStatus.ready, 'click finished'),
                    onWaterfall: (w) => _waterfall.append(w.format()),
                  ),
          ),
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
