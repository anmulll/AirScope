import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../domain/models/air_quality_data.dart';
import '../../domain/models/city_location.dart';
import 'air_quality_api_exception.dart';

class AirQualityApiService {
  AirQualityApiService({
    http.Client? client,
    this._timeout = const Duration(seconds: 15),
  }) : _client = client ?? http.Client(),
       _ownsClient = client == null;

  final http.Client _client;
  final bool _ownsClient;
  final Duration _timeout;

  static const String _geocodingHost = 'geocoding-api.open-meteo.com';

  static const String _airQualityHost = 'air-quality-api.open-meteo.com';

  /// Mencari lokasi berdasarkan nama kota.
  Future<List<CityLocation>> searchCities(String query) async {
    final normalizedQuery = query.trim();

    if (normalizedQuery.length < 2) {
      return const [];
    }

    final uri = Uri.https(_geocodingHost, '/v1/search', {
      'name': normalizedQuery,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final json = await _getJson(uri);

    final results = json['results'];

    if (results == null) {
      return const [];
    }

    if (results is! List) {
      throw const FormatException('Format hasil pencarian lokasi tidak valid.');
    }

    return results
        .map((item) {
          if (item is! Map<String, dynamic>) {
            throw const FormatException('Data lokasi tidak valid.');
          }

          return CityLocation.fromJson(item);
        })
        .toList(growable: false);
  }

  /// Mengambil kualitas udara berdasarkan lokasi.
  Future<AirQualityData> fetchAirQuality(CityLocation location) async {
    final uri = Uri.https(_airQualityHost, '/v1/air-quality', {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'us_aqi,pm2_5,pm10',
      'timezone': 'auto',
    });

    final json = await _getJson(uri);

    final current = json['current'];

    if (current is! Map<String, dynamic>) {
      throw const AirQualityApiException('Data kualitas udara tidak tersedia.');
    }

    final normalizedData = {
      'city_name': location.name,
      'country': location.country,
      'latitude': location.latitude,
      'longitude': location.longitude,
      'us_aqi': current['us_aqi'],
      'pm2_5': current['pm2_5'],
      'pm10': current['pm10'],
      'time': current['time'],
    };

    final airQuality = AirQualityData.fromJson(normalizedData);

    if (airQuality.usAqi == null &&
        airQuality.pm25 == null &&
        airQuality.pm10 == null) {
      throw const AirQualityApiException(
        'Tidak ada data kualitas udara yang tersedia.',
      );
    }

    return airQuality;
  }

  /// Mengirim HTTP GET dan membaca respons JSON.
  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    try {
      final response = await _client.get(uri).timeout(_timeout);

      final decoded = jsonDecode(utf8.decode(response.bodyBytes));

      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Respons server tidak valid.');
      }

      if (response.statusCode < 200 || response.statusCode >= 300) {
        final reason = decoded['reason'];

        throw AirQualityApiException(
          reason is String
              ? reason
              : 'Server mengembalikan status '
                    '${response.statusCode}.',
        );
      }

      if (decoded['error'] == true) {
        final reason = decoded['reason'];

        throw AirQualityApiException(
          reason is String ? reason : 'Terjadi kesalahan pada Open-Meteo.',
        );
      }

      return decoded;
    } on TimeoutException {
      throw const AirQualityApiException(
        'Permintaan API melewati batas waktu. '
        'Periksa koneksi internet.',
      );
    } on http.ClientException {
      throw const AirQualityApiException(
        'Tidak dapat terhubung ke Open-Meteo. '
        'Periksa koneksi internet.',
      );
    }
  }

  /// Menutup HTTP client jika dibuat oleh service ini.
  void close() {
    if (_ownsClient) {
      _client.close();
    }
  }
}
