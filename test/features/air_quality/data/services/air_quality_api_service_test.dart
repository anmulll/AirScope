import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:airscope/features/air_quality/data/services/air_quality_api_service.dart';
import 'package:airscope/features/air_quality/data/services/air_quality_api_exception.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';

void main() {
  const city = CityLocation(
    name: 'Makassar',
    country: 'Indonesia',
    admin1: 'South Sulawesi',
    latitude: -5.1477,
    longitude: 119.4327,
  );

  group('AirQualityApiService - City Search', () {
    test('searches cities successfully', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');
        expect(request.url.host, 'geocoding-api.open-meteo.com');
        expect(request.url.path, '/v1/search');

        expect(request.url.queryParameters['name'], 'Makassar');

        return http.Response(
          jsonEncode({
            'results': [
              {
                'name': 'Makassar',
                'country': 'Indonesia',
                'admin1': 'South Sulawesi',
                'latitude': -5.1477,
                'longitude': 119.4327,
              },
            ],
          }),
          200,
        );
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      final results = await service.searchCities('  Makassar  ');

      expect(results, hasLength(1));
      expect(results.first.name, 'Makassar');
      expect(results.first.country, 'Indonesia');
      expect(results.first.latitude, -5.1477);
    });

    test('returns empty list for short search query', () async {
      var requestCalled = false;

      final client = MockClient((request) async {
        requestCalled = true;
        return http.Response('{}', 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      final results = await service.searchCities(' A ');

      expect(results, isEmpty);
      expect(requestCalled, isFalse);
    });

    test('returns empty list when results are null', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'results': null}), 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      final results = await service.searchCities('Makassar');

      expect(results, isEmpty);
    });

    test('throws FormatException for invalid results format', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'results': 'invalid'}), 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(service.searchCities('Makassar'), throwsFormatException);
    });

    test('throws FormatException for invalid city item', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'results': ['invalid-city-data'],
          }),
          200,
        );
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(service.searchCities('Makassar'), throwsFormatException);
    });
  });

  group('AirQualityApiService - Air Quality', () {
    test('fetches air quality successfully', () async {
      final client = MockClient((request) async {
        expect(request.method, 'GET');

        expect(request.url.host, 'air-quality-api.open-meteo.com');

        expect(request.url.path, '/v1/air-quality');

        expect(request.url.queryParameters['latitude'], '-5.1477');

        expect(request.url.queryParameters['longitude'], '119.4327');

        expect(request.url.queryParameters['current'], 'us_aqi,pm2_5,pm10');

        return http.Response(
          jsonEncode({
            'current': {
              'time': '2026-11-12T10:00',
              'us_aqi': 42,
              'pm2_5': 8.5,
              'pm10': 12.3,
            },
          }),
          200,
        );
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      final result = await service.fetchAirQuality(city);

      expect(result.cityName, 'Makassar');
      expect(result.country, 'Indonesia');
      expect(result.usAqi, 42.0);
      expect(result.pm25, 8.5);
      expect(result.pm10, 12.3);
      expect(result.measuredAt, isNotNull);
    });

    test('throws API exception when current data is missing', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'hourly': {}}), 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(
        service.fetchAirQuality(city),
        throwsA(isA<AirQualityApiException>()),
      );
    });

    test(
      'throws API exception when all measurements are unavailable',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            jsonEncode({
              'current': {
                'time': '2026-11-12T10:00',
                'us_aqi': null,
                'pm2_5': null,
                'pm10': null,
              },
            }),
            200,
          );
        });

        addTearDown(client.close);

        final service = AirQualityApiService(client: client);

        expect(
          service.fetchAirQuality(city),
          throwsA(isA<AirQualityApiException>()),
        );
      },
    );
  });

  group('AirQualityApiService - Error Handling', () {
    test('handles HTTP server error', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'reason': 'Server maintenance'}), 503);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(
        service.searchCities('Makassar'),
        throwsA(isA<AirQualityApiException>()),
      );
    });

    test('handles API error response', () async {
      final client = MockClient((request) async {
        return http.Response(
          jsonEncode({'error': true, 'reason': 'Invalid API request'}),
          200,
        );
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(
        service.searchCities('Makassar'),
        throwsA(isA<AirQualityApiException>()),
      );
    });

    test('handles malformed JSON response', () async {
      final client = MockClient((request) async {
        return http.Response('{invalid-json', 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(service.searchCities('Makassar'), throwsFormatException);
    });

    test('handles non-object JSON response', () async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode(['invalid', 'response']), 200);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(service.searchCities('Makassar'), throwsFormatException);
    });

    test('handles network connection failure', () async {
      final client = MockClient((request) async {
        throw http.ClientException('No internet connection', request.url);
      });

      addTearDown(client.close);

      final service = AirQualityApiService(client: client);

      expect(
        service.searchCities('Makassar'),
        throwsA(isA<AirQualityApiException>()),
      );
    });

    test('handles request timeout', () async {
      final completer = Completer<http.Response>();

      final client = MockClient((request) {
        return completer.future;
      });

      addTearDown(client.close);

      final service = AirQualityApiService(
        client: client,
        timeout: const Duration(milliseconds: 20),
      );

      expect(
        service.searchCities('Makassar'),
        throwsA(isA<AirQualityApiException>()),
      );
    });
  });
}
