import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignInViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool obscurePassword = true;
  bool isLoading = false;
  String errorMessage = '';

  void togglePasswordVisibility() {
    obscurePassword = !obscurePassword;
    notifyListeners();
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu correo electr\u00f3nico';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingresa tu contrase\u00f1a';
    }
    return null;
  }

  Future<bool> signIn() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = _getErrorMessage(e);
    } catch (_) {
      errorMessage = 'Se produjo un error inesperado';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'El formato del correo electrónico no es válido';
      case 'user-disabled':
        return 'El usuario ha sido deshabilitado';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Correo o contraseña incorrectos';
      case 'too-many-requests':
        return 'Demasiados intentos. Intenta más tarde';
      case 'network-request-failed':
        return 'Sin conexión a internet';
      default:
        return 'Se produjo un error. Intenta de nuevo';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
