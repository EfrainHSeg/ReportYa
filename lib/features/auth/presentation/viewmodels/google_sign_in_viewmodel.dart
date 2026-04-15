import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSignInViewModel extends ChangeNotifier {
  bool isLoading = false;
  String errorMessage = '';

  Future<bool> signInWithGoogle() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        isLoading = false;
        notifyListeners();
        return false;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code == 'account-exists-with-different-credential'
          ? 'Ya existe una cuenta con ese correo'
          : 'Error al iniciar sesión con Google';
    } catch (_) {
      errorMessage = 'Error al iniciar sesión con Google';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }
}
