import 'package:flutter/material.dart';

import '../design/tokens.dart';

class LogController extends ChangeNotifier {
  final List<String> _lines = <String>[];

  List<String> get lines => List.unmodifiable(_lines);

  void append(String line) {
    final now = DateTime.now();
    final stamp = '${_two(now.hour)}:${_two(now.minute)}:${_two(now.second)}';
    _lines.add('[$stamp] $line');
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    notifyListeners();
  }

  String _two(int v) => v < 10 ? '0$v' : '$v';
}

/// 고정폭 글꼴의 추가 전용 로그 영역. 항상 최신 줄로 스크롤된다.
class LogView extends StatefulWidget {
  const LogView({
    required this.controller,
    this.minHeight = 160,
    super.key,
  });

  final LogController controller;
  final double minHeight;

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(covariant LogView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onChanged);
      widget.controller.addListener(_onChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onChanged() {
    setState(() {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 120),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final lines = widget.controller.lines;

    return Container(
      constraints: BoxConstraints(minHeight: widget.minHeight),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(CornerRadii.log),
      ),
      padding: const EdgeInsets.all(Spacing.s),
      child: lines.isEmpty
          ? Center(
              child: Text(
                'No events yet',
                style: TextStyle(
                  color: scheme.onSurfaceVariant,
                  fontSize: 11,
                ),
              ),
            )
          : SingleChildScrollView(
              controller: _scrollController,
              child: SelectableText(
                lines.join('\n'),
                style: TextStyle(
                  fontFamily: 'Menlo',
                  fontFeatures: const [FontFeature.tabularFigures()],
                  fontSize: 11,
                  color: scheme.onSurface,
                ),
              ),
            ),
    );
  }
}
