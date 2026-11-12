import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/domain/models/air_quality_data.dart';
import 'package:airscope/features/air_quality/domain/models/aqi_category.dart';

void main() {
  group('AirQualityData', () {
    test('creates AirQualityData from valid JSON', () {
      final data = AirQualityData.fromJson({
        'city_name': ' Makassar ',
        'country': 'Indonesia',
        'latitude': -5.1477,
        'longitude': 119.4327,
        'us_aqi': 42,
        'pm2_5': 8.5,
        'pm10': 12.3,
        'time': '2026-11-12T10:00',
      });

      expect(data.cityName, 'Makassar');
      expect(data.country, 'Indonesia');
      expect(data.latitude, -5.1477);
      expect(data.longitude, 119.4327);
      expect(data.usAqi, 42.0);
      expect(data.pm25, 8.5);
      expect(data.pm10, 12.3);
      expect(data.measuredAt, DateTime.parse('2026-11-12T10:00'));
    });

    test('throws FormatException for invalid city name', () {
      expect(
        () => AirQualityData.fromJson({
          'city_name': '',
          'latitude': -5.1477,
          'longitude': 119.4327,
        }),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid latitude', () {
      expect(
        () => AirQualityData.fromJson({
          'city_name': 'Makassar',
          'latitude': 100,
          'longitude': 119.4327,
        }),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid longitude', () {
      expect(
        () => AirQualityData.fromJson({
          'city_name': 'Makassar',
          'latitude': -5.1477,
          'longitude': 200,
        }),
        throwsFormatException,
      );
    });

    test('converts numeric strings into double values', () {
      final data = AirQualityData.fromJson({
        'city_name': 'Makassar',
        'latitude': '-5.1477',
        'longitude': '119.4327',
        'us_aqi': '42',
        'pm2_5': '8.5',
        'pm10': '12.3',
      });

      expect(data.usAqi, 42.0);
      expect(data.pm25, 8.5);
      expect(data.pm10, 12.3);
    });

    test('returns null for invalid optional numeric values', () {
      final data = AirQualityData.fromJson({
        'city_name': 'Makassar',
        'latitude': -5.1477,
        'longitude': 119.4327,
        'us_aqi': 'invalid',
        'pm2_5': double.nan,
        'pm10': null,
      });

      expect(data.usAqi, isNull);
      expect(data.pm25, isNull);
      expect(data.pm10, isNull);
    });

    test('returns null for invalid measurement time', () {
      final data = AirQualityData.fromJson({
        'city_name': 'Makassar',
        'latitude': -5.1477,
        'longitude': 119.4327,
        'time': 'invalid-date',
      });

      expect(data.measuredAt, isNull);
    });

    test('converts AirQualityData into JSON', () {
      final measuredAt = DateTime.parse('2026-11-12T10:00');

      const data = AirQualityData(
        cityName: 'Makassar',
        country: 'Indonesia',
        latitude: -5.1477,
        longitude: 119.4327,
        usAqi: 42,
        pm25: 8.5,
        pm10: 12.3,
        measuredAt: null,
      );

      final dataWithTime = AirQualityData(
        cityName: data.cityName,
        country: data.country,
        latitude: data.latitude,
        longitude: data.longitude,
        usAqi: data.usAqi,
        pm25: data.pm25,
        pm10: data.pm10,
        measuredAt: measuredAt,
      );

      final json = dataWithTime.toJson();

      expect(json['city_name'], 'Makassar');
      expect(json['country'], 'Indonesia');
      expect(json['latitude'], -5.1477);
      expect(json['longitude'], 119.4327);
      expect(json['us_aqi'], 42.0);
      expect(json['pm2_5'], 8.5);
      expect(json['pm10'], 12.3);
      expect(json['time'], measuredAt.toIso8601String());
    });

    test('returns correct AQI category', () {
      const data = AirQualityData(
        cityName: 'Makassar',
        latitude: -5.1477,
        longitude: 119.4327,
        usAqi: 42,
      );

      expect(data.aqiCategory, AqiCategory.good);
    });

    test('detects available particulate matter data', () {
      const data = AirQualityData(
        cityName: 'Makassar',
        latitude: -5.1477,
        longitude: 119.4327,
        pm25: 8.5,
      );

      expect(data.hasParticulateMatterData, isTrue);
    });

    test('returns false when particulate data is unavailable', () {
      const data = AirQualityData(
        cityName: 'Makassar',
        latitude: -5.1477,
        longitude: 119.4327,
      );

      expect(data.hasParticulateMatterData, isFalse);
    });
  });
}
