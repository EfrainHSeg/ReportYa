import 'package:flutter/animation.dart';

class SplashBackCurve extends Curve {
  const SplashBackCurve();

  @override
  double transformInternal(double t) {
    const c1 = 1.70158;
    const c3 = c1 + 1;
    final t1 = t - 1;
    return 1 + c3 * t1 * t1 * t1 + c1 * t1 * t1;
  }
}
