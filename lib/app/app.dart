import 'package:flutter/material.dart';
import '../core/routes/app_routes.dart';
import '../core/constants/app_constants.dart';
import '../core/theme/app_theme.dart';

class MyApp extends StatelessWidget {
  final ThemeMode themeMode;

  const MyApp({
    super.key,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appName,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      initialRoute: '/',
      onGenerateRoute: AppRoutes.generateRoute,
    );
  }
}