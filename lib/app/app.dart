import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_theme.dart';
import 'package:reportya/features/splash/presentation/views/splash_view.dart';

class ReportYaApp extends StatelessWidget {
  const ReportYaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const SplashView(),
    );
  }
}
