import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:reportya/app/app.dart';
import 'package:reportya/core/config/app_config.dart';
import 'package:reportya/core/config/firebase_options.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (_) {}

  await Supabase.initialize(
    url: AppConfig.supabaseUrl,
    anonKey: AppConfig.supabaseAnonKey,
  );

  runApp(const ReportYaApp());
}
