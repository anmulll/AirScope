import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/models/city_location.dart';

class LocalStorageService {
  LocalStorageService({this._preferences});

  SharedPreferences? _preferences;

  static const String _selectedCityKey = 'airscope.selected_city';

  Future<SharedPreferences> get _instance async {
    return _preferences ??= await SharedPreferences.getInstance();
  }

  /// Menyimpan lokasi terakhir yang dipilih.
  Future<void> saveSelectedCity(CityLocation location) async {
    final preferences = await _instance;

    final jsonString = jsonEncode(location.toJson());

    await preferences.setString(_selectedCityKey, jsonString);
  }

  /// Mengambil lokasi terakhir yang tersimpan.
  Future<CityLocation?> getSelectedCity() async {
    final preferences = await _instance;

    final jsonString = preferences.getString(_selectedCityKey);

    if (jsonString == null || jsonString.isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(jsonString);

      if (decoded is! Map<String, dynamic>) {
        await preferences.remove(_selectedCityKey);
        return null;
      }

      return CityLocation.fromJson(decoded);
    } on FormatException {
      await preferences.remove(_selectedCityKey);
      return null;
    } on TypeError {
      await preferences.remove(_selectedCityKey);
      return null;
    }
  }

  /// Menghapus lokasi yang tersimpan.
  Future<void> clearSelectedCity() async {
    final preferences = await _instance;

    await preferences.remove(_selectedCityKey);
  }
}
