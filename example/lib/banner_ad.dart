import 'package:exelbid_plugin/ad_classes.dart';
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
      ? "27060aff4c8bcc8e7f897bc6385d870adbfe0738"
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
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _isShow = true;
                  });
                },
                child: const Text('Show Ad'),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: EdgeInsets.only(
                      bottom: MediaQuery.of(context).padding.bottom,
                    ),
                    child: Container(
                      width: 320,
                      height: 50,
                      color: Colors.grey,
                      child: _isShow
                          ? EBBannerAdView(
                              adUnitId: _adUnitId,
                              listener: EBPBannerAdViewListener(
                                onLoadAd: () {
                                  print("Banner onLoadAd");
                                },
                                onFailAd: (String? errorMessage) {
                                  print("Banner onFailAd");
                                  _isShow = false;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content:
                                          Text(errorMessage ?? "에러가 발생했습니다."),
                                      duration: const Duration(seconds: 3),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                                onClickAd: () {
                                  print("Banner onClickAd");
                                },
                              ),
                              styles: EBViewStyle(
                                backgroundColor: Colors.blueGrey[100],
                                borderRadius: 20,
                              ),
                            )
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
