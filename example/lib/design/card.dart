import 'package:flutter/material.dart';

import 'tokens.dart';

/// 데모 화면 전반에서 사용하는 그룹형 카드 컨테이너.
class AppCard extends StatelessWidget {
  const AppCard({
    required this.children,
    this.spacing = Spacing.m,
    this.padding = AppInsets.card,
    this.crossAxisAlignment = CrossAxisAlignment.stretch,
    super.key,
  });

  final List<Widget> children;
  final double spacing;
  final EdgeInsetsGeometry padding;
  final CrossAxisAlignment crossAxisAlignment;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final items = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      items.add(children[i]);
      if (i != children.length - 1) {
        items.add(SizedBox(height: spacing));
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(CornerRadii.card),
      ),
      padding: padding,
      child: Column(
        crossAxisAlignment: crossAxisAlignment,
        children: items,
      ),
    );
  }
}

/// 아이브로 라벨: 캡션, 세미볼드, 대문자, 보조 색상.
class SectionLabel extends StatelessWidget {
  const SectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;
    return Text(
      text.toUpperCase(),
      style: theme.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: scheme.onSurfaceVariant,
        letterSpacing: 0.5,
      ),
    );
  }
}

/// 정보 / 상태 카드에서 사용하는 `key — value` 행.
class InfoRow extends StatelessWidget {
  const InfoRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final theme = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
        const SizedBox(width: Spacing.m),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: theme.bodyMedium?.copyWith(color: scheme.onSurface),
          ),
        ),
      ],
    );
  }
}
