import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpViewModel extends ChangeNotifier {
  final emailController = TextEditingController();
  final userNameController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  String _errorMessage = '';

  bool get obscurePassword => _obscurePassword;
  bool get obscureConfirmPassword => _obscureConfirmPassword;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  void toggleConfirmPasswordVisibility() {
    _obscureConfirmPassword = !_obscureConfirmPassword;
    notifyListeners();
  }

  String? validateUserName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Ingresa tu nombre de usuario';
    }
    if (value.trim().length < 3) {
      return 'M\u00ednimo 3 caracteres';
    }
    return null;
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu correo electr\u00f3nico';
    }

    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Correo electr\u00f3nico no v\u00e1lido';
    }
    return null;
  }

  String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingresa tu contrase\u00f1a';
    }
    if (value.length < 6) {
      return 'M\u00ednimo 6 caracteres';
    }
    return null;
  }

  String? validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Confirma tu contrase\u00f1a';
    }
    if (value != passwordController.text) {
      return 'Las contrase\u00f1as no coinciden';
    }
    return null;
  }

  Future<bool> signUp() async {
    _isLoading = true;
    _errorMessage = '';
    notifyListeners();

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      await credential.user?.updateDisplayName(
        userNameController.text.trim(),
      );

      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _mapError(e);
      return false;
    } catch (_) {
      _errorMessage = 'Ocurri\u00f3 un error inesperado. Intenta de nuevo.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String _mapError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este correo ya est\u00e1 registrado.';
      case 'invalid-email':
        return 'El formato del correo no es v\u00e1lido.';
      case 'weak-password':
        return 'La contrase\u00f1a es demasiado d\u00e9bil.';
      case 'operation-not-allowed':
        return 'El registro con correo est\u00e1 deshabilitado.';
      default:
        return 'Error desconocido. C\u00f3digo: ${e.code}';
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    userNameController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }
}
