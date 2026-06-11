import 'package:flutter/material.dart';

import '../../design/card.dart';
import '../../design/tokens.dart';
import '../../widgets/surface_card.dart';
import '../banner_screen.dart';
import '../interstitial_screen.dart';
import '../native_screen.dart';
import '../video_screen.dart';

/// "Ads" 탭 — ExelBid의 기본 광고 타입 4종 목록. 행을 탭하면 해당 탭의
/// 내비게이션 스택에 상세 화면을 푸시한다.
class AdsListScreen extends StatelessWidget {
  const AdsListScreen({super.key});

  static final List<_AdEntry> _entries = [
    _AdEntry('Banner', '320×50 배너 광고', Icons.crop_landscape,
        (_) => const BannerScreen()),
    _AdEntry('Interstitial', '전체화면 전면 광고', Icons.fullscreen,
        (_) => const InterstitialScreen()),
    _AdEntry('Native', '앱 레이아웃에 맞춘 네이티브 광고', Icons.article,
        (_) => const NativeScreen()),
    _AdEntry('Video', '전체화면 동영상 광고', Icons.play_circle,
        (_) => const VideoScreen()),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ads'), centerTitle: false),
      body: ListView(
        padding: AppInsets.screen.add(const EdgeInsets.only(top: 4)),
        children: [
          AppCard(
            children: [
              const SectionLabel('Ads'),
              Text(
                'ExelBid 기본 광고 4종입니다. 항목을 선택하면 해당 '
                '화면으로 이동합니다.',
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

class _AdEntry {
  _AdEntry(this.title, this.subtitle, this.icon, this.builder);

  final String title;
  final String subtitle;
  final IconData icon;
  final WidgetBuilder builder;
}
