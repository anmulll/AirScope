import 'package:flutter/material.dart';

import 'package:airscope/core/theme/app_colors.dart';
import 'package:airscope/features/air_quality/domain/models/air_quality_data.dart';
import 'package:airscope/features/air_quality/domain/models/aqi_category.dart';

class AirQualitySummaryCard extends StatelessWidget {
  const AirQualitySummaryCard({super.key, required this.data});

  final AirQualityData data;

  Color _getCategoryColor(AqiCategory category) {
    switch (category) {
      case AqiCategory.good:
        return AppColors.aqiGood;

      case AqiCategory.moderate:
        return AppColors.aqiModerate;

      case AqiCategory.unhealthyForSensitiveGroups:
        return AppColors.aqiSensitive;

      case AqiCategory.unhealthy:
        return AppColors.aqiUnhealthy;

      case AqiCategory.veryUnhealthy:
        return AppColors.aqiVeryUnhealthy;

      case AqiCategory.hazardous:
        return AppColors.aqiHazardous;

      case AqiCategory.unavailable:
        return AppColors.textSecondary;
    }
  }

  String _formatTime(DateTime? time) {
    if (time == null) {
      return 'Waktu data tidak tersedia';
    }

    final day = time.day.toString().padLeft(2, '0');
    final month = time.month.toString().padLeft(2, '0');
    final year = time.year;

    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final category = data.aqiCategory;
    final categoryColor = _getCategoryColor(category);
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kualitas Udara Saat Ini',
              style: textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 20),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  data.usAqi?.toStringAsFixed(0) ?? '—',
                  style: TextStyle(
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                    color: categoryColor,
                    height: 1,
                  ),
                ),

                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: categoryColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          category.label,
                          style: TextStyle(
                            color: categoryColor,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(category.description, style: textTheme.bodySmall),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'US Air Quality Index (AQI)',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),

            const SizedBox(height: 20),

            const Divider(),

            const SizedBox(height: 16),

            Text(
              'Particulate Matter',
              style: textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _buildMetricCard(title: 'PM2.5', value: data.pm25),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: _buildMetricCard(title: 'PM10', value: data.pm10),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Icon(
                  Icons.schedule_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: Text(
                    'Waktu data: ${_formatTime(data.measuredAt)}',
                    style: textTheme.bodySmall,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            Text(
              'Sumber: Open-Meteo Air Quality API',
              style: textTheme.bodySmall?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricCard({required String title, required double? value}) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 8),

          Text(
            value?.toStringAsFixed(1) ?? '—',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),

          const SizedBox(height: 4),

          const Text(
            'µg/m³',
            style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }
}
