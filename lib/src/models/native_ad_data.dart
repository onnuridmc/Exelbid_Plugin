/// 로드 시 전달되는 네이티브 광고 에셋 값의 스냅샷.
///
/// 호스트 렌더링 슬롯([ExelbidNativeAdTitle], [ExelbidNativeAdMainImage], …)은
/// SDK가 직접 채우므로 보통은 이 값들이 필요하지 않다. 이 값들은 렌더링
/// 슬롯이 없는 **데이터 전용 에셋**(`secondaryBody`, `phone`, `address`,
/// `rating`, `likes`, `downloads`, `price`, `salePrice`)에 유용하며, 일반
/// Flutter 위젯으로 직접 레이아웃할 수 있다.
class ExelbidNativeAdData {
  const ExelbidNativeAdData({
    this.title,
    this.body,
    this.secondaryBody,
    this.callToAction,
    this.sponsored,
    this.displayUrl,
    this.phone,
    this.address,
    this.iconImageUrl,
    this.mainImageUrl,
    this.logoImageUrl,
    this.rating,
    this.likes,
    this.downloads,
    this.price,
    this.salePrice,
    this.hasVideo = false,
  });

  final String? title;
  final String? body;
  final String? secondaryBody;
  final String? callToAction;
  final String? sponsored;
  final String? displayUrl;
  final String? phone;
  final String? address;
  final String? iconImageUrl;
  final String? mainImageUrl;
  final String? logoImageUrl;
  final String? rating;
  final String? likes;
  final String? downloads;
  final String? price;
  final String? salePrice;
  final bool hasVideo;

  factory ExelbidNativeAdData.fromMap(Map<Object?, Object?> map) {
    String? s(String k) => map[k] as String?;
    return ExelbidNativeAdData(
      title: s('title'),
      body: s('body'),
      secondaryBody: s('secondaryBody'),
      callToAction: s('callToAction'),
      sponsored: s('sponsored'),
      displayUrl: s('displayUrl'),
      phone: s('phone'),
      address: s('address'),
      iconImageUrl: s('iconImageUrl'),
      mainImageUrl: s('mainImageUrl'),
      logoImageUrl: s('logoImageUrl'),
      rating: s('rating'),
      likes: s('likes'),
      downloads: s('downloads'),
      price: s('price'),
      salePrice: s('salePrice'),
      hasVideo: map['hasVideo'] as bool? ?? false,
    );
  }
}
