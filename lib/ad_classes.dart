class EBMediation {
  final String networkId;
  final String unitId;

  EBMediation({required this.networkId, required this.unitId});

  EBMediation.fromJson(Map<dynamic, dynamic> json)
      : networkId = json['network_id'] as String,
        unitId = json['unit_id'] as String;

  @override
  String toString() {
    return 'EBMediation { ne-tworkId: $networkId, unitId: $unitId }';
  }
}

class EBNativeData {
  final String title;
  final String description;
  final String callToAction;

  EBNativeData.fromJson(Map<dynamic, dynamic> json)
      : title = json['title'] as String,
        description = json['desc'] as String,
        callToAction = json['ctatext'] as String;

  @override
  String toString() {
    return 'EBNativeData { title: $title, description: $description, callToAction: $callToAction }';
  }
}

class EBError {
  final String code;
  final String? message;

  EBError({required this.code, this.message});

  @override
  String toString() {
    return 'EBError : {code: $code, message: $message}';
  }
}

class EBMediationTypes {
  static const String exelbid = "exelbid";
  static const String admob = "admob";
  static const String facebook = "fan";
  static const String adfit = "adfit";
  static const String digitalturbine = "dt";
  static const String pangle = "pangle";
  static const String applovin = "applovin";
  static const String tnk = "tnk";
  static const String targetpick = "targetpick";
  static const String mpartners = "mp";
}

class EBNativeAssets {
  static const String title = "title";
  static const String icon = "icon";
  static const String main = "main";
  static const String video = "video";
  static const String desc = "desc";
  static const String ctatext = "ctatext";
}

enum ATTStatus { NotDetermined, Restricted, Denied, Authorized, Unknown }

extension IntExtension on int {
  ATTStatus toATTStatus() {
    switch (this) {
      case 0:
        return ATTStatus.NotDetermined;
      case 1:
        return ATTStatus.Restricted;
      case 2:
        return ATTStatus.Denied;
      case 3:
        return ATTStatus.Authorized;
      default:
        return ATTStatus.Unknown;
    }
  }
}
