/// `ExelBidSDK.NativeAsset`를 따른다. raw 값은 ObjC 브리지 정수와 일치한다.
enum NativeAsset {
  title(0),
  desc(1),
  desc2(2),
  ctatext(3),
  sponsored(4),
  displayUrl(5),
  phone(6),
  address(7),
  icon(8),
  main(9),
  logo(10),
  rating(11),
  likes(12),
  downloads(13),
  price(14),
  salePrice(15),
  video(16);

  const NativeAsset(this.rawValue);

  final int rawValue;
}
