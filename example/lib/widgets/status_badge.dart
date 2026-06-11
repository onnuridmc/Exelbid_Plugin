import 'package:flutter/material.dart';

enum AdStatus { idle, loading, ready, impression, clicked, failed }

extension AdStatusColor on AdStatus {
  Color get foreground {
    switch (this) {
      case AdStatus.idle:
        return const Color(0xFF8E8E93);
      case AdStatus.loading:
        return const Color(0xFFFF9500);
      case AdStatus.ready:
        return const Color(0xFF0A84FF);
      case AdStatus.impression:
        return const Color(0xFF34C759);
      case AdStatus.clicked:
        return const Color(0xFFAF52DE);
      case AdStatus.failed:
        return const Color(0xFFFF3B30);
    }
  }

  Color get background => foreground.withValues(alpha: 0.12);
}

class StatusBadge extends StatelessWidget {
  const StatusBadge({required this.status, required this.text, super.key});

  final AdStatus status;
  final String text;

  @override
  Widget build(BuildContext context) {
    final fg = status.foreground;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: status.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: fg,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: fg, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
