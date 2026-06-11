import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../ad_unit_ids.dart';
import '../design/card.dart';
import '../design/primary_button.dart';
import '../design/tokens.dart';
import '../widgets/log_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/test_options_panel.dart';

class BannerScreen extends StatefulWidget {
  const BannerScreen({super.key});

  @override
  State<BannerScreen> createState() => _BannerScreenState();
}

class _BannerScreenState extends State<BannerScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';

  /// 배너 위젯의 key로 사용된다. 값을 올리면 새로운 PlatformView가 생성되어,
  /// 이후 Load 탭이 유휴 상태로 머무르지 않고 실제로 배너를 다시 요청하게 된다.
  int _bannerEpoch = 0;
  bool _hasLoaded = false;

  @override
  void dispose() {
    _options.dispose();
    _log.dispose();
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
    _set(AdStatus.loading, 'loading…');
    setState(() {
      _bannerEpoch += 1;
      _hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Banner'), centerTitle: false),
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
          _logCard(),
        ],
      ),
    );
  }

  Widget _introCard() {
    return AppCard(
      children: [
        const SectionLabel('Banner'),
        Text(
          '320×50 배너 광고입니다. Load 버튼으로 배너를 불러옵니다.',
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
      ],
    );
  }

  Widget _actionCard() {
    return AppCard(
      children: [
        const SectionLabel('Action'),
        PrimaryFilledButton(label: 'Load banner', onPressed: _handleLoad),
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
            child: _hasLoaded
                ? ExelbidBannerAd(
                    key: ValueKey('banner-$_bannerEpoch'),
                    adUnitId: AdUnitIds.banner,
                    size: const Size(320, 50),
                    options: _options.buildOptions(),
                    onLoad: () => _set(AdStatus.ready, 'loaded'),
                    onFail: (e) =>
                        _set(AdStatus.failed, 'failed: ${e.message}'),
                    onClick: () => _set(AdStatus.clicked, 'clicked'),
                    onLeaveApp: () => _set(AdStatus.clicked, 'left app'),
                    onClickFinish: () => _set(AdStatus.ready, 'click finished'),
                  )
                : const SizedBox(width: 320, height: 50),
          ),
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
