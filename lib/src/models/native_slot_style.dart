import 'package:flutter/widgets.dart';

/// 네이티브 광고 슬롯의 기반 네이티브 뷰에 적용되는 시각적 스타일.
///
/// 호스트 렌더링 네이티브 광고에서 SDK는 텍스트를 네이티브 `UILabel`에,
/// 이미지를 네이티브 `UIImageView`에 채운다 — Flutter 슬롯 위젯 자체는 빈
/// 박스다. 따라서 이러한 에셋의 폰트/색상/배경/모서리 스타일은 네이티브에서
/// 적용해야 한다. 이 객체는 그 스타일을 Dart에서 네이티브 렌더링 뷰로
/// 전달하며, 각 슬롯의 측정된 프레임과 함께 보내진다.
///
/// 필드는 선택 사항이다 — 설정한 것만 적용되고 나머지는 네이티브 기본값으로
/// 남는다. 텍스트 필드([textColor], [fontSize], [fontWeight],
/// [textAlign], [maxLines])는 텍스트 슬롯(제목, 설명, CTA)에 적용된다.
/// [contentMode]는 이미지 슬롯(아이콘, 메인 이미지, 개인정보 아이콘)에
/// 적용된다. 박스 필드([backgroundColor], [cornerRadius], [borderWidth],
/// [borderColor])는 모든 슬롯에 적용된다.
@immutable
class ExelbidNativeSlotStyle {
  const ExelbidNativeSlotStyle({
    this.textColor,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.maxLines,
    this.overflow,
    this.padding,
    this.backgroundColor,
    this.cornerRadius,
    this.borderWidth,
    this.borderColor,
    this.contentMode,
  });

  /// 텍스트 색상(텍스트 슬롯).
  final Color? textColor;

  /// 폰트 패밀리 이름(텍스트 슬롯).
  ///
  /// 이 이름은 Flutter뿐 아니라 **네이티브 플랫폼**이 인식하는 폰트로
  /// 해석되어야 한다. iOS에서는 시스템 폰트 패밀리(예: `'Georgia'`)이거나
  /// iOS 앱에 번들되어 `Info.plist`의 `UIAppFonts`로 등록된 커스텀 폰트를
  /// 의미한다 — `pubspec.yaml`의 `fonts:` 선언만으로는 네이티브 `UILabel`에서
  /// 보이지 않는다. 알 수 없는 이름은 시스템 폰트로 대체된다.
  final String? fontFamily;

  /// 폰트 포인트 크기(텍스트 슬롯).
  final double? fontSize;

  /// 폰트 굵기(텍스트 슬롯). 네이티브 폰트 굵기로 매핑된다.
  final FontWeight? fontWeight;

  /// 가로 텍스트 정렬(텍스트 슬롯).
  final TextAlign? textAlign;

  /// 최대 줄 수. `0`은 무제한을 의미한다(텍스트 슬롯).
  final int? maxLines;

  /// [maxLines] / 슬롯 너비를 초과하는 텍스트를 처리하는 방식(텍스트 슬롯).
  ///
  /// 네이티브 라벨의 잘림(truncation) 모드로 매핑된다:
  /// - [TextOverflow.clip] — 표시 없이 깔끔하게 잘라낸다
  ///   (iOS `byClipping` / Android `ellipsize = null`).
  /// - [TextOverflow.ellipsis] — 끝에 `…`를 붙인다
  ///   (iOS `byTruncatingTail` / Android `TruncateAt.END`).
  /// - [TextOverflow.fade] — 가장자리에서 페이드 아웃한다. 최선 노력 처리:
  ///   Android에서는 실제 페이드(가로 fading edge)가 적용되고, iOS는 라벨
  ///   페이드가 없어 `…`로 대체된다.
  /// - [TextOverflow.visible] — 잘라내지 않는다. 단, 네이티브 라벨은 여전히
  ///   자신의 경계로 클리핑되므로 [TextOverflow.clip]처럼 동작한다.
  ///
  /// 설정하지 않으면 네이티브 기본값이 적용된다(iOS는 `…` 표시, Android는 클립).
  final TextOverflow? overflow;

  /// 슬롯의 가장자리와 텍스트 사이의 내부 패딩(텍스트 슬롯).
  ///
  /// 배경/테두리는 슬롯 프레임 전체를 채우는 반면 텍스트는 이만큼 안쪽으로
  /// 들여진다 — 버튼 형태의 call-to-action 슬롯에 유용하다. 네이티브 라벨(iOS)
  /// / `TextView`(Android)에 적용되며, 이미지 슬롯에서는 무시된다. 값은 논리
  /// 픽셀 단위다. 슬롯이 기본 예약 높이에 의존하는 경우, 텍스트가 잘리지 않도록
  /// 세로 패딩이 그 위에 더해진다.
  final EdgeInsets? padding;

  /// 슬롯 네이티브 뷰의 채움 색상(모든 슬롯).
  final Color? backgroundColor;

  /// 모서리 반경(논리 포인트 단위). 뷰를 클리핑한다(모든 슬롯).
  final double? cornerRadius;

  /// 테두리 두께(논리 포인트 단위)(모든 슬롯).
  final double? borderWidth;

  /// 테두리 색상(모든 슬롯).
  final Color? borderColor;

  /// 이미지 에셋이 슬롯을 채우는 방식(이미지 슬롯).
  final BoxFit? contentMode;

  Map<String, Object?> toMap() => <String, Object?>{
        if (textColor != null) 'textColor': _argb(textColor!),
        if (fontFamily != null) 'fontFamily': fontFamily,
        if (fontSize != null) 'fontSize': fontSize,
        if (fontWeight != null) 'fontWeight': fontWeight!.value,
        if (textAlign != null) 'textAlign': _textAlignName(textAlign!),
        if (maxLines != null) 'maxLines': maxLines,
        if (overflow != null) 'overflow': _overflowName(overflow!),
        if (padding != null)
          'padding': <String, double>{
            'left': padding!.left,
            'top': padding!.top,
            'right': padding!.right,
            'bottom': padding!.bottom,
          },
        if (backgroundColor != null) 'backgroundColor': _argb(backgroundColor!),
        if (cornerRadius != null) 'cornerRadius': cornerRadius,
        if (borderWidth != null) 'borderWidth': borderWidth,
        if (borderColor != null) 'borderColor': _argb(borderColor!),
        if (contentMode != null) 'contentMode': _boxFitName(contentMode!),
      };

  static int _argb(Color c) => c.toARGB32();

  static String _textAlignName(TextAlign a) {
    switch (a) {
      case TextAlign.left:
      case TextAlign.start:
        return 'left';
      case TextAlign.right:
      case TextAlign.end:
        return 'right';
      case TextAlign.center:
        return 'center';
      case TextAlign.justify:
        return 'justify';
    }
  }

  static String _overflowName(TextOverflow o) {
    switch (o) {
      case TextOverflow.clip:
        return 'clip';
      case TextOverflow.ellipsis:
        return 'ellipsis';
      case TextOverflow.fade:
        return 'fade';
      case TextOverflow.visible:
        return 'visible';
    }
  }

  static String _boxFitName(BoxFit fit) {
    switch (fit) {
      case BoxFit.fill:
        return 'fill';
      case BoxFit.cover:
        return 'cover';
      case BoxFit.contain:
        return 'contain';
      case BoxFit.fitWidth:
      case BoxFit.fitHeight:
      case BoxFit.none:
      case BoxFit.scaleDown:
        return 'center';
    }
  }
}
