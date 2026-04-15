import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ForgotPasswordViewModel extends ChangeNotifier {
  final emailController = TextEditingController();

  bool isLoading = false;
  bool emailSent = false;
  String errorMessage = '';

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electrónico';
    }
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Correo electrónico no válido';
    }
    return null;
  }

  Future<bool> sendResetEmail() async {
    isLoading = true;
    errorMessage = '';
    notifyListeners();

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: emailController.text.trim(),
      );
      emailSent = true;
      isLoading = false;
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      errorMessage = e.code == 'user-not-found'
          ? 'No existe una cuenta con ese correo'
          : 'Ocurrió un error. Intenta de nuevo';
    } catch (_) {
      errorMessage = 'Ocurrió un error. Intenta de nuevo';
    }

    isLoading = false;
    notifyListeners();
    return false;
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
