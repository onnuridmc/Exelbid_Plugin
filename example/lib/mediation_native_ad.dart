import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/native_ad_view.dart';
import 'package:exelbid_plugin/exelbid_mediation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MediationNativeAdWidget extends StatefulWidget {
  const MediationNativeAdWidget({super.key});

  @override
  _MediationNativeAdState createState() => _MediationNativeAdState();
}

class _MediationNativeAdState extends State<MediationNativeAdWidget> {
  final String _mediationUnitId =
      defaultTargetPlatform == TargetPlatform.android
          ? "d7b20997ed5f925e617c33a5b198bdce6fcf04b0"
          : "5792d262715cbd399d6910200437b40a95dcc0f6";
  bool _isShowButton = false;

  // 광고 뷰
  Widget? adView;

  // 미디에이션 컨트롤
  late final EBMediationManager _mediationManager;

  _MediationNativeAdState() {
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
        title: const Text("Mediation Native Ad"),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
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
                  child: adView,
                ),
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  void loadExelbid(String unitId) {
    setState(() {
      // 광고 뷰 설정
      adView = EBNativeAdView(
        adUnitId: unitId,
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
              child: EBNativeAdTtitle(),
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
                    child: EBNativeAdPrivacyInformationIconImage(
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
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: const EBNativeAdCallToAction(
                style: ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(Colors.white),
                  textStyle: WidgetStatePropertyAll<TextStyle>(
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ),
          ),
        ]),
      );
    });
  }
}
