import 'package:exelbid_plugin/ad_classes.dart';
import 'package:exelbid_plugin/ad_listener.dart';
import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

typedef MediationResponseHandler = void Function();

class EBMediationManager {
  final String mediationUnitId;
  final List<String> mediationTypes;
  final EBPMediationListener listener;

  late final MethodChannel _methodChannel;

  EBMediationManager({
    required this.mediationUnitId,
    required this.mediationTypes,
    required this.listener,
  }) {
    _methodChannel = MethodChannel('exelbid_plugin/mediation_$mediationUnitId');
    _methodChannel.setMethodCallHandler(_handleMethodChannel);

    ExelbidPlugin.shared.callInvokeMethod('initMediation', {
      'mediation_unit_id': mediationUnitId,
      'mediation_types': mediationTypes,
    });
  }

  Future<void> _handleMethodChannel(MethodCall call) async {
    try {
      final String method = call.method;
      final Map<dynamic, dynamic>? arguments = call.arguments;

      if (method == "onFailMediation") {
        final errorCode = arguments?['error_code'] as String? ?? "0";
        final errorMessage = arguments?['error_message'] as String?;
        listener.onError(EBError(code: errorCode, message: errorMessage));
      } else {
        throw MissingPluginException('No MethodChannel : $method');
      }
    } catch (e) {
      debugPrint('Error MethodChannel ${call.method} : $e');
    }
  }

  Future<void> loadMediation() async {
    try {
      if (await _methodChannel.invokeMethod('loadMediation')) {
        listener.onLoad();
      } else {
        listener.onEmpty();
      }
    } on PlatformException catch (e) {
      listener.onError(EBError(code: e.code, message: e.message));
    }
  }

  Future<void> nextMediation() async {
    try {
      final result = await _methodChannel.invokeMethod('nextMediation');
      if (result != null) {
        listener.onNext(EBMediation.fromJson(result));
      } else {
        listener.onEmpty();
      }
    } on PlatformException catch (e) {
      listener.onError(EBError(code: e.code, message: e.message));
    }
  }
}
