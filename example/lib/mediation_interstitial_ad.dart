import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:exelbid_plugin/exelbid_mediation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediationInterstitialAdWidget extends StatefulWidget {
  const MediationInterstitialAdWidget({super.key});

  @override
  _MediationInterstitialAdState createState() =>
      _MediationInterstitialAdState();
}

class _MediationInterstitialAdState
    extends State<MediationInterstitialAdWidget> {
  final String _mediationUnitId =
      defaultTargetPlatform == TargetPlatform.android
          ? "94ed378f4b99783cf9ff15e1f428bd2250191cc4"
          : "615217b82a648b795040baee8bc81986a71d0eb7";
  bool _isLoadButton = true;
  bool _isShowButton = false;

  // 미디에이션 컨트롤
  late final EBMediationManager _mediationManager;

  _MediationInterstitialAdState() {
    // Exelbid 전면광고 초기화
    initExelbid();

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
            // 사용할 미디에이션 네트워크 체크 후 광고 요청
            if (mediation.networkId == EBMediationTypes.exelbid) {
              // 전달받은 unitId로 해당 네트워크 광고 요청
              loadExelbid(mediation.unitId);
            } else {
              // 매칭되는 네트워크가 없으면 다음 미디에이션 요청
              _mediationManager.nextMediation();
            }

            print(">>> onNext");
          },
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Mediation Interstitial Ad"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.start, children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child:
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // 미디에이션 목록 조회
                  _mediationManager.loadMediation();
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
                        _mediationManager.nextMediation();
                      }
                    : null,
                child: const Text('Next Mediation'),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void initExelbid() {
    // 전면 광고 콜백 리스너 설정
    ExelbidPlugin.shared
        .setInterstitialListener(EBPInterstitialAdViewListener(onLoadAd: () {
      print('Interstitial onLoadAd');
      ExelbidPlugin.shared.showInterstitial();
    }, onFailAd: (String? errorMessage) {
      print('Interstitial onFailAd : $errorMessage');
      // 오류 시 다음 미디에이션 요청
      _mediationManager.nextMediation();
    }, onClickAd: () {
      print('Interstitial onClickAd');
    }, onInterstitialShow: () {
      print('onInterstitialShow');
    }, onInterstitialDismiss: () {
      print('onInterstitialDismiss');
    }));
  }

  void loadExelbid(String unitId) {
    // Exelbid 전면 광고 요청
    ExelbidPlugin.shared.loadInterstitial(adUnitId: unitId);
  }
}
