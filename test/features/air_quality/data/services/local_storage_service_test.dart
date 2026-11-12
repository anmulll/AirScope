import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:airscope/features/air_quality/data/services/local_storage_service.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const city = CityLocation(
    name: 'Makassar',
    country: 'Indonesia',
    admin1: 'South Sulawesi',
    latitude: -5.1477,
    longitude: 119.4327,
  );

  group('LocalStorageService', () {
    test('saves and restores selected city', () async {
      SharedPreferences.setMockInitialValues({});

      final storage = LocalStorageService();

      await storage.saveSelectedCity(city);

      final restoredCity = await storage.getSelectedCity();

      expect(restoredCity, isNotNull);
      expect(restoredCity!.name, 'Makassar');
      expect(restoredCity.country, 'Indonesia');
      expect(restoredCity.latitude, -5.1477);
      expect(restoredCity.longitude, 119.4327);
    });

    test('returns null when no city is saved', () async {
      SharedPreferences.setMockInitialValues({});

      final storage = LocalStorageService();

      final result = await storage.getSelectedCity();

      expect(result, isNull);
    });

    test('clears saved selected city', () async {
      SharedPreferences.setMockInitialValues({});

      final storage = LocalStorageService();

      await storage.saveSelectedCity(city);
      await storage.clearSelectedCity();

      final result = await storage.getSelectedCity();

      expect(result, isNull);
    });

    test('removes corrupted saved city data', () async {
      SharedPreferences.setMockInitialValues({
        'airscope.selected_city': '{invalid-json',
      });

      final storage = LocalStorageService();

      final result = await storage.getSelectedCity();

      expect(result, isNull);

      final preferences = await SharedPreferences.getInstance();

      expect(preferences.containsKey('airscope.selected_city'), isFalse);
    });
  });
}
