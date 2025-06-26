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
  void dispose() {
    super.dispose();
  }

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
                child: Container(
                  width: double.infinity,
                  height: 300,
                  color: Color.fromARGB(255, 240, 240, 240),
                  child: _isShow
                      ? EBNativeAdView(
                          adUnitId: _adUnitId,
                          nativeAssets: const [
                            EBNativeAssets.title,
                            EBNativeAssets.main,
                            EBNativeAssets.icon,
                            EBNativeAssets.ctatext,
                          ],
                          styles: const EBViewStyle(
                            borderRadius: 20,
                          ),
                          listener: EBPNativeAdViewListener(onLoadAd: () {
                            print("Native onLoadAd");
                          }, onFailAd: (String? errorMessage) {
                            print("Native onFailAd");
                          }, onClickAd: () {
                            print("Native onClickAd");
                          }),
                          child: Column(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                child: // 상단 이미지 및 텍스트 영역
                                    Row(children: [
                                  SizedBox(
                                    width: 48,
                                    height: 48,
                                    child: Center(
                                      child: EBNativeAdIconImage(
                                        styles: EBImageStyle(
                                          backgroundColor: Colors.grey[300],
                                          borderRadius: 20,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: SizedBox(
                                      child: EBNativeAdTitle(
                                        styles: const EBTextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                ]),
                              ),
                              const SizedBox(height: 10),
                              // 메인 이미지 뷰
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  height: double.infinity,
                                  child: Stack(children: [
                                    Center(
                                      child: EBNativeAdMainImage(
                                        styles: EBImageStyle(
                                          backgroundColor: Colors.grey[300],
                                          borderRadius: 10,
                                        ),
                                      ),
                                    ),
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
                              const SizedBox(height: 10),
                              // 버튼 영역
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Container(
                                  padding: const EdgeInsets.only(
                                      top: 10, bottom: 10, right: 10),
                                  child: EBNativeAdCallToAction(
                                    styles: const EBButtonStyle(
                                      color: Colors.white,
                                      backgroundColor: Colors.lightBlue,
                                      borderRadius: 10,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
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
