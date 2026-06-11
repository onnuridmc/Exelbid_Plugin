sealed class AdError implements Exception {
  const AdError(this.message);

  final String message;

  factory AdError.fromMap(Map<Object?, Object?> map) {
    final code = map['code'] as int? ?? 0;
    final message = map['message'] as String? ?? '';
    return switch (code) {
      1 => InvalidAdUnitIdError(message),
      2 => NoFillError(message),
      3 => NetworkAdError(message),
      4 => HttpStatusAdError(
          message,
          statusCode: map['statusCode'] as int? ?? 0,
        ),
      5 => DecodingAdError(message),
      6 => VastParsingAdError(message),
      7 => MediaFileUnavailableError(message),
      8 => PlaybackAdError(message),
      9 => NotReadyAdError(message),
      10 => CanceledAdError(message),
      _ => UnknownAdError(message, code: code),
    };
  }

  @override
  String toString() => '$runtimeType: $message';
}

class InvalidAdUnitIdError extends AdError {
  const InvalidAdUnitIdError(super.message);
}

class NoFillError extends AdError {
  const NoFillError(super.message);
}

class NetworkAdError extends AdError {
  const NetworkAdError(super.message);
}

class HttpStatusAdError extends AdError {
  const HttpStatusAdError(super.message, {required this.statusCode});

  final int statusCode;
}

class DecodingAdError extends AdError {
  const DecodingAdError(super.message);
}

class VastParsingAdError extends AdError {
  const VastParsingAdError(super.message);
}

class MediaFileUnavailableError extends AdError {
  const MediaFileUnavailableError(super.message);
}

class PlaybackAdError extends AdError {
  const PlaybackAdError(super.message);
}

class NotReadyAdError extends AdError {
  const NotReadyAdError(super.message);
}

class CanceledAdError extends AdError {
  const CanceledAdError(super.message);
}

class UnknownAdError extends AdError {
  const UnknownAdError(super.message, {required this.code});

  final int code;
}
