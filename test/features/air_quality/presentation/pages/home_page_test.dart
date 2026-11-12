import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:airscope/features/air_quality/data/services/air_quality_api_service.dart';
import 'package:airscope/features/air_quality/data/services/local_storage_service.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';
import 'package:airscope/features/air_quality/presentation/pages/home_page.dart';
import 'package:airscope/features/air_quality/presentation/widgets/city_search_result_tile.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const city = CityLocation(
    name: 'Makassar',
    country: 'Indonesia',
    admin1: 'South Sulawesi',
    latitude: -5.1477,
    longitude: 119.4327,
  );

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestApp(http.Client client) {
    return MaterialApp(
      home: HomePage(
        apiService: AirQualityApiService(client: client),
        storageService: LocalStorageService(),
      ),
    );
  }

  http.Response successfulSearchResponse() {
    return http.Response(
      jsonEncode({
        'results': [city.toJson()],
      }),
      200,
    );
  }

  http.Response successfulAirQualityResponse() {
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
  }

  group('HomePage Widget Testing', () {
    testWidgets('displays initial HomePage interface', (
      WidgetTester tester,
    ) async {
      final client = MockClient((request) async {
        return http.Response('{}', 200);
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      expect(find.text('AirScope'), findsOneWidget);

      expect(find.text('Pantau kualitas udara'), findsOneWidget);

      expect(find.text('Mulai pencarian lokasi'), findsOneWidget);

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('validates search query shorter than two characters', (
      WidgetTester tester,
    ) async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount++;

        return successfulSearchResponse();
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'A');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      expect(
        find.text('Masukkan minimal 2 karakter untuk mencari kota.'),
        findsOneWidget,
      );

      expect(requestCount, 0);
    });

    testWidgets('searches and displays city results', (
      WidgetTester tester,
    ) async {
      final client = MockClient((request) async {
        expect(request.url.host, 'geocoding-api.open-meteo.com');

        return successfulSearchResponse();
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      expect(find.text('Pilih lokasi'), findsOneWidget);

      expect(find.byType(CitySearchResultTile), findsOneWidget);

      expect(find.text('South Sulawesi, Indonesia'), findsOneWidget);
    });

    testWidgets('displays empty state when city is not found', (
      WidgetTester tester,
    ) async {
      final client = MockClient((request) async {
        return http.Response(jsonEncode({'results': []}), 200);
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'KotaTidakAda');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      expect(
        find.text('Kota tidak ditemukan. Coba gunakan nama kota lainnya.'),
        findsOneWidget,
      );

      expect(find.byType(CitySearchResultTile), findsNothing);
    });

    testWidgets('selects city, displays AQI and saves location', (
      WidgetTester tester,
    ) async {
      final client = MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return successfulSearchResponse();
        }

        if (request.url.host == 'air-quality-api.open-meteo.com') {
          return successfulAirQualityResponse();
        }

        return http.Response('{}', 404);
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(CitySearchResultTile));

      await tester.pumpAndSettle();

      expect(find.text('Lokasi berhasil dipilih'), findsOneWidget);

      expect(find.text('Makassar, South Sulawesi, Indonesia'), findsOneWidget);

      expect(find.text('42'), findsOneWidget);

      expect(find.text('Baik'), findsOneWidget);

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.containsKey('airscope.selected_city'), isTrue);

      final savedData = jsonDecode(
        preferences.getString('airscope.selected_city')!,
      );

      expect(savedData['name'], 'Makassar');
    });

    testWidgets('displays search error and retries successfully', (
      WidgetTester tester,
    ) async {
      var requestCount = 0;

      final client = MockClient((request) async {
        requestCount++;

        if (requestCount == 1) {
          return http.Response(
            jsonEncode({'reason': 'Server maintenance'}),
            503,
          );
        }

        return successfulSearchResponse();
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      expect(find.text('Pencarian gagal'), findsOneWidget);

      expect(find.text('Server maintenance'), findsOneWidget);

      await tester.tap(find.text('Coba Lagi'));

      await tester.pumpAndSettle();

      expect(find.byType(CitySearchResultTile), findsOneWidget);

      expect(requestCount, 2);
    });

    testWidgets('restores previously selected city', (
      WidgetTester tester,
    ) async {
      SharedPreferences.setMockInitialValues({
        'airscope.selected_city': jsonEncode(city.toJson()),
      });

      final client = MockClient((request) async {
        expect(request.url.host, 'air-quality-api.open-meteo.com');

        return successfulAirQualityResponse();
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      expect(find.text('Lokasi berhasil dipilih'), findsOneWidget);

      expect(find.text('Makassar, South Sulawesi, Indonesia'), findsOneWidget);

      expect(find.text('42'), findsOneWidget);

      expect(find.text('Memulihkan lokasi terakhir...'), findsNothing);
    });

    testWidgets('retries AQI request after API failure', (
      WidgetTester tester,
    ) async {
      var airQualityRequestCount = 0;

      final client = MockClient((request) async {
        if (request.url.host == 'geocoding-api.open-meteo.com') {
          return successfulSearchResponse();
        }

        if (request.url.host == 'air-quality-api.open-meteo.com') {
          airQualityRequestCount++;

          if (airQualityRequestCount == 1) {
            return http.Response(
              jsonEncode({'reason': 'Temporary server error'}),
              503,
            );
          }

          return successfulAirQualityResponse();
        }

        return http.Response('{}', 404);
      });

      addTearDown(client.close);

      await tester.pumpWidget(createTestApp(client));

      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Makassar');

      await tester.tap(find.byTooltip('Cari kota'));

      await tester.pumpAndSettle();

      await tester.tap(find.byType(CitySearchResultTile));

      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat kualitas udara'), findsOneWidget);

      expect(find.text('Temporary server error'), findsOneWidget);

      final retryButton = find.text('Coba Lagi');

      await tester.ensureVisible(retryButton);

      await tester.tap(retryButton);

      await tester.pumpAndSettle();

      expect(find.text('42'), findsOneWidget);

      expect(airQualityRequestCount, 2);
    });
  });
}
