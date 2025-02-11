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
      ? "b014ec22dccb43bfc35ea1e5051c83862d7357cf"
      : "5792d262715cbd399d6910200437b40a95dcc0f6";
  bool _isShow = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ad"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
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
                    child: SizedBox(
                      width: double.infinity,
                      height: 300,
                      child: _isShow
                          ? EBNativeAdView(
                              adUnitId: _adUnitId,
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
                              child: Column(
                                children: [
                                  // 상단 이미지 및 텍스트 영역
                                  Row(
                                    children: [
                                      Container(
                                        width: 48,
                                        height: 48,
                                        child: const Center(
                                          child: EBNativeAdIconImage(),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      const Expanded(
                                        child: EBNativeAdTtitle(
                                          height: 48,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // 메인 이미지 뷰
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: const Center(
                                        child: EBNativeAdMainImage(),
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
                                                      fontWeight:
                                                          FontWeight.bold)),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ))
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
