import 'package:exelbid_plugin_example/banner_ad.dart';
import 'package:exelbid_plugin_example/interstitial_ad.dart';
import 'package:exelbid_plugin_example/native_ad.dart';
import 'package:exelbid_plugin_example/mediation_banner_ad.dart';
import 'package:exelbid_plugin_example/mediation_interstitial_ad.dart';
import 'package:exelbid_plugin_example/mediation_native_ad.dart';
import 'package:flutter/material.dart';
import 'package:exelbid_plugin/exelbid_plugin.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();

    ExelbidPlugin.shared
        .requestTrackingAuthorization()
        .then((value) => {print(">>> requestTrackingAuthorization : $value")});
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ad Screen Example',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Main Screen'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BannerAdWidget()),
                );
              },
              child: const Text('Go to Banner Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const InterstitialAdWidget()),
                );
              },
              child: const Text('Go to Interstitial Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const NativeAdWidget()),
                );
              },
              child: const Text('Go to Native Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MediationBannerAdWidget()),
                );
              },
              child: const Text('Go to Mediation Banner Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          const MediationInterstitialAdWidget()),
                );
              },
              child: const Text('Go to Mediation Interstitial Ad'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MediationNativeAdWidget()),
                );
              },
              child: const Text('Go to Mediation Native Ad'),
            )
          ],
        ),
      ),
    );
  }
}
