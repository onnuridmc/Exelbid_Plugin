import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InterstitialAdWidget extends StatefulWidget {
  const InterstitialAdWidget({super.key});

  @override
  _InterstitialAdState createState() => _InterstitialAdState();
}

class _InterstitialAdState extends State<InterstitialAdWidget> {
  final String _adUnitId = defaultTargetPlatform == TargetPlatform.android
      ? "f028a0c209dfc9fe7243381f3ba92eabe640cfbf"
      : "615217b82a648b795040baee8bc81986a71d0eb7";
  bool _isLoadButton = true;
  bool _isShowButton = false;

  _InterstitialAdState() {
    // Set Interstitial Listener
    ExelbidPlugin.shared
        .setInterstitialListener(EBPInterstitialAdViewListener(onLoadAd: () {
      print('Interstitial onLoadAd');
      setState(() {
        _isShowButton = true;
      });
    }, onFailAd: (String? errorMessage) {
      print('Interstitial onFailAd : $errorMessage');
    }, onClickAd: () {
      print('Interstitial onClickAd');
    }, onInterstitialShow: () {
      print('onInterstitialShow');
    }, onInterstitialDismiss: () {
      print('onInterstitialDismiss');
      setState(() {
        _isLoadButton = true;
        _isShowButton = false;
      });
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interstitial Ad"),
      ),
      body: Column(
        children: [
          // 버튼 2개
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoadButton
                        ? () {
                            // Interstitial Ad Load
                            ExelbidPlugin.shared
                                .loadInterstitial(adUnitId: _adUnitId);
                            setState(() {
                              _isLoadButton = false;
                            });
                          }
                        : null,
                    child: const Text('Load Ad'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isShowButton
                        ? () {
                            // Interstitial Ad Show
                            ExelbidPlugin.shared.showInterstitial();
                          }
                        : null,
                    child: const Text('Show Ad'),
                  ),
                ),
              ],
            ),
          ),
          // 하단 빈 영역
          const Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }
}
