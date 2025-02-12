import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/native_ad_view.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  @override
  _NativeAdState createState() => _NativeAdState();
}

class _NativeAdState extends State<NativeAdWidget> {
  final String _adUnitId = defaultTargetPlatform == TargetPlatform.android
      ? "d7b20997ed5f925e617c33a5b198bdce6fcf04b0"
      : "5792d262715cbd399d6910200437b40a95dcc0f6";
  bool _isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ad"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
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
          child: Stack(children: [
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).padding.bottom,
                ),
                child: SizedBox(
                  width: double.infinity,
                  height: 300,
                  child: _isShow
                      ? EBNativeAdView(
                          adUnitId: _adUnitId,
                          isTest: true,
                          nativeAssets: const [
                            EBNativeAssets.title,
                            EBNativeAssets.main,
                            EBNativeAssets.icon,
                            EBNativeAssets.ctatext,
                          ],
                          listener: EBPNativeAdViewListener(onLoadAd: () {
                            print("Native onLoadAd");
                          }, onFailAd: (String? errorMessage) {
                            print("Native onFailAd");
                          }, onClickAd: () {
                            print("Native onClickAd");
                          }),
                          child: Column(children: [
                            // 상단 이미지 및 텍스트 영역
                            const Row(children: [
                              SizedBox(
                                width: 48,
                                height: 48,
                                child: Center(
                                  child: EBNativeAdIconImage(),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: EBNativeAdTtitle(
                                  height: 48,
                                ),
                              ),
                            ]),
                            const SizedBox(height: 10),
                            // 메인 이미지 뷰
                            const Expanded(
                              child: SizedBox(
                                width: double.infinity,
                                child: Center(
                                  child: Stack(children: [
                                    EBNativeAdMainImage(),
                                    Positioned(
                                      right: 10,
                                      top: 10,
                                      child:
                                          EBNativeAdPrivacyInformationIconImage(
                                        width: 20,
                                        height: 20,
                                      ),
                                    ),
                                  ]),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            // 버튼 영역
                            Align(
                              alignment: Alignment.bottomRight,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 10, horizontal: 20),
                                child: const EBNativeAdCallToAction(
                                  style: ButtonStyle(
                                    backgroundColor:
                                        WidgetStatePropertyAll<Color>(
                                            Colors.white),
                                    textStyle:
                                        WidgetStatePropertyAll<TextStyle>(
                                            TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold)),
                                  ),
                                ),
                              ),
                            ),
                          ]),
                        )
                      : null,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}
