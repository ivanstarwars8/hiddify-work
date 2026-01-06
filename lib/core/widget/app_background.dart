import 'package:flutter/material.dart';

class AppBackground extends StatelessWidget {
  const AppBackground({required this.child, super.key});

  final Widget child;

  static const _assetPath = 'assets/images/app_background.png';

  // The source image is 1024x1536 (2:3).
  static const _imageAspect = 1024 / 1536;

  bool _shouldShowImage(double screenAspect) {
    // If aspect is too different, the image won't "fit" naturally without
    // cropping or excessive empty space. In that case we fallback to the
    // default premium dark background (no image) as requested.
    final relDiff = ((screenAspect / _imageAspect) - 1).abs();
    return relDiff <= 0.12;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;
        final screenAspect = (w > 0 && h > 0) ? (w / h) : _imageAspect;
        final showImage = _shouldShowImage(screenAspect);

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


