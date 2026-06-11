import 'package:flutter/material.dart';

import '../design/card.dart';
import '../design/tokens.dart';

/// Ads / Mediation 탭에서 사용하는 목록 행: 앞쪽의 색조 아이콘, 제목 +
/// 부제목, 뒤쪽의 셰브론으로 구성되며 카드 전체를 탭할 수 있다.
class SurfaceCard extends StatelessWidget {
  const SurfaceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    super.key,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(CornerRadii.card),
        onTap: onTap,
        child: AppCard(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: BrandColors.accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: BrandColors.accent),
                ),
                const SizedBox(width: Spacing.m),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: scheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
