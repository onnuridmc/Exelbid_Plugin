import 'dart:io' show Platform;

import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../../ad_unit_ids.dart';
import '../../design/card.dart';
import '../../design/primary_button.dart';
import '../../design/tokens.dart';
import '../../widgets/log_view.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/test_options_panel.dart';

class MediatedNativeScreen extends StatefulWidget {
  const MediatedNativeScreen({super.key});

  @override
  State<MediatedNativeScreen> createState() => _MediatedNativeScreenState();
}

class _MediatedNativeScreenState extends State<MediatedNativeScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  final LogController _waterfall = LogController();

  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';
  String _winner = '-';

  int _adEpoch = 0;
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
    _set(AdStatus.loading, 'loading…');
    setState(() {
      _winner = '-';
      _adEpoch += 1;
      _hasLoaded = true;
    });
    _waterfall.append('─── load ───');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mediated Native'), centerTitle: false),
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
        const SectionLabel('Mediated Native'),
        Text(
          '미디에이션 네이티브 광고입니다. 선택된 네트워크의 광고 자산이 '
          '앱 레이아웃의 각 슬롯에 채워집니다.',
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
          label: 'Reload mediated native ad',
          onPressed: _handleLoad,
        ),
      ],
    );
  }

  Widget _creativeCard() {
    return AppCard(
      children: [
        const SectionLabel('Creative'),
        if (!_hasLoaded)
          Container(
            height: 280,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Tap “Reload mediated native ad”',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          _MediatedNativeCreative(
            key: ValueKey('mediated-native-$_adEpoch'),
            adUnitId: AdUnitIds.native,
            options: _options.buildOptions(),
            onWinningNetwork: (n) => setState(() => _winner = n),
            onWaterfall: (w) => _waterfall.append(w.format()),
            onLoad: () => _set(AdStatus.ready, '표시됨'),
            onFail: (e) => _set(AdStatus.failed, 'failed: ${e.message}'),
            onImpression: () => _set(AdStatus.impression, 'impression'),
            onImpression50: () => _set(AdStatus.impression, 'impression 50%'),
            onImpression100: () => _set(AdStatus.impression, 'impression 100%'),
            onClick: () => _set(AdStatus.clicked, 'clicked'),
            onLeaveApp: () => _set(AdStatus.clicked, 'left app'),
            onClickFinish: () => _set(AdStatus.ready, 'click finished'),
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

/// 미디에이션 네이티브 광고 텍스트에 적용할 커스텀 폰트(NanumPen) 패밀리명.
///
/// 표준 네이티브와 동일하게, 광고 텍스트는 네이티브가 그리므로 플랫폼별로
/// 등록 이름이 다르다 (Android: `res/font` 파일명, iOS: 폰트 내부 패밀리명).
/// 등록 절차는 `doc/CUSTOM_FONT_SETUP.md` 참고.
String? get _adFontFamily {
  if (Platform.isAndroid) return 'nanum_pen';
  if (Platform.isIOS) return 'Nanum Pen';
  return null;
}

class _MediatedNativeCreative extends StatelessWidget {
  const _MediatedNativeCreative({
    required this.adUnitId,
    required this.options,
    required this.onWinningNetwork,
    required this.onWaterfall,
    required this.onLoad,
    required this.onFail,
    required this.onImpression,
    required this.onImpression50,
    required this.onImpression100,
    required this.onClick,
    required this.onLeaveApp,
    required this.onClickFinish,
    super.key,
  });

  final String adUnitId;
  final AdOptions options;
  final void Function(String network) onWinningNetwork;
  final void Function(WaterfallEvent waterfall) onWaterfall;
  final VoidCallback onLoad;
  final void Function(AdError error) onFail;
  final VoidCallback onImpression;
  final VoidCallback onImpression50;
  final VoidCallback onImpression100;
  final VoidCallback onClick;
  final VoidCallback onLeaveApp;
  final VoidCallback onClickFinish;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        color: scheme.surfaceContainerLowest,
        padding: const EdgeInsets.all(12),
        child: ExelbidMediatedNativeAdView(
          adUnitId: adUnitId,
          options: options,
          perNetworkTimeout: 5,
          desiredAssets: const {
            NativeAsset.title,
            NativeAsset.icon,
            NativeAsset.main,
            NativeAsset.desc,
            NativeAsset.ctatext,
          },
          onWinningNetwork: onWinningNetwork,
          onWaterfall: onWaterfall,
          onLoad: onLoad,
          onFail: onFail,
          onImpression: onImpression,
          onImpression50: onImpression50,
          onImpression100: onImpression100,
          onClick: onClick,
          onLeaveApp: onLeaveApp,
          onClickFinish: onClickFinish,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  ExelbidNativeAdIconImage(
                    width: 40,
                    height: 40,
                    style: const ExelbidNativeSlotStyle(
                      contentMode: BoxFit.cover,
                      cornerRadius: 8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SizedBox(
                      child: ExelbidNativeAdTitle(
                        style: ExelbidNativeSlotStyle(
                          fontFamily: _adFontFamily,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          textColor: scheme.onSurface,
                          maxLines: 2,
                          overflow: .ellipsis,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ExelbidNativeAdCallToAction(
                    width: 80,
                    style: ExelbidNativeSlotStyle(
                      fontFamily: _adFontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      textColor: Colors.white,
                      textAlign: TextAlign.center,
                      backgroundColor: scheme.primary,
                      cornerRadius: 8,
                      padding: EdgeInsets.all(8.0),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Stack(
                children: [
                  ExelbidNativeAdMedia(
                    width: double.infinity,
                    height: 180,
                    style: const ExelbidNativeSlotStyle(
                      contentMode: BoxFit.cover,
                      cornerRadius: 8,
                    ),
                  ),
                  const Positioned(
                    top: 6,
                    right: 6,
                    child: ExelbidNativeAdPrivacyIcon(width: 20, height: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                child: ExelbidNativeAdDescription(
                  style: ExelbidNativeSlotStyle(
                    fontFamily: _adFontFamily,
                    fontSize: 13,
                    textColor: scheme.onSurfaceVariant,
                    maxLines: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
