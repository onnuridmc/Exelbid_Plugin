import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../design/card.dart';
import '../design/tokens.dart';

/// "Home" 탭 — SDK 정보, ATT 상태/요청, 로그 레벨 설정.
/// (광고 타입은 Ads / Mediation 탭에 있다.)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _sdkVersion = '-';
  String _attStatus = '-';
  LogLevel _logLevel = LogLevel.debug;

  @override
  void initState() {
    super.initState();
    _loadSdkVersion();
    _refreshAttStatus();
  }

  Future<void> _loadSdkVersion() async {
    try {
      final v = await Exelbid.sdkVersion;
      if (mounted) setState(() => _sdkVersion = v.isEmpty ? '-' : v);
    } catch (_) {
      // 무시
    }
  }

  Future<void> _refreshAttStatus() async {
    try {
      final s = await Exelbid.trackingAuthorizationStatus;
      if (mounted) setState(() => _attStatus = _attTitle(s));
    } catch (_) {
      // 무시
    }
  }

  Future<void> _requestAtt() async {
    try {
      final s = await Exelbid.requestTrackingAuthorization();
      if (mounted) setState(() => _attStatus = _attTitle(s));
    } catch (_) {
      // 무시
    }
  }

  Future<void> _changeLogLevel(LogLevel level) async {
    setState(() => _logLevel = level);
    await Exelbid.setLogLevel(level);
  }

  String _attTitle(TrackingAuthorizationStatus s) {
    switch (s) {
      case TrackingAuthorizationStatus.authorized:
        return 'authorized';
      case TrackingAuthorizationStatus.denied:
        return 'denied';
      case TrackingAuthorizationStatus.restricted:
        return 'restricted';
      case TrackingAuthorizationStatus.notDetermined:
        return 'not determined';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ExelBid Demo'), centerTitle: false),
      body: ListView(
        padding: AppInsets.screen.add(const EdgeInsets.only(top: 4)),
        children: [
          _buildHeroCard(context),
          const SizedBox(height: Spacing.l),
          _buildAttCard(context),
          const SizedBox(height: Spacing.l),
          _buildLogLevelCard(context),
        ],
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      children: [
        const SectionLabel('SDK'),
        Text(
          'ExelBid ${_platformName()}',
          style: theme.textTheme.headlineSmall
              ?.copyWith(fontWeight: FontWeight.w700),
        ),
        Text(
          'ExelBid Flutter 플러그인 데모입니다. Ads / Mediation 탭에서 '
          '각 광고 유형을 확인할 수 있습니다.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        InfoRow(label: 'SDK version', value: _sdkVersion),
        InfoRow(label: 'Deployment', value: _deploymentTarget()),
      ],
    );
  }

  /// 앱이 실행 중인 플랫폼의 사람이 읽기 쉬운 이름.
  String _platformName() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS';
      case TargetPlatform.android:
        return 'Android';
      default:
        return defaultTargetPlatform.name;
    }
  }

  /// 실행 중인 플랫폼의 최소 배포 타깃.
  String _deploymentTarget() {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return 'iOS 13.0+';
      case TargetPlatform.android:
        return 'Android 5.0+ (API 21)';
      default:
        return '-';
    }
  }

  Widget _buildAttCard(BuildContext context) {
    return AppCard(
      children: [
        const SectionLabel('App Tracking Transparency'),
        InfoRow(label: 'ATT status', value: _attStatus),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton(
            onPressed: _requestAtt,
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              foregroundColor: BrandColors.accent,
              textStyle: const TextStyle(fontWeight: FontWeight.w600),
            ),
            child: const Text('Request ATT prompt'),
          ),
        ),
      ],
    );
  }

  Widget _buildLogLevelCard(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AppCard(
      children: [
        const SectionLabel('Log level'),
        SegmentedButton<LogLevel>(
          showSelectedIcon: false,
          segments: const [
            ButtonSegment(value: LogLevel.off, label: Text('off')),
            ButtonSegment(value: LogLevel.warning, label: Text('warn')),
            ButtonSegment(value: LogLevel.info, label: Text('info')),
            ButtonSegment(value: LogLevel.debug, label: Text('debug')),
          ],
          selected: {_logLevel},
          onSelectionChanged: (set) => _changeLogLevel(set.first),
        ),
        Text(
          '로그 출력 레벨입니다. 운영 빌드에서는 warn 이상을 권장합니다.',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}
