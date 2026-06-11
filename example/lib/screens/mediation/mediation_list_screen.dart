import 'package:flutter/material.dart';

import '../../design/card.dart';
import '../../design/tokens.dart';
import '../../widgets/surface_card.dart';
import 'mediated_banner_screen.dart';
import 'mediated_interstitial_screen.dart';
import 'mediated_native_screen.dart';
import 'mediated_video_screen.dart';

/// "Mediation" 탭 — 미디에이션 광고 타입 4종 목록. 행을 탭하면 해당 탭의
/// 내비게이션 스택에 상세 화면을 푸시한다.
class MediationListScreen extends StatelessWidget {
  const MediationListScreen({super.key});

  static final List<_MediationEntry> _entries = [
    _MediationEntry('Mediated Banner', '배너 미디에이션',
        Icons.crop_landscape, (_) => const MediatedBannerScreen()),
    _MediationEntry(
        'Mediated Interstitial',
        '전면 미디에이션',
        Icons.fullscreen,
        (_) => const MediatedInterstitialScreen()),
    _MediationEntry('Mediated Native', '네이티브 미디에이션',
        Icons.article, (_) => const MediatedNativeScreen()),
    _MediationEntry('Mediated Video', '동영상 미디에이션',
        Icons.play_circle, (_) => const MediatedVideoScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mediation'), centerTitle: false),
      body: ListView(
        padding: AppInsets.screen.add(const EdgeInsets.only(top: 4)),
        children: [
          AppCard(
            children: [
              const SectionLabel('Mediation'),
              Text(
                '여러 광고 네트워크를 정해진 순서대로 시도해 가장 먼저 응답한 '
                '광고를 노출합니다. 항목을 선택하면 각 유형을 확인할 수 있습니다.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: Spacing.l),
          for (final entry in _entries) ...[
            SurfaceCard(
              title: entry.title,
              subtitle: entry.subtitle,
              icon: entry.icon,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: entry.builder),
              ),
            ),
            const SizedBox(height: Spacing.m),
          ],
        ],
      ),
    );
  }
}

class _MediationEntry {
  _MediationEntry(this.title, this.subtitle, this.icon, this.builder);

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
