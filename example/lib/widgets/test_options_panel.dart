import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import '../design/tokens.dart';

/// `AdOptions.testing`을 위한 인라인 테스트 모드 토글. 각 예제 화면은 이를
/// 포함시키고 로드 직전에 [build]를 호출하여, 호스트 앱이 요청마다 값을
/// 설정하는 방식 그대로 값이 SDK로 전달되도록 한다.
class TestOptionsController extends ChangeNotifier {
  bool _testing = false;

  bool get testing => _testing;
  set testing(bool value) {
    if (_testing == value) return;
    _testing = value;
    notifyListeners();
  }

  AdOptions buildOptions({AdOptions? base}) {
    return AdOptions(
      keywords: base?.keywords ?? const {},
      yearOfBirth: base?.yearOfBirth,
      gender: base?.gender ?? Gender.unspecified,
      location: base?.location,
      coppa: base?.coppa ?? false,
      testing: _testing,
      videoSkipMin: base?.videoSkipMin,
      videoSkipAfter: base?.videoSkipAfter,
    );
  }
}

class TestOptionsPanel extends StatefulWidget {
  const TestOptionsPanel({required this.controller, super.key});

  final TestOptionsController controller;

  @override
  State<TestOptionsPanel> createState() => _TestOptionsPanelState();
}

class _TestOptionsPanelState extends State<TestOptionsPanel> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(CornerRadii.card),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
        ),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 4,
          ),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: const Text(
            'Test options',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          children: [
            Row(
              children: [
                const Text('testing'),
                const Spacer(),
                Switch.adaptive(
                  value: widget.controller.testing,
                  onChanged: (v) => widget.controller.testing = v,
                ),
              ],
            ),
            const SizedBox(height: Spacing.s),
            Text(
              '켜면 테스트 광고를 요청합니다. 실제 운영 전에 동작 확인용으로 사용하세요.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
