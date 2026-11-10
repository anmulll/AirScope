import 'package:flutter/material.dart';
import 'package:airscope/core/theme/app_theme.dart';
import 'package:airscope/features/air_quality/presentation/pages/home_page.dart';

class AirScopeApp extends StatelessWidget {
  const AirScopeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AirScope',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomePage(),
    );
  }
}
