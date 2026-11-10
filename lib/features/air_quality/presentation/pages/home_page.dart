import 'package:flutter/material.dart';

import 'package:airscope/features/air_quality/data/services/air_quality_api_exception.dart';
import 'package:airscope/features/air_quality/data/services/air_quality_api_service.dart';
import 'package:airscope/features/air_quality/domain/models/city_location.dart';

import '../widgets/city_search_field.dart';
import '../widgets/city_search_result_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _searchController = TextEditingController();

  final AirQualityApiService _apiService = AirQualityApiService();

  List<CityLocation> _searchResults = [];

  CityLocation? _selectedCity;

  bool _isSearching = false;
  bool _hasSearched = false;

  String? _searchError;

  Future<void> _searchCities() async {
    final query = _searchController.text.trim();

    if (query.length < 2) {
      setState(() {
        _searchError = 'Masukkan minimal 2 karakter untuk mencari kota.';
        _searchResults = [];
        _hasSearched = false;
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
    });

    try {
      final results = await _apiService.searchCities(query);

      if (!mounted) return;

      setState(() {
        _searchResults = results;
      });
    } on AirQualityApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _searchError = error.message;
      });
    } on FormatException {
      if (!mounted) return;

      setState(() {
        _searchError = 'Format data lokasi dari server tidak valid.';
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _searchError = 'Terjadi kesalahan saat mencari lokasi.';
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
    setState(() {
      _selectedCity = location;
      _searchResults = [];
      _searchController.text = location.name;
      _searchError = null;
      _hasSearched = false;
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

              if (_selectedCity != null) ...[
                const SizedBox(height: 28),
                _buildSelectedCityCard(_selectedCity!, colorScheme, textTheme),
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
}
