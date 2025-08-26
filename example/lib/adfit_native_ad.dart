import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AdfitNativeAdWidget extends StatefulWidget {
  const AdfitNativeAdWidget({super.key});

  @override
  AdfitNativeAdState createState() => AdfitNativeAdState();
}

class AdfitNativeAdState extends State<AdfitNativeAdWidget> {
  final String NATIVE_VIEW_TYPE = "adfit/native_ad";
  final String _adfitClientId = defaultTargetPlatform == TargetPlatform.android
      ? "<<Ad Client ID>>"
      : "<<Ad Client ID>>";
  bool _isShow = false;
  MethodChannel? methodChannel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Native Ad"),
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
                      width: double.infinity,
                      height: 300,
                      color: Color.fromARGB(255, 240, 240, 240),
                      child: _isShow ? makeAdfitNativeAd(context) : null,
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

  Widget makeAdfitNativeAd(BuildContext context) {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AndroidView(
        viewType: NATIVE_VIEW_TYPE,
        creationParams: createParams(),
        creationParamsCodec: const StandardMessageCodec(),
        onPlatformViewCreated: onPlatformViewCreated,
      );
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      return UiKitView(
        viewType: NATIVE_VIEW_TYPE,
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
    methodChannel = MethodChannel('${NATIVE_VIEW_TYPE}_$id');
    methodChannel?.setMethodCallHandler(handleMethodChannel);
    methodChannel?.invokeMethod("loadAd", createParams());
  }

  Future<void> handleMethodChannel(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      if ("onLoadAd" == method) {
        print(">>> onLoadAd");
      } else if ("onFailAd" == method) {
        print(">>> onFailAd");
      } else {
        debugPrint('No MethodChannel : $method');
      }
    } catch (e) {
      debugPrint('Error MethodChannel ${call.method} : $e');
    }
  }
}
