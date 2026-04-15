import 'package:flutter/material.dart';
import 'package:reportya/core/theme/app_colors.dart';
import 'package:reportya/features/auth/presentation/viewmodels/google_sign_in_viewmodel.dart';
import 'package:reportya/features/auth/presentation/viewmodels/sign_in_viewmodel.dart';
import 'package:reportya/features/auth/presentation/views/forgot_password_view.dart';
import 'package:reportya/features/auth/presentation/views/sign_up_view.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_divider.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:reportya/features/auth/presentation/widgets/auth_login_button.dart';
import 'package:reportya/features/auth/presentation/widgets/google_auth_button.dart';
import 'package:reportya/features/auth/presentation/widgets/reportya_auth_header.dart';
import 'package:reportya/features/dashboard/presentation/views/dashboard_view.dart';

class SignInView extends StatefulWidget {
  const SignInView({super.key});

  @override
  State<SignInView> createState() => _SignInViewState();
}

class _SignInViewState extends State<SignInView> {
  final _formKey = GlobalKey<FormState>();
  late final SignInViewModel _viewModel;
  late final GoogleSignInViewModel _googleViewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SignInViewModel()..addListener(_refresh);
    _googleViewModel = GoogleSignInViewModel()..addListener(_refresh);
  }

  @override
  void dispose() {
    _viewModel
      ..removeListener(_refresh)
      ..dispose();
    _googleViewModel.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _handleGoogleSignIn() async {
    final success = await _googleViewModel.signInWithGoogle();
    if (!mounted || !success) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardView()),
    );
  }

  void _handleForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordView()),
    );
  }

  Future<void> _handleSignIn() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final success = await _viewModel.signIn();
    if (!mounted || !success) {
      return;
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const DashboardView()),
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
                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
                  child: SizedBox(
                    width: double.infinity,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight - 44,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Iniciar sesi\u00f3n',
                              style: TextStyle(
                                fontSize: 21,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textoNegro,
                              ),
                            ),
                            const SizedBox(height: 28),
                            AuthInputField(
                              label: 'CORREO',
                              hint: 'ejemplo@correo.com',
                              controller: _viewModel.emailController,
                              validator: _viewModel.validateEmail,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: 18),
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
                            const SizedBox(height: 10),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _handleForgotPassword,
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: Size.zero,
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                                child: const Text(
                                  '\u00bfOlvidaste tu contrase\u00f1a?',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: AppColors.naranjaFerreyros,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            AuthLoginButton(
                              onPressed: _handleSignIn,
                              isLoading: _viewModel.isLoading,
                            ),
                            if (_viewModel.errorMessage.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 14),
                                child: Text(
                                  _viewModel.errorMessage,
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const SizedBox(height: 22),
                            const AuthDivider(),
                            const SizedBox(height: 18),
                            GoogleAuthButton(onPressed: _handleGoogleSignIn),
                            const SizedBox(height: 26),
                            Center(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: AppColors.textoGris,
                                  ),
                                  children: [
                                    const TextSpan(text: '\u00bfSin cuenta? '),
                                    WidgetSpan(
                                      alignment: PlaceholderAlignment.middle,
                                      child: GestureDetector(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) => const SignUpView(),
                                            ),
                                          );
                                        },
                                        child: const Text(
                                          'Reg\u00edstrate',
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
                          ],
                        ),
                      ),
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
