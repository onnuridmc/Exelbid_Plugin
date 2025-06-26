import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdfitBannerAdWidget extends StatefulWidget {
  const AdfitBannerAdWidget({super.key});

  @override
  AdfitBannerAdState createState() => AdfitBannerAdState();
}

class AdfitBannerAdState extends State<AdfitBannerAdWidget> {
  final String BANNER_VIEW_TYPE = "adfit/banner_ad";
  final String _adfitClientId = defaultTargetPlatform == TargetPlatform.android
      ? "DAN-UjXXfGZx5g7oUcFN"
      : "DAN-2STczol2v1EEctGu";
  bool _isShow = false;
  MethodChannel? methodChannel;

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
                      color: Color.fromARGB(255, 240, 240, 240),
                      child: _isShow ? makeAdfitBannerAd(context) : null,
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

  Widget makeAdfitBannerAd(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: BANNER_VIEW_TYPE,
        creationParams: createParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: BANNER_VIEW_TYPE,
        creationParams: createParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    }

    return Container();
  }

  Map<String, dynamic> createParams() {
    return {"client_id": _adfitClientId};
  }

  void onPlatformViewCreated(int id) {
    methodChannel = MethodChannel('${BANNER_VIEW_TYPE}_$id');
    methodChannel?.setMethodCallHandler(handleMethodChannel);
  }

  Future<void> handleMethodChannel(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      if ("onLoadAd" == method) {
        print(">>> onLoadAd");
      } else if ("onFailAd" == method) {
        print(">>> onFailAd");
      } else if ("onClickAd" == method) {
        print(">>> onClickAd");
      } else {
        throw MissingPluginException('No MethodChannel : $method');
      }
    } catch (e) {
      debugPrint('Error MethodChannel ${call.method} : $e');
    }
  }
}
