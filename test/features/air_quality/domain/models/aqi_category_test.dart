import 'package:flutter_test/flutter_test.dart';

import 'package:airscope/features/air_quality/domain/models/aqi_category.dart';

void main() {
  group('AqiCategory.fromUsAqi', () {
    test('returns unavailable for null AQI', () {
      expect(AqiCategory.fromUsAqi(null), AqiCategory.unavailable);
    });

    test('returns unavailable for negative AQI', () {
      expect(AqiCategory.fromUsAqi(-1), AqiCategory.unavailable);
    });

    test('returns unavailable for NaN AQI', () {
      expect(AqiCategory.fromUsAqi(double.nan), AqiCategory.unavailable);
    });

    test('returns unavailable for infinite AQI', () {
      expect(AqiCategory.fromUsAqi(double.infinity), AqiCategory.unavailable);
    });

    test('returns good for AQI between 0 and 50', () {
      expect(AqiCategory.fromUsAqi(25), AqiCategory.good);

      expect(AqiCategory.fromUsAqi(50), AqiCategory.good);
    });

    test('returns moderate for AQI between 51 and 100', () {
      expect(AqiCategory.fromUsAqi(75), AqiCategory.moderate);

      expect(AqiCategory.fromUsAqi(100), AqiCategory.moderate);
    });

    test('returns unhealthyForSensitiveGroups for AQI 101-150', () {
      expect(
        AqiCategory.fromUsAqi(125),
        AqiCategory.unhealthyForSensitiveGroups,
      );

      expect(
        AqiCategory.fromUsAqi(150),
        AqiCategory.unhealthyForSensitiveGroups,
      );
    });

    test('returns unhealthy for AQI 151-200', () {
      expect(AqiCategory.fromUsAqi(175), AqiCategory.unhealthy);

      expect(AqiCategory.fromUsAqi(200), AqiCategory.unhealthy);
    });

    test('returns veryUnhealthy for AQI 201-300', () {
      expect(AqiCategory.fromUsAqi(250), AqiCategory.veryUnhealthy);

      expect(AqiCategory.fromUsAqi(300), AqiCategory.veryUnhealthy);
    });

    test('returns hazardous for AQI above 300', () {
      expect(AqiCategory.fromUsAqi(301), AqiCategory.hazardous);

      expect(AqiCategory.fromUsAqi(500), AqiCategory.hazardous);
    });

    test('provides correct category labels', () {
      expect(AqiCategory.good.label, 'Baik');
      expect(AqiCategory.moderate.label, 'Sedang');
      expect(AqiCategory.unhealthy.label, 'Tidak Sehat');
      expect(AqiCategory.hazardous.label, 'Berbahaya');
    });
  });
}
