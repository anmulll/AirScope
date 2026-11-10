import 'aqi_category.dart';

class AirQualityData {
  final String cityName;
  final String? country;

  final double latitude;
  final double longitude;

  final double? usAqi;
  final double? pm25;
  final double? pm10;

  final DateTime? measuredAt;

  const AirQualityData({
    required this.cityName,
    this.country,
    required this.latitude,
    required this.longitude,
    this.usAqi,
    this.pm25,
    this.pm10,
    this.measuredAt,
  });

  /// Mengubah JSON yang sudah dinormalisasi menjadi objek AirQualityData.
  factory AirQualityData.fromJson(Map<String, dynamic> json) {
    final cityName = json['city_name'];
    final latitude = _toDouble(json['latitude']);
    final longitude = _toDouble(json['longitude']);

    if (cityName is! String || cityName.trim().isEmpty) {
      throw const FormatException('Nama kota tidak valid.');
    }

    if (latitude == null || latitude < -90 || latitude > 90) {
      throw const FormatException('Koordinat latitude tidak valid.');
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      throw const FormatException('Koordinat longitude tidak valid.');
    }

    return AirQualityData(
      cityName: cityName.trim(),
      country: json['country'] is String ? json['country'] : null,
      latitude: latitude,
      longitude: longitude,
      usAqi: _toDouble(json['us_aqi']),
      pm25: _toDouble(json['pm2_5']),
      pm10: _toDouble(json['pm10']),
      measuredAt: json['time'] is String
          ? DateTime.tryParse(json['time'] as String)
          : null,
    );
  }

  /// Mengubah objek menjadi format JSON.
  Map<String, dynamic> toJson() {
    return {
      'city_name': cityName,
      'country': country,
      'latitude': latitude,
      'longitude': longitude,
      'us_aqi': usAqi,
      'pm2_5': pm25,
      'pm10': pm10,
      'time': measuredAt?.toIso8601String(),
    };
  }

  /// Menghasilkan kategori kualitas udara.
  AqiCategory get aqiCategory {
    return AqiCategory.fromUsAqi(usAqi);
  }

  /// Memeriksa apakah data partikulat tersedia.
  bool get hasParticulateMatterData {
    return pm25 != null || pm10 != null;
  }

  /// Mengubah nilai numerik JSON menjadi double.
  static double? _toDouble(dynamic value) {
    if (value is num && value.isFinite) {
      return value.toDouble();
    }

    if (value is String) {
      final parsed = double.tryParse(value);

      if (parsed != null && parsed.isFinite) {
        return parsed;
      }
    }

    return null;
  }
}
