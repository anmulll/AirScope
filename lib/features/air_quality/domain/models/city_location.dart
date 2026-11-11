class CityLocation {
  final String name;
  final String? country;
  final String? admin1;
  final double latitude;
  final double longitude;

  const CityLocation({
    required this.name,
    this.country,
    this.admin1,
    required this.latitude,
    required this.longitude,
  });

  factory CityLocation.fromJson(Map<String, dynamic> json) {
    final name = json['name'];
    final latitude = _toDouble(json['latitude']);
    final longitude = _toDouble(json['longitude']);

    if (name is! String || name.trim().isEmpty) {
      throw const FormatException('Nama lokasi tidak valid.');
    }

    if (latitude == null || latitude < -90 || latitude > 90) {
      throw const FormatException('Latitude tidak valid.');
    }

    if (longitude == null || longitude < -180 || longitude > 180) {
      throw const FormatException('Longitude tidak valid.');
    }

    return CityLocation(
      name: name.trim(),
      country: _readString(json['country']),
      admin1: _readString(json['admin1']),
      latitude: latitude,
      longitude: longitude,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'country': country,
      'admin1': admin1,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  String get displayName {
    return [name, ?admin1, ?country].join(', ');
  }

  static String? _readString(dynamic value) {
    if (value is String && value.trim().isNotEmpty) {
      return value.trim();
    }

    return null;
  }

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
