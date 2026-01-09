import 'package:flutter/material.dart';

/// Go Bull logo that stays readable on both light and dark surfaces.
///
/// Uses the monochrome alpha mask from `assets/images/app_logo.png` and
/// recolors it to white in dark mode.
class GoBullLogo extends StatelessWidget {
  const GoBullLogo({
    super.key,
    this.size = 120,
    this.opacity = 1,
  });

  final double size;
  final double opacity;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final color = isDark ? Colors.white : null;

    return Opacity(
      opacity: opacity.clamp(0, 1),
      child: Image.asset(
        'assets/images/app_logo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        color: color,
      ),
    );
  }
}


