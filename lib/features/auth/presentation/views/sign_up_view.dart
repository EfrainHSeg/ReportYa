import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/auth/presentation/viewmodels/sign_up_viewmodel.dart';
import 'package:reportya/features/auth/presentation/views/sign_in_view.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_login_button.dart';
import 'package:reportya/features/auth/presentation/widgets/reportya_auth_header.dart';

class SignUpView extends StatefulWidget {
  const SignUpView({super.key});

  @override
  State<SignUpView> createState() => _SignUpViewState();
}

class _SignUpViewState extends State<SignUpView> {
  final _formKey = GlobalKey<FormState>();
  late final SignUpViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignUpViewModel()..addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_refresh)
      ..dispose();
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _viewModel.signUp();
    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cuenta creada correctamente'),
        duration: Duration(seconds: 2),
      ),
    );

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInView()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondoBlanco,
      resizeToAvoidBottomInset: true,
      body: Column(
        children: [
          const ReportYaAuthHeader(),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxHeight < 640;
                final fieldGap = compact ? 12.0 : 16.0;
                final topGap = compact ? 16.0 : 22.0;
                final titleGap = compact ? 6.0 : 10.0;
                final bottomGap = compact ? 18.0 : 24.0;

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 18),
                  child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textoNegro,
                              ),
                            ),
                            SizedBox(height: titleGap),
                            const Text(
                              'Registra tu acceso para empezar a reportar.',
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textoGrisOscuro,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: topGap),
                            AuthInputField(
                              label: 'USUARIO',
                              hint: 'Tu nombre completo',
                              controller: _viewModel.userNameController,
                              validator: _viewModel.validateUserName,
                            ),
                            SizedBox(height: fieldGap),
                            AuthInputField(
                              label: 'CORREO',
                              hint: 'ejemplo@correo.com',
                              controller: _viewModel.emailController,
                              validator: _viewModel.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: fieldGap),
                            AuthInputField(
                              label: 'CONTRASE\u00d1A',
                              hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                              controller: _viewModel.passwordController,
                              validator: _viewModel.validatePassword,
                              obscureText: _viewModel.obscurePassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _viewModel.obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textoGris,
                                ),
                                onPressed: _viewModel.togglePasswordVisibility,
                              ),
                            ),
                            SizedBox(height: fieldGap),
                            AuthInputField(
                              label: 'CONFIRMAR CONTRASE\u00d1A',
                              hint: '\u2022\u2022\u2022\u2022\u2022\u2022\u2022\u2022',
                              controller: _viewModel.confirmPasswordController,
                              validator: _viewModel.validateConfirmPassword,
                              obscureText: _viewModel.obscureConfirmPassword,
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _viewModel.obscureConfirmPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 18,
                                  color: AppColors.textoGris,
                                ),
                                onPressed:
                                    _viewModel.toggleConfirmPasswordVisibility,
                              ),
                            ),
                            SizedBox(height: bottomGap),
                            AuthLoginButton(
                              onPressed: _handleSignUp,
                              isLoading: _viewModel.isLoading,
                              label: 'Crear cuenta',
                            ),
                            if (_viewModel.errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 12),
                                child: Text(
                                  _viewModel.errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 24),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 18),
                                child: RichText(
                                  text: TextSpan(
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textoGris,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: '\u00bfYa tienes una cuenta? ',
                                      ),
                                      WidgetSpan(
                                        alignment: PlaceholderAlignment.middle,
                                        child: GestureDetector(
                                          onTap: () {
                                            Navigator.pushReplacement(
                                              context,
                                              MaterialPageRoute(
                                                builder: (_) => const SignInView(),
                                              ),
                                            );
                                          },
                                          child: const Text(
                                            'Inicia sesi\u00f3n',
                                            style: TextStyle(
                                              fontSize: 13,
                                              color: AppColors.naranjaFerreyros,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
