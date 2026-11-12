import 'dart:async';

import 'package:flutter/material.dart';

import 'package:airscope/features/air_quality/data/services/air_quality_api_exception.dart';
import 'package:airscope/features/air_quality/data/services/air_quality_api_service.dart';
import 'package:airscope/features/air_quality/data/services/local_storage_service.dart';

import 'package:airscope/features/air_quality/domain/models/air_quality_data.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';

import '../widgets/air_quality_error_card.dart';
import '../widgets/air_quality_summary_card.dart';
import '../widgets/city_search_field.dart';
import '../widgets/city_search_result_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.apiService, this.storageService});

  final AirQualityApiService? apiService;
  final LocalStorageService? storageService;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // ============================================================
  // DEPENDENCIES
  // ============================================================

  final TextEditingController _searchController = TextEditingController();

  late final AirQualityApiService _apiService;

  late final LocalStorageService _storageService;

  late final bool _ownsApiService;

  // ============================================================
  // STATE VARIABLES
  // ============================================================

  bool _isRestoringCity = true;

  bool _isSearching = false;

  bool _hasSearched = false;

  bool _canRetrySearch = false;

  List<CityLocation> _searchResults = [];

  CityLocation? _selectedCity;

  Future<AirQualityData>? _airQualityFuture;

  // Data kualitas udara terakhir yang berhasil diterima.
  AirQualityData? _latestAirQualityData;

  // Status pembaruan data.
  bool _isRefreshing = false;

  // Pesan error ketika proses refresh gagal.
  String? _refreshError;

  String? _searchError;

  // ============================================================
  // INITIALIZATION
  // ============================================================

  @override
  void initState() {
    super.initState();

    _ownsApiService = widget.apiService == null;

    _apiService = widget.apiService ?? AirQualityApiService();

    _storageService = widget.storageService ?? LocalStorageService();

    _restoreLastSelectedCity();
  }

  // ============================================================
  // AIR QUALITY REQUEST
  // ============================================================

  /// Membuat request kualitas udara.
  ///
  /// Error handler dipasang segera agar Future tidak menghasilkan
  /// unhandled asynchronous error sebelum FutureBuilder menerima
  /// Future tersebut.
  ///
  /// Future asli tetap dikembalikan sehingga FutureBuilder masih
  /// dapat membaca snapshot.hasError dan snapshot.error.

  Future<AirQualityData> _requestAirQuality(CityLocation location) {
    final future = _apiService.fetchAirQuality(location);

    // Menyimpan data terbaru ketika request berhasil.
    unawaited(
      future.then<void>((data) {
        if (!mounted) return;

        final selected = _selectedCity;

        // Abaikan respons dari lokasi yang sudah tidak dipilih.
        if (selected == null ||
            selected.latitude != location.latitude ||
            selected.longitude != location.longitude) {
          return;
        }

        setState(() {
          _latestAirQualityData = data;
          _refreshError = null;
        });
      }, onError: (Object error, StackTrace stackTrace) {}),
    );

    return future;
  }

  // ============================================================
  // RESTORE LAST SELECTED CITY
  // ============================================================

  /// Memulihkan lokasi terakhir ketika aplikasi dibuka.
  Future<void> _restoreLastSelectedCity() async {
    try {
      final location = await _storageService.getSelectedCity();

      if (!mounted) return;

      if (location != null) {
        final future = _requestAirQuality(location);

        setState(() {
          _selectedCity = location;

          _searchController.text = location.name;

          _airQualityFuture = future;
        });
      }
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi terakhir tidak dapat dipulihkan.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isRestoringCity = false;
        });
      }
    }
  }

  // ============================================================
  // SEARCH CITY
  // ============================================================

  Future<void> _searchCities() async {
    final query = _searchController.text.trim();

    // Validasi input pencarian.
    if (query.length < 2) {
      setState(() {
        _searchError = 'Masukkan minimal 2 karakter untuk mencari kota.';

        _searchResults = [];

        _hasSearched = false;

        _canRetrySearch = false;
      });

      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      _isSearching = true;

      _hasSearched = true;

      _searchError = null;

      _searchResults = [];

      _selectedCity = null;

      _airQualityFuture = null;

      _canRetrySearch = false;

      _latestAirQualityData = null;

      _isRefreshing = false;

      _refreshError = null;
    });

    try {
      final results = await _apiService.searchCities(query);

      if (!mounted) return;

      setState(() {
        _searchResults = results;

        _canRetrySearch = false;
      });
    } on AirQualityApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _searchError = error.message;

        _canRetrySearch = true;
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        _searchError = 'Format data lokasi dari server tidak valid.';

        _canRetrySearch = true;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _searchError = 'Terjadi kesalahan saat mencari lokasi.';

        _canRetrySearch = true;
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
      }
    }
  }

  // ============================================================
  // SELECT CITY
  // ============================================================

  void _selectCity(CityLocation location) {
    // Request melalui helper yang sudah memiliki error handler.
    final future = _requestAirQuality(location);

    setState(() {
      _selectedCity = location;

      _airQualityFuture = future;

      _searchResults = [];

      _searchController.text = location.name;

      _searchError = null;

      _hasSearched = false;

      _canRetrySearch = false;

      _latestAirQualityData = null;

      _isRefreshing = false;

      _refreshError = null;
    });

    _saveSelectedCity(location);
  }

  // ============================================================
  // SAVE SELECTED CITY
  // ============================================================

  Future<void> _saveSelectedCity(CityLocation location) async {
    try {
      await _storageService.saveSelectedCity(location);
    } catch (_) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lokasi berhasil dipilih, tetapi gagal disimpan.'),
        ),
      );
    }
  }

  // ============================================================
  // RETRY AIR QUALITY REQUEST
  // ============================================================

  void _retryAirQuality() {
    final location = _selectedCity;

    if (location == null) return;

    // Jika sudah memiliki data sebelumnya,
    // gunakan mekanisme refresh tanpa menghapus data.
    if (_latestAirQualityData != null) {
      _refreshAirQuality();
      return;
    }

    // Jika belum memiliki data, ulangi request awal.
    setState(() {
      _airQualityFuture = _requestAirQuality(location);
    });
  }

  // ============================================================
  // MANUAL REFRESH AIR QUALITY
  // ============================================================

  Future<void> _refreshAirQuality() async {
    final location = _selectedCity;

    if (location == null || _isRefreshing) return;

    setState(() {
      _isRefreshing = true;
      _refreshError = null;
    });

    try {
      // Mengambil data terbaru dari API.
      final data = await _apiService.fetchAirQuality(location);

      if (!mounted) return;

      // Mengabaikan respons jika pengguna sudah memilih lokasi lain.
      if (_selectedCity?.latitude != location.latitude ||
          _selectedCity?.longitude != location.longitude) {
        return;
      }

      setState(() {
        _latestAirQualityData = data;
        _airQualityFuture = Future<AirQualityData>.value(data);
      });
    } catch (error) {
      if (!mounted) return;

      if (_selectedCity?.latitude != location.latitude ||
          _selectedCity?.longitude != location.longitude) {
        return;
      }

      String message;

      if (error is AirQualityApiException) {
        message = error.message;
      } else if (error is FormatException) {
        message = 'Format respons dari server tidak valid.';
      } else {
        message =
            'Gagal memperbarui kualitas udara. '
            'Periksa koneksi internet dan coba kembali.';
      }

      setState(() {
        // Data lama tidak dihapus ketika refresh gagal.
        _refreshError = message;
      });
    } finally {
      if (mounted &&
          _selectedCity?.latitude == location.latitude &&
          _selectedCity?.longitude == location.longitude) {
        setState(() {
          _isRefreshing = false;
        });
      }
    }
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    _searchController.dispose();

    // Hanya menutup API Service yang dibuat oleh HomePage.
    if (_ownsApiService) {
      _apiService.close();
    }

    super.dispose();
  }

  // ============================================================
  // BUILD MAIN PAGE
  // ============================================================

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'AirScope',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        backgroundColor: colorScheme.surface,
        actions: [
          if (_selectedCity != null)
            IconButton(
              tooltip: 'Perbarui kualitas udara',
              onPressed: _latestAirQualityData == null || _isRefreshing
                  ? null
                  : _refreshAirQuality,
              icon: _isRefreshing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
        ],
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              // --------------------------------------------------
              // HEADER
              // --------------------------------------------------

              Text('Pantau kualitas udara', style: textTheme.headlineSmall),

              const SizedBox(height: 8),

              Text(
                'Cari kota untuk mengetahui informasi '
                'kualitas udara di lokasi tersebut.',
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 28),

              // --------------------------------------------------
              // SEARCH FIELD
              // --------------------------------------------------
              Text(
                'Nama kota',
                style: textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 10),

              CitySearchField(
                controller: _searchController,
                onSearch: _searchCities,
                isLoading: _isSearching,
              ),

              if (_isSearching) ...[
                const SizedBox(height: 16),

                const LinearProgressIndicator(),
              ],

              // --------------------------------------------------
              // SEARCH ERROR
              // --------------------------------------------------
              if (_searchError != null) ...[
                const SizedBox(height: 20),

                if (_canRetrySearch)
                  AirQualityErrorCard(
                    title: 'Pencarian gagal',
                    message: _searchError!,
                    onRetry: _searchCities,
                  )
                else
                  _buildMessageCard(
                    icon: Icons.error_outline_rounded,
                    message: _searchError!,
                    color: colorScheme.error,
                  ),
              ],

              // --------------------------------------------------
              // SEARCH RESULTS
              // --------------------------------------------------
              if (_searchResults.isNotEmpty) ...[
                const SizedBox(height: 28),

                Text(
                  'Pilih lokasi',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 12),

                ..._searchResults.map(
                  (location) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),

                    child: CitySearchResultTile(
                      location: location,
                      onTap: () => _selectCity(location),
                    ),
                  ),
                ),
              ],

              // --------------------------------------------------
              // EMPTY SEARCH RESULT
              // --------------------------------------------------
              if (_hasSearched &&
                  !_isSearching &&
                  _searchResults.isEmpty &&
                  _searchError == null) ...[
                const SizedBox(height: 24),

                _buildMessageCard(
                  icon: Icons.location_off_outlined,
                  message:
                      'Kota tidak ditemukan. '
                      'Coba gunakan nama kota lainnya.',
                  color: colorScheme.onSurfaceVariant,
                ),
              ],

              // --------------------------------------------------
              // RESTORING LAST CITY
              // --------------------------------------------------
              if (_isRestoringCity) ...[
                const SizedBox(height: 36),

                const Center(
                  child: Column(
                    children: [
                      CircularProgressIndicator(),

                      SizedBox(height: 16),

                      Text('Memulihkan lokasi terakhir...'),
                    ],
                  ),
                ),
              ],

              // --------------------------------------------------
              // SELECTED CITY
              // --------------------------------------------------
              if (_selectedCity != null) ...[
                const SizedBox(height: 28),

                _buildSelectedCityCard(_selectedCity!, colorScheme, textTheme),

                const SizedBox(height: 16),

                _buildAirQualitySection(),
              ],

              // --------------------------------------------------
              // INITIAL EMPTY STATE
              // --------------------------------------------------
              if (!_hasSearched &&
                  _selectedCity == null &&
                  _searchError == null) ...[
                const SizedBox(height: 36),

                Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.location_searching_rounded,
                        size: 64,
                        color: colorScheme.primary,
                      ),

                      const SizedBox(height: 16),

                      Text(
                        'Mulai pencarian lokasi',
                        style: textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Masukkan nama kota untuk menemukan '
                        'lokasi yang ingin dipantau.',
                        style: textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],

              // --------------------------------------------------
              // FOOTER
              // --------------------------------------------------
              const SizedBox(height: 32),

              Center(
                child: Text(
                  'Air quality data provided by Open-Meteo',
                  style: textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // MESSAGE CARD
  // ============================================================

  Widget _buildMessageCard({
    required IconData icon,
    required String message,
    required Color color,
  }) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(icon, color: color),

          const SizedBox(width: 12),

          Expanded(
            child: Text(message, style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SELECTED CITY CARD
  // ============================================================

  Widget _buildSelectedCityCard(
    CityLocation location,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.35),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.2)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(Icons.check_circle_rounded, color: colorScheme.primary),

              const SizedBox(width: 8),

              Text(
                'Lokasi berhasil dipilih',
                style: textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(location.displayName, style: textTheme.titleLarge),

          const SizedBox(height: 8),

          Text(
            'Latitude: ${location.latitude.toStringAsFixed(4)}',
            style: textTheme.bodyMedium,
          ),

          Text(
            'Longitude: ${location.longitude.toStringAsFixed(4)}',
            style: textTheme.bodyMedium,
          ),

          const SizedBox(height: 12),

          Text(
            'Data kualitas udara untuk lokasi ini '
            'ditampilkan pada bagian berikutnya.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // ============================================================
  // AIR QUALITY SECTION
  // ============================================================

  Widget _buildAirQualitySection() {
    // ==========================================================
    // CACHED DATA
    // ==========================================================

    final latestData = _latestAirQualityData;

    if (latestData != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Indikator pembaruan tanpa menghilangkan data lama.
          if (_isRefreshing) ...[
            const LinearProgressIndicator(),

            const SizedBox(height: 8),

            const Text(
              'Memperbarui data kualitas udara...',
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 12),
          ],

          // Dashboard tetap menampilkan data terakhir.
          AirQualitySummaryCard(data: latestData),

          // Error refresh ditampilkan di bawah dashboard.
          if (_refreshError != null) ...[
            const SizedBox(height: 12),

            AirQualityErrorCard(
              title: 'Pembaruan data gagal',
              message:
                  '$_refreshError\n'
                  'Data sebelumnya tetap ditampilkan.',
              onRetry: _refreshAirQuality,
            ),
          ],
        ],
      );
    }

    // ==========================================================
    // INITIAL REQUEST
    // ==========================================================

    final future = _airQualityFuture;

    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<AirQualityData>(
      future: future,
      builder: (context, snapshot) {
        // ------------------------------------------------------
        // LOADING STATE
        // ------------------------------------------------------

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const CircularProgressIndicator(),

                  const SizedBox(height: 16),

                  Text(
                    'Mengambil data kualitas udara...',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        // ------------------------------------------------------
        // ERROR STATE
        // ------------------------------------------------------

        if (snapshot.hasError) {
          final error = snapshot.error;

          String message;

          if (error is AirQualityApiException) {
            message = error.message;
          } else if (error is FormatException) {
            message =
                'Format respons dari server tidak valid. '
                'Silakan coba kembali.';
          } else {
            message =
                'Gagal mengambil data kualitas udara. '
                'Periksa koneksi internet dan coba kembali.';
          }

          return AirQualityErrorCard(
            title: 'Gagal memuat kualitas udara',
            message: message,
            onRetry: _retryAirQuality,
          );
        }

        // ------------------------------------------------------
        // SUCCESS STATE
        // ------------------------------------------------------

        if (snapshot.hasData) {
          return AirQualitySummaryCard(data: snapshot.data!);
        }

        // ------------------------------------------------------
        // EMPTY STATE
        // ------------------------------------------------------

        return AirQualityErrorCard(
          title: 'Data tidak tersedia',
          message:
              'Belum ada informasi kualitas udara untuk '
              'lokasi ini. Silakan coba kembali.',
          onRetry: _retryAirQuality,
        );
      },
    );
  }
}
