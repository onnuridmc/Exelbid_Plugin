import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InterstitialVideoAdWidget extends StatefulWidget {
  const InterstitialVideoAdWidget({super.key});

  @override
  _InterstitialVideoAdState createState() => _InterstitialVideoAdState();
}

class _InterstitialVideoAdState extends State<InterstitialVideoAdWidget> {
  final String _adUnitId = defaultTargetPlatform == TargetPlatform.android
      ? "c73ca366de62a253f847b737c78a4b905d8825de"
      : "3f548c41c3c6539ee7051aeb58ada2d4c039bc07";
  bool _isLoadButton = true;
  bool _isShowButton = false;

  final _channel = MethodChannel('sample');

  _InterstitialVideoAdState() {
    _channel.setMethodCallHandler(_handleMethodCall);

    // Set Interstitial Video Listener
    ExelbidPlugin.shared.setVideoListener(EBPVideoAdViewListener(
      onLoadAd: () {
        print('Interstitial Video onLoadAd');
        setState(() {
          _isShowButton = true;
        });
      },
      onFailAd: (String? errorMessage) {
        print('Interstitial Video onFailAd : $errorMessage');
      },
      onFailToPlay: (errorMessage) {
        print('Interstitial Video onFailToPlay : $errorMessage');
      },
      onClickAd: () {
        print('Interstitial Video onClickAd');
      },
      onShow: () {
        print('onInterstitial Video Show');
      },
      onDismiss: () {
        print('onInterstitial Video Dismiss');
        setState(() {
          _isLoadButton = true;
          _isShowButton = false;
        });
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Interstitial Video Ad"),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoadButton
                        ? () {
                            ExelbidPlugin.shared.loadInterstitialVideo(
                              adUnitId: _adUnitId,
                              isTest: true,
                              coppa: false,
                              timer: 5,
                            );
                            setState(() {
                              _isLoadButton = false;
                            });
                          }
                        : null,
                    child: const Text('Load Ad'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isShowButton
                        ? () {
                            ExelbidPlugin.shared.showInterstitialVideo();
                          }
                        : null,
                    child: const Text('Show Ad'),
                  ),
                ),
              ],
            ),
          ),
          const Expanded(
            child: SizedBox(),
          ),
        ],
      ),
    );
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      final methodHandlers = {"": () => {}};

      final handler = methodHandlers[method];
      if (handler != null) {
        handler();
      } else {
        debugPrint('Unhandled method: $method');
      }
    } catch (e) {
      print(
        'Error handling native method call ${call.method} with arguments ${call.arguments}: $e',
      );
    }
  }
}
