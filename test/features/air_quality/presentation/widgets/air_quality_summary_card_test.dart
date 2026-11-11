import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/domain/models/air_quality_data.dart';
import 'package:airscope/features/air_quality/presentation/widgets/air_quality_summary_card.dart';

void main() {
  testWidgets('Air quality summary displays AQI and particulate data', (
    WidgetTester tester,
  ) async {
    const data = AirQualityData(
      cityName: 'Makassar',
      latitude: -5.1477,
      longitude: 119.4327,
      usAqi: 42,
      pm25: 8.5,
      pm10: 12.3,
      measuredAt: null,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: AirQualitySummaryCard(data: data)),
        ),
      ),
    );

    expect(find.text('42'), findsOneWidget);
    expect(find.text('Baik'), findsOneWidget);

    expect(find.text('PM2.5'), findsOneWidget);
    expect(find.text('PM10'), findsOneWidget);

    expect(find.text('8.5'), findsOneWidget);
    expect(find.text('12.3'), findsOneWidget);

    expect(find.text('US Air Quality Index (AQI)'), findsOneWidget);
  });
}
