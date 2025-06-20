import 'package:flutter/material.dart';

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

enum ObjectFit {
  fit,
  fill,
}

class EBBaseStyle {
  final Color? color;
  final Color? backgroundColor;
  final double? fontSize;
  final FontWeight? fontWeight;
  final FontStyle? fontStyle;
  final double? letterSpacing;
  final double? wordSpacing;
  final double? height;
  final String? fontFamily;
  final TextOverflow? overflow;
  final TextAlign? textAlign;
  final bool? softWrap;
  final int? maxLines;
  final Color? borderColor;
  final double? borderWidth;
  final double? borderRadius;
  final WidgetStateProperty<Size?>? minimumSize;
  final WidgetStateProperty<Size?>? fixedSize;
  final WidgetStateProperty<Size?>? maximumSize;
  final ObjectFit? objectFit;

  const EBBaseStyle({
    this.color,
    this.backgroundColor,
    this.fontSize,
    this.fontWeight,
    this.fontStyle,
    this.letterSpacing,
    this.wordSpacing,
    this.height,
    this.fontFamily,
    this.overflow,
    this.textAlign,
    this.softWrap,
    this.maxLines,
    this.borderColor,
    this.borderWidth,
    this.borderRadius,
    this.minimumSize,
    this.fixedSize,
    this.maximumSize,
    this.objectFit,
  });

  Map<String, dynamic> toMap() {
    return {
      "color": colorToHex(color),
      "background_color": colorToHex(backgroundColor),
      "font_size": fontSize,
      "font_weight": fontWeightToString(fontWeight),
      "font_style": fontStyle,
      "letter_spacing": letterSpacing,
      "word_spacing": wordSpacing,
      "height": height,
      "font_family": fontFamily,
      "overflow": overflow,
      "text_align": textAlign,
      "soft_wrap": softWrap,
      "max_lines": maxLines,
      "border_radius": borderRadius,
      "minimum_size": minimumSize,
      "fixed_size": fixedSize,
      "maximum_size": maximumSize,
      "object_fit": objectFit?.name
    };
  }

  String? colorToHex(Color? color) {
    if (color != null) {
      int r = (color.r * 255).round();
      int g = (color.g * 255).round();
      int b = (color.b * 255).round();

      return '#${r.toRadixString(16).padLeft(2, '0')}'
          '${g.toRadixString(16).padLeft(2, '0')}'
          '${b.toRadixString(16).padLeft(2, '0')}';
    }

    return null;
  }

  String fontWeightToString(FontWeight? fontWeight) {
    switch (fontWeight) {
      case FontWeight.w100:
        return 'ultraLight';
      case FontWeight.w200:
        return 'thin';
      case FontWeight.w300:
        return 'light';
      case FontWeight.w400:
        return 'regular';
      case FontWeight.w500:
        return 'medium';
      case FontWeight.w600:
        return 'semibold';
      case FontWeight.w700:
        return 'bold';
      case FontWeight.w800:
        return 'heavy';
      case FontWeight.w900:
        return 'black';
      default:
        return 'regular';
    }
  }
}

/// ViewStyle 지정 클래스
class EBViewStyle extends EBBaseStyle {
  const EBViewStyle({
    super.backgroundColor,
    super.borderRadius,
  });
}

class EBImageStyle extends EBBaseStyle {
  const EBImageStyle({
    super.backgroundColor,
    super.borderRadius,
    super.objectFit,
  });
}

/// TextStyle 지정 클래스
class EBTextStyle extends EBBaseStyle {
  const EBTextStyle({
    super.color,
    super.fontSize,
    super.fontWeight,
  });
}

/// ButtonStyle 지정 클래스
class EBButtonStyle extends EBBaseStyle {
  const EBButtonStyle({
    super.backgroundColor,
    super.borderRadius,
    super.color,
    super.fontSize,
    super.fontWeight,
  });
}
