class AirQualityApiException implements Exception {
  final String message;

  const AirQualityApiException(this.message);

  @override
  String toString() {
    return 'AirQualityApiException: $message';
  }
}
