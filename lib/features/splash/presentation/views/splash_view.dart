import 'package:flutter/material.dart';
import 'package:reportya/features/auth/presentation/views/sign_in_view.dart';
import 'package:reportya/features/splash/presentation/viewmodels/splash_viewmodel.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_back_curve.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_background.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_brand_word.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_chart.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_ferreyros_badge.dart';
import 'package:reportya/features/splash/presentation/widgets/splash_loading_dots.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView>
    with TickerProviderStateMixin {
  late final AnimationController _barsController;
  late final List<Animation<double>> _barAnimations;
  late final Animation<double> _baseAnimation;

  late final AnimationController _lineController;
  late final Animation<double> _lineAnimation;
  late final List<Animation<double>> _dotAnimations;

  late final AnimationController _uiController;
  late final List<Animation<double>> _letterAnimations;
  late final Animation<double> _lineDecorWidth;
  late final Animation<double> _badgeFade;
  late final Animation<double> _dotsFade;

  late final AnimationController _pulseController;
  late final Animation<double> _pulse;
  late final AnimationController _exitController;
  late final Animation<double> _exitFade;

  final _viewModel = SplashViewModel();

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _runSequence();
    _prepareAndNavigate();
  }

  void _setupAnimations() {
    _barsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    );
    _barAnimations = [
      CurvedAnimation(
        parent: _barsController,
        curve: const Interval(0.00, 0.75, curve: SplashBackCurve()),
      ),
      CurvedAnimation(
        parent: _barsController,
        curve: const Interval(0.12, 0.88, curve: SplashBackCurve()),
      ),
      CurvedAnimation(
        parent: _barsController,
        curve: const Interval(0.06, 0.82, curve: SplashBackCurve()),
      ),
    ];
    _baseAnimation = CurvedAnimation(
      parent: _barsController,
      curve: const Interval(0.15, 0.70, curve: Curves.easeOutCubic),
    );

    _lineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _lineAnimation = CurvedAnimation(
      parent: _lineController,
      curve: Curves.easeInOutCubic,
    );
    _dotAnimations = List.generate(3, (index) {
      return CurvedAnimation(
        parent: _lineController,
        curve: Interval(
          0.35 + index * 0.18,
          (0.65 + index * 0.18).clamp(0.0, 1.0),
          curve: const SplashBackCurve(),
        ),
      );
    });

    _uiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    );
    _letterAnimations = List.generate(8, (index) {
      final start = index * 0.055;
      final end = (start + 0.28).clamp(0.0, 1.0);
      return CurvedAnimation(
        parent: _uiController,
        curve: Interval(start, end, curve: Curves.easeOutCubic),
      );
    });
    _lineDecorWidth = Tween<double>(
      begin: 44,
      end: 130,
    ).animate(
      CurvedAnimation(
        parent: _uiController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeInOutSine),
      ),
    );
    _badgeFade = CurvedAnimation(
      parent: _uiController,
      curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
    );
    _dotsFade = CurvedAnimation(
      parent: _uiController,
      curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    );
    _pulse = Tween<double>(
      begin: 1.0,
      end: 1.5,
    ).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _exitController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _exitFade = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(
      CurvedAnimation(
        parent: _exitController,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  Future<void> _runSequence() async {
    await _barsController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 160));
    await _lineController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _uiController.forward();
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (mounted) {
      _pulseController.repeat(reverse: true);
    }
  }

  Future<void> _prepareAndNavigate() async {
    await _viewModel.prepareApp();
    if (!mounted) {
      return;
    }

    await _exitController.forward();
    if (!mounted) {
      return;
    }

    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => const SignInView(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeIn,
            ),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 350),
      ),
    );
  }

  @override
  void dispose() {
    _barsController.dispose();
    _lineController.dispose();
    _uiController.dispose();
    _pulseController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SplashBackground(),
          Center(
            child: AnimatedBuilder(
              animation: Listenable.merge([
                _barsController,
                _lineController,
                _uiController,
                _pulseController,
                _exitController,
              ]),
              builder: (context, _) {
                return Opacity(
                  opacity: _exitFade.value,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SplashChart(
                        barProgress: _barAnimations.map((item) => item.value).toList(),
                        baseProgress: _baseAnimation.value,
                        lineProgress: _lineAnimation.value,
                        dotProgress: _dotAnimations.map((item) => item.value).toList(),
                      ),
                      const SizedBox(height: 22),
                      SplashBrandWord(
                        progress: _letterAnimations.map((item) => item.value).toList(),
                      ),
                      const SizedBox(height: 14),
                      Opacity(
                        opacity: _letterAnimations.last.value,
                        child: Container(
                          width: _lineDecorWidth.value,
                          height: 4,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5821F),
                            borderRadius: BorderRadius.circular(99),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Opacity(
                        opacity: _badgeFade.value,
                        child: Transform.translate(
                          offset: Offset(0, (1 - _badgeFade.value) * 12),
                          child: const SplashFerreyrosBadge(),
                        ),
                      ),
                      const SizedBox(height: 52),
                      Opacity(
                        opacity: _dotsFade.value,
                        child: SplashLoadingDots(pulse: _pulse.value),
                      ),
                    ],
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
