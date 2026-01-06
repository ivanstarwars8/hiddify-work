import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  static const _assetPath = 'assets/images/app_background.png';

  // The source image is 1024x1536 (2:3).
  static const _imageAspect = 1024 / 1536;

  bool _shouldShowImage({
    required double screenAspect,
    required double w,
    required double h,
  }) {
    // Show on portrait phones (cropping is acceptable and looks natural).
    // Hide on landscape / very wide layouts where the photo becomes awkward.
    final isPortrait = h >= w;
    if (!isPortrait) return false;

    // Typical phones: ~0.45..0.60. Tablets can be ~0.75.
    // If too wide, fallback to plain premium dark background.
    if (screenAspect > 0.82) return false;

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final screenAspect = (w > 0 && h > 0) ? (w / h) : _imageAspect;
        final showImage = _shouldShowImage(
          screenAspect: screenAspect,
          w: w,
          h: h,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            if (showImage)
              Image.asset(
                _assetPath,
                fit: BoxFit.cover,
                alignment: Alignment.center,
                filterQuality: FilterQuality.high,
              ),
            // Always keep premium dark base to ensure readability.
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xF20A0A0A),
                    Color(0xE6101010),
                    Color(0xF20A0A0A),
                  ],
                ),
              ),
            ),
            child,
          ],
        );
      },
    );
  }
}


