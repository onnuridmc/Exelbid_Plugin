import 'gender.dart';

class AdOptions {
  AdOptions({
    this.keywords = const {},
    this.yearOfBirth,
    this.gender = Gender.unspecified,
    this.location,
    this.coppa = false,
    this.testing = false,
    this.videoSkipMin,
    this.videoSkipAfter,
  });

  final Map<String, String> keywords;
  final int? yearOfBirth;
  final Gender gender;
  final AdLocation? location;
  final bool coppa;
  final bool testing;
  final int? videoSkipMin;
  final int? videoSkipAfter;

  Map<String, Object?> toMap() => {
        'keywords': keywords,
        'yearOfBirth': yearOfBirth ?? 0,
        'gender': gender.rawValue,
        'location': location?.toMap(),
        'coppa': coppa,
        'testing': testing,
        if (videoSkipMin != null) 'videoSkipMin': videoSkipMin,
        if (videoSkipAfter != null) 'videoSkipAfter': videoSkipAfter,
      };
}

class AdLocation {
  const AdLocation({required this.latitude, required this.longitude});

  final double latitude;
  final double longitude;

  Map<String, double> toMap() => {
        'latitude': latitude,
        'longitude': longitude,
      };
}
