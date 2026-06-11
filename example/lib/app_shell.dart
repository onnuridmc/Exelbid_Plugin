import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/material.dart';

import 'screens/ads/ads_list_screen.dart';
import 'screens/home_screen.dart';
import 'screens/mediation/mediation_list_screen.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> with WidgetsBindingObserver {
  int _index = 0;
  bool _didRequestAtt = false;

  // 하단 탭: Home / Ads / Mediation.
  static const List<_Tab> _tabs = [
    _Tab('Home', Icons.home_outlined, Icons.home),
    _Tab('Ads', Icons.rectangle_outlined, Icons.rectangle),
    _Tab('Mediation', Icons.account_tree_outlined, Icons.account_tree),
  ];

  late final List<Widget> _screens = [
    const HomeScreen(),
    _TabNavigator(builder: (_) => const AdsListScreen()),
    _TabNavigator(builder: (_) => const MediationListScreen()),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestAttOnce());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _requestAttOnce();
    }
  }

  Future<void> _requestAttOnce() async {
    if (_didRequestAtt) return;
    _didRequestAtt = true;
    try {
      await Exelbid.requestTrackingAuthorization();
    } catch (_) {
      // 무시 — iOS가 아니거나 이미 결정됨
    }
  }

  void _selectTab(int index) {
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _selectTab,
        destinations: [
          for (final tab in _tabs)
            NavigationDestination(
              icon: Icon(tab.icon),
              selectedIcon: Icon(tab.selectedIcon),
              label: tab.label,
            ),
        ],
      ),
    );
  }
}

/// 탭별 내비게이션 스택. 목록 → 상세 화면 전환이 해당 탭 안에서 이루어지고
/// 하단 바가 계속 보이도록 한다.
class _TabNavigator extends StatelessWidget {
  const _TabNavigator({required this.builder});

  final WidgetBuilder builder;

  @override
  Widget build(BuildContext context) {
    return Navigator(
      onGenerateRoute: (settings) => MaterialPageRoute(
        settings: settings,
        builder: builder,
      ),
    );
  }
}

class _Tab {
  const _Tab(this.label, this.icon, this.selectedIcon);
  final String label;
  final IconData icon;
  final IconData selectedIcon;
}
