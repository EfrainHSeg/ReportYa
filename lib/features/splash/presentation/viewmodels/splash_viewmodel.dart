import 'package:firebase_core/firebase_core.dart';
import 'package:reportya/core/config/firebase_options.dart';

class SplashViewModel {
  Future<void> prepareApp() async {
    final waitBranding = Future<void>.delayed(const Duration(seconds: 5));

    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }

    await waitBranding;
  }
}
