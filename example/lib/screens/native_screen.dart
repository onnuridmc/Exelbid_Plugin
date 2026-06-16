import 'dart:io' show Platform;

import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../ad_unit_ids.dart';
import '../design/card.dart';
import '../design/primary_button.dart';
import '../design/tokens.dart';
import '../widgets/log_view.dart';
import '../widgets/status_badge.dart';
import '../widgets/test_options_panel.dart';

class NativeScreen extends StatefulWidget {
  const NativeScreen({super.key});

  @override
  State<NativeScreen> createState() => _NativeScreenState();
}

class _NativeScreenState extends State<NativeScreen> {
  final TestOptionsController _options = TestOptionsController();
  final LogController _log = LogController();
  AdStatus _status = AdStatus.idle;
  String _statusText = 'Tap to load';

  int _adEpoch = 0;
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
      _adEpoch += 1;
      _hasLoaded = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Native'), centerTitle: false),
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
        const SectionLabel('Native'),
        Text(
          '앱이 구성한 레이아웃에 광고 자산(제목·이미지·아이콘 등)이 채워집니다. '
          '광고가 화면에 보이면 노출 이벤트가 발생합니다.',
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
        PrimaryTonalButton(label: 'Reload native ad', onPressed: _handleLoad),
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
              'Tap “Reload native ad” to fetch a creative',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          _NativeCreative(
            key: ValueKey('native-$_adEpoch'),
            adUnitId: AdUnitIds.native,
            options: _options.buildOptions(),
            onLoad: () => _set(AdStatus.ready, '표시됨'),
            onFail: (e) => _set(AdStatus.failed, 'failed: ${e.message}'),
            onImpression: () => _set(AdStatus.impression, 'impression'),
            onClick: () => _set(AdStatus.clicked, 'clicked'),
            onLeaveApp: () => _set(AdStatus.clicked, 'left app'),
            onClickFinish: () => _set(AdStatus.ready, 'click finished'),
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

/// 네이티브 광고 텍스트에 적용할 커스텀 폰트(NanumPen) 패밀리명.
///
/// 광고 텍스트는 네이티브(iOS/Android)가 직접 그리므로 폰트도 각 플랫폼에
/// 등록해야 하고, 등록 이름이 서로 다르다:
/// - Android: `res/font/nanum_pen.xml` 파일명 → `'nanum_pen'`
/// - iOS: 폰트 파일 내부의 패밀리명(파일명과 다름!) → `'Nanum Pen'`
///
/// 등록 절차는 `doc/CUSTOM_FONT_SETUP.md` 참고.
String? get _adFontFamily {
  if (Platform.isAndroid) return 'nanum_pen';
  if (Platform.isIOS) return 'Nanum Pen';
  return null;
}

class _NativeCreative extends StatelessWidget {
  const _NativeCreative({
    required this.adUnitId,
    required this.options,
    required this.onLoad,
    required this.onFail,
    required this.onImpression,
    required this.onClick,
    required this.onLeaveApp,
    required this.onClickFinish,
    super.key,
  });

  final String adUnitId;
  final AdOptions options;
  final VoidCallback onLoad;
  final void Function(AdError error) onFail;
  final VoidCallback onImpression;
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
        child: ExelbidNativeAdView(
          adUnitId: adUnitId,
          options: options,
          desiredAssets: const {
            NativeAsset.title,
            NativeAsset.icon,
            NativeAsset.main,
            NativeAsset.desc,
            NativeAsset.ctatext,
          },
          onLoad: onLoad,
          onFail: onFail,
          onImpression: onImpression,
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
                    left: 6,
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
