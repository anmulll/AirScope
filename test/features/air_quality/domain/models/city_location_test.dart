import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/domain/models/city_location.dart';

void main() {
  group('CityLocation', () {
    test('creates CityLocation from valid JSON', () {
      final location = CityLocation.fromJson({
        'name': ' Makassar ',
        'country': ' Indonesia ',
        'admin1': ' South Sulawesi ',
        'latitude': -5.1477,
        'longitude': 119.4327,
      });

      expect(location.name, 'Makassar');
      expect(location.country, 'Indonesia');
      expect(location.admin1, 'South Sulawesi');
      expect(location.latitude, -5.1477);
      expect(location.longitude, 119.4327);
    });

    test('throws FormatException for empty name', () {
      expect(
        () => CityLocation.fromJson({
          'name': ' ',
          'latitude': -5.1477,
          'longitude': 119.4327,
        }),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid latitude', () {
      expect(
        () => CityLocation.fromJson({
          'name': 'Makassar',
          'latitude': -100,
          'longitude': 119.4327,
        }),
        throwsFormatException,
      );
    });

    test('throws FormatException for invalid longitude', () {
      expect(
        () => CityLocation.fromJson({
          'name': 'Makassar',
          'latitude': -5.1477,
          'longitude': 190,
        }),
        throwsFormatException,
      );
    });

    test('accepts numeric coordinates as strings', () {
      final location = CityLocation.fromJson({
        'name': 'Makassar',
        'latitude': '-5.1477',
        'longitude': '119.4327',
      });

      expect(location.latitude, -5.1477);
      expect(location.longitude, 119.4327);
    });

    test('returns null for invalid optional location fields', () {
      final location = CityLocation.fromJson({
        'name': 'Makassar',
        'country': 123,
        'admin1': '',
        'latitude': -5.1477,
        'longitude': 119.4327,
      });

      expect(location.country, isNull);
      expect(location.admin1, isNull);
    });

    test('creates correct display name', () {
      const location = CityLocation(
        name: 'Makassar',
        admin1: 'South Sulawesi',
        country: 'Indonesia',
        latitude: -5.1477,
        longitude: 119.4327,
      );

      expect(location.displayName, 'Makassar, South Sulawesi, Indonesia');
    });

    test('display name works without optional fields', () {
      const location = CityLocation(
        name: 'Makassar',
        latitude: -5.1477,
        longitude: 119.4327,
      );

      expect(location.displayName, 'Makassar');
    });

    test('converts CityLocation into JSON', () {
      const location = CityLocation(
        name: 'Makassar',
        country: 'Indonesia',
        admin1: 'South Sulawesi',
        latitude: -5.1477,
        longitude: 119.4327,
      );

      final json = location.toJson();

      expect(json['name'], 'Makassar');
      expect(json['country'], 'Indonesia');
      expect(json['admin1'], 'South Sulawesi');
      expect(json['latitude'], -5.1477);
      expect(json['longitude'], 119.4327);
    });
  });
}
