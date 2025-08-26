import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/banner_ad_view.dart';
import 'package:exelbid_plugin/exelbid_mediation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediationBannerAdWidget extends StatefulWidget {
  const MediationBannerAdWidget({super.key});

  @override
  _MediationBannerAdState createState() => _MediationBannerAdState();
}

class _MediationBannerAdState extends State<MediationBannerAdWidget> {
  final String _mediationUnitId =
      defaultTargetPlatform == TargetPlatform.android
          ? "27060aff4c8bcc8e7f897bc6385d870adbfe0738"
          : "08377f76c8b3e46c4ed36c82e434da2b394a4dfa";
  bool _isShowButton = false;

  // 광고 뷰
  Widget? adView;

  // 미디에이션 컨트롤
  EBMediationManager? _mediationManager;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mediation Banner Ad"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        adView = null;
                      });

                      // 미디에이션 초기화
                      _mediationManager = EBMediationManager(
                        mediationUnitId: _mediationUnitId,
                        mediationTypes: [
                          EBMediationTypes.exelbid,
                          // 사용할 미디에이션 네트워크 추가
                        ],
                        listener: EBPMediationListener(
                          onLoad: () {
                            // 미디에이션 목록 조회 성공
                            setState(() {
                              _isShowButton = true;
                            });
                            print(">>> onLoad");
                          },
                          onError: (EBError error) {
                            // 미디에이션 에러, 예외 처리
                            setState(() {
                              _isShowButton = false;
                            });
                            print(">>> onError : $error");
                          },
                          onEmpty: () {
                            print(">>> onEmpty");
                            // 미디에이션 목록이 비었을 경우 (순회 완료, 목록 없음)
                            setState(() {
                              _isShowButton = false;
                            });
                          },
                          onNext: (EBMediation mediation) {
                            print(">>> onNext : $mediation");

                            // 사용할 미디에이션 네트워크 체크 후 광고 요청
                            if (mediation.networkId ==
                                EBMediationTypes.exelbid) {
                              // 전달받은 unitId로 해당 네트워크 광고 요청
                              loadExelbid(mediation.unitId);
                            } else {
                              // 매칭되는 네트워크가 없으면 다음 미디에이션 요청
                              _mediationManager?.nextMediation();
                            }
                          },
                        ),
                      );
                    },
                    child: const Text('Load Mediation'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isShowButton
                        ? () {
                            // 미디에이션 정보 조회
                            _mediationManager?.nextMediation();
                          }
                        : null,
                    child: const Text('Next Mediation'),
                  ),
                ),
              ],
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
                      width: 320,
                      height: 50,
                      child: adView,
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

  void loadExelbid(String unitId) {
    print(">>> loadExelbid");
    // 광고 뷰 설정
    setState(() {
      adView = EBBannerAdView(
        adUnitId: unitId,
        listener: EBPBannerAdViewListener(
          onLoadAd: () {
            print("Banner onLoadAd");
          },
          onFailAd: (String? errorMessage) {
            print("Banner onFailAd");

            // 에러 또는 광고 없을 시 다음 미디에이션 요청
            _mediationManager?.nextMediation();
          },
          onClickAd: () {
            print("Banner onClickAd");
          },
        ),
      );
    });
  }
}
