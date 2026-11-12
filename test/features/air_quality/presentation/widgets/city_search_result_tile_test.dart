import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/domain/models/city_location.dart';
import 'package:airscope/features/air_quality/presentation/widgets/city_search_result_tile.dart';

void main() {
  const city = CityLocation(
    name: 'Makassar',
    country: 'Indonesia',
    admin1: 'South Sulawesi',
    latitude: -5.1477,
    longitude: 119.4327,
  );

  Widget createWidget({
    required VoidCallback onTap,
    CityLocation location = city,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CitySearchResultTile(location: location, onTap: onTap),
      ),
    );
  }

  group('CitySearchResultTile', () {
    testWidgets('displays city name and location details', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(createWidget(onTap: () {}));

      expect(find.text('Makassar'), findsOneWidget);

      expect(find.text('South Sulawesi, Indonesia'), findsOneWidget);

      expect(find.byIcon(Icons.location_city_rounded), findsOneWidget);

      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('calls callback when city is selected', (
      WidgetTester tester,
    ) async {
      var selected = false;

      await tester.pumpWidget(
        createWidget(
          onTap: () {
            selected = true;
          },
        ),
      );

      await tester.tap(find.byType(ListTile));

      expect(selected, isTrue);
    });

    testWidgets('displays fallback when location details are unavailable', (
      WidgetTester tester,
    ) async {
      const location = CityLocation(
        name: 'Makassar',
        latitude: -5.1477,
        longitude: 119.4327,
      );

      await tester.pumpWidget(createWidget(location: location, onTap: () {}));

      expect(find.text('Koordinat tersedia'), findsOneWidget);
    });
  });
}
