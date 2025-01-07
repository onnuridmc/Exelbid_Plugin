import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/banner_ad_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  _BannerAdState createState() => _BannerAdState();
}

class _BannerAdState extends State<BannerAdWidget> {
  final String _adUnitId = defaultTargetPlatform == TargetPlatform.android
      ? "fb59bdd7ffd4e9868e0d6dde98445a8854882a28"
      : "08377f76c8b3e46c4ed36c82e434da2b394a4dfa";
  bool _isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Banner Ad"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // 버튼 2개
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Show Ad 기능 추가
                  setState(() {
                    _isShow = true;
                  });
                },
                child: const Text('Show Ad'),
              ),
            ),
          ),
          // 하단 빈 영역
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: SizedBox(
                      width: 320,
                      height: 50,
                      child: _isShow
                          ? EBBannerAdView(
                              adUnitId: _adUnitId,
                              listener: EBPBannerAdViewListener(onLoadAd: () {
                                print("Banner onLoadAd");
                              }, onFailAd: (String? errorMessage) {
                                print("Banner onFailAd");
                              }, onClickAd: () {
                                print("Banner onClickAd");
                              }))
                          : null,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
