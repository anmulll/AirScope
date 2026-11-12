import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:airscope/main.dart' as app;

import 'package:airscope/features/air_quality/data/services/local_storage_service.dart';

import 'package:airscope/features/air_quality/presentation/widgets/city_search_result_tile.dart';
import 'package:airscope/app/app.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('AirScope Integration Testing', () {
    testWidgets(
      'Pengguna dapat mencari kota, melihat AQI, dan menyimpan lokasi',
      (tester) async {
        // =====================================================
        // 1. MEMBUKA APLIKASI
        // =====================================================

        app.main();

        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 45),
        );

        expect(find.text('AirScope'), findsOneWidget);

        expect(find.text('Pantau kualitas udara'), findsOneWidget);

        expect(find.byType(TextField), findsOneWidget);

        // =====================================================
        // 2. MEMASUKKAN NAMA KOTA
        // =====================================================

        await tester.enterText(find.byType(TextField), 'Makassar');

        // =====================================================
        // 3. MENJALANKAN PENCARIAN
        // =====================================================

        await tester.tap(find.byTooltip('Cari kota'));

        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 45),
        );

        expect(find.text('Pilih lokasi'), findsOneWidget);

        expect(find.byType(CitySearchResultTile), findsWidgets);

        // =====================================================
        // 4. MEMILIH KOTA
        // =====================================================

        final firstResult = find.byType(CitySearchResultTile).first;

        await tester.ensureVisible(firstResult);

        await tester.tap(firstResult);

        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 45),
        );

        // =====================================================
        // 5. MEMASTIKAN LOKASI DIPILIH
        // =====================================================

        expect(find.text('Lokasi berhasil dipilih'), findsOneWidget);

        // =====================================================
        // 6. MEMASTIKAN DATA AQI TAMPIL
        // =====================================================

        expect(find.text('US Air Quality Index (AQI)'), findsOneWidget);

        expect(find.text('Particulate Matter'), findsOneWidget);

        expect(find.text('PM2.5'), findsOneWidget);

        expect(find.text('PM10'), findsOneWidget);

        // =====================================================
        // 7. MEMERIKSA LOCAL STORAGE
        // =====================================================

        final storageService = LocalStorageService();

        final savedCity = await storageService.getSelectedCity();

        // Lokasi harus berhasil tersimpan.
        expect(savedCity, isNotNull);

        // Nama kota harus tersedia.
        expect(savedCity!.name, isNotEmpty);

        // Koordinat harus valid.
        expect(savedCity.latitude, inInclusiveRange(-90.0, 90.0));

        expect(savedCity.longitude, inInclusiveRange(-180.0, 180.0));

        // Memastikan nama lokasi mengandung Makassar,
        // tanpa mengharuskan nama persis sama.
        expect(savedCity.name.toLowerCase(), contains('makassar'));

        print('Lokasi berhasil tersimpan: ${savedCity.displayName}');

        // =====================================================
        // 8. SIMULASI INISIALISASI ULANG APLIKASI
        // =====================================================

        print('Memulai simulasi pemulihan aplikasi...');

        // Membuat ulang root aplikasi.
        // Data SharedPreferences tetap tersimpan di perangkat.
        await tester.pumpWidget(const AirScopeApp());

        await tester.pumpAndSettle(
          const Duration(milliseconds: 100),
          EnginePhase.sendSemanticsUpdate,
          const Duration(seconds: 45),
        );

        // =====================================================
        // 9. MEMASTIKAN LOKASI BERHASIL DIPULIHKAN
        // =====================================================

        expect(find.text('Lokasi berhasil dipilih'), findsOneWidget);

        // Memastikan nama kota kembali terisi.
        final restoredSearchField = tester.widget<TextField>(
          find.byType(TextField),
        );

        expect(
          restoredSearchField.controller?.text.toLowerCase(),
          contains('makassar'),
        );

        // Memastikan lokasi yang dipulihkan sesuai.
        expect(
          find.text('Kota Makassar, Sulawesi Selatan, Indonesia'),
          findsOneWidget,
        );

        print('Lokasi terakhir berhasil dipulihkan!');

        // =====================================================
        // 8. SELESAI
        // =====================================================
      },
    );
  });
}
