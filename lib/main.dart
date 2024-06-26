import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:reportya/screens/home_screen.dart';
import 'package:reportya/screens/main_screen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MainScreen(),
      debugShowCheckedModeBanner: false, // Oculta el banner de debug
    );
  }
}
