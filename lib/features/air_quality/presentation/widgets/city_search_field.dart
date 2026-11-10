import 'package:flutter/material.dart';

import '../../domain/models/city_location.dart';

class CitySearchResultTile extends StatelessWidget {
  const CitySearchResultTile({
    super.key,
    required this.location,
    required this.onTap,
  });

  final CityLocation location;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final details = [
      location.admin1,
      location.country,
    ].whereType<String>().join(', ');

    return Card(
      margin: EdgeInsets.zero,
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: colorScheme.primaryContainer,
          child: Icon(
            Icons.location_city_rounded,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        title: Text(
          location.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(details.isEmpty ? 'Koordinat tersedia' : details),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }
}
