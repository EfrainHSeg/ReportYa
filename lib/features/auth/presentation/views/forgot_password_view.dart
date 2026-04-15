import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/auth/presentation/viewmodels/forgot_password_viewmodel.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_login_button.dart';

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _formKey = GlobalKey<FormState>();
  late final ForgotPasswordViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = ForgotPasswordViewModel()..addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _handleSend() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await _viewModel.sendResetEmail();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoBlanco,
      appBar: AppBar(
        backgroundColor: AppColors.amarilloCat,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.negro),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Form(
            key: _formKey,
            child: _viewModel.emailSent
                ? _SuccessContent(
                    email: _viewModel.emailController.text.trim(),
                    onBack: () => Navigator.pop(context),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: AppColors.amarilloCat.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.lock_reset_rounded,
                          color: AppColors.amarilloCat,
                          size: 30,
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Recuperar\ncontraseña',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textoNegro,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textoGrisOscuro,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),
                      AuthInputField(
                        label: 'CORREO',
                        hint: 'ejemplo@correo.com',
                        controller: _viewModel.emailController,
                        validator: _viewModel.validateEmail,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      if (_viewModel.errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 12),
                          child: Text(
                            _viewModel.errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      const SizedBox(height: 32),
                      AuthLoginButton(
                        onPressed: _handleSend,
                        isLoading: _viewModel.isLoading,
                        label: 'Enviar enlace',
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _SuccessContent extends StatelessWidget {
  const _SuccessContent({required this.email, required this.onBack});

  final String email;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 40),
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.mark_email_read_rounded,
              color: Colors.green.shade600, size: 40),
        ),
        const SizedBox(height: 28),
        const Text(
          '¡Correo enviado!',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textoNegro,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos un enlace de recuperación a\n$email',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textoGrisOscuro,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        const Text(
          'Revisa también tu carpeta de spam.',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textoGris,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 40),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onBack,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.amarilloCat,
              foregroundColor: AppColors.negro,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              'Volver al inicio de sesión',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ),
      ],
    );
  }
}
