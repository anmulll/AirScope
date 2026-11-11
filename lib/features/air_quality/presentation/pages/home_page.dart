import 'package:flutter/material.dart';

import 'package:airscope/features/air_quality/data/services/air_quality_api_exception.dart';
import 'package:airscope/features/air_quality/data/services/air_quality_api_service.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';

import '../widgets/city_search_field.dart';
import '../widgets/city_search_result_tile.dart';

import 'package:airscope/features/air_quality/domain/models/air_quality_data.dart';

import '../widgets/air_quality_summary_card.dart';
import '../widgets/air_quality_error_card.dart';

import 'package:airscope/features/air_quality/data/services/local_storage_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final AirQualityApiService _apiService = AirQualityApiService();

  final LocalStorageService _storageService = LocalStorageService();

  bool _isRestoringCity = true;

  List<CityLocation> _searchResults = [];

  CityLocation? _selectedCity;

  Future<AirQualityData>? _airQualityFuture;

  bool _isSearching = false;
  bool _hasSearched = false;
  bool _canRetrySearch = false;

  String? _searchError;

  @override
  void initState() {
    super.initState();

    _restoreLastSelectedCity();
  }

  /// Memulihkan lokasi terakhir ketika aplikasi dibuka.
  Future<void> _restoreLastSelectedCity() async {
    try {
      final location = await _storageService.getSelectedCity();

      if (!mounted) return;

      if (location != null) {
        final future = _apiService.fetchAirQuality(location);

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

  Future<void> _searchCities() async {
    final query = _searchController.text.trim();

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

  void _selectCity(CityLocation location) {
    final future = _apiService.fetchAirQuality(location);

    setState(() {
      _selectedCity = location;
      _airQualityFuture = future;

      _searchResults = [];
      _searchController.text = location.name;

      _searchError = null;
      _hasSearched = false;
      _canRetrySearch = false;
    });

    _saveSelectedCity(location);
  }

  /// Menyimpan lokasi yang baru dipilih.
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

  void _retryAirQuality() {
    final location = _selectedCity;

    if (location == null) return;

    setState(() {
      _airQualityFuture = _apiService.fetchAirQuality(location);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _apiService.close();
    super.dispose();
  }

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
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Pantau kualitas udara', style: textTheme.headlineSmall),
              const SizedBox(height: 8),
              Text(
                'Cari kota untuk mengetahui informasi '
                'kualitas udara di lokasi tersebut.',
                style: textTheme.bodyMedium,
              ),

              const SizedBox(height: 28),

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

              if (_selectedCity != null) ...[
                const SizedBox(height: 28),

                _buildSelectedCityCard(_selectedCity!, colorScheme, textTheme),

                const SizedBox(height: 16),

                _buildAirQualitySection(),
              ],

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
            'Lokasi telah dipilih. Pengambilan data '
            'kualitas udara akan diimplementasikan '
            'pada tahap berikutnya.',
            style: textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAirQualitySection() {
    final future = _airQualityFuture;

    if (future == null) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<AirQualityData>(
      future: future,
      builder: (context, snapshot) {
        // LOADING STATE
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

        // ERROR STATE
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

        // SUCCESS STATE
        if (snapshot.hasData) {
          return AirQualitySummaryCard(data: snapshot.data!);
        }

        // EMPTY STATE
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
