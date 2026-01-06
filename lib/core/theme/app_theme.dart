import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);
  final AppThemeMode mode;
  final String fontFamily;

  // Premium dark: polished stone + minimal electronics.
  // Keep accent colors subtle; vivid accents are reserved for state indication.
  static const _seed = Color(0xFF2F2F2F);
  static const _trueBlack = Color(0xFF0A0A0A);
  static const _surface = Color(0xFF121212);
  static const _surfaceHigh = Color(0xFF1A1A1A);
  static const _surfaceHighest = Color(0xFF232323);
  static const _surfaceLow = Color(0xFF0E0E0E);

  TextTheme _textTheme(ThemeData base) {
    final t = base.textTheme;
    return t.copyWith(
      displayLarge: t.displayLarge?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.8,
      ),
      displayMedium: t.displayMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -0.5,
      ),
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w700),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
      titleLarge: t.titleLarge?.copyWith(
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
      ),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w600),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w700),
      labelMedium: t.labelMedium?.copyWith(fontWeight: FontWeight.w600),
    );
  }

  ThemeData _baseTheme(ColorScheme scheme) {
    // iOS parity: force Material widgets to render with Android visuals so the
    // UI matches Android pixel-for-pixel as close as possible.
    final platform = defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.windows ||
            defaultTargetPlatform == TargetPlatform.macOS
        ? TargetPlatform.android
        : defaultTargetPlatform;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: fontFamily,
      platform: platform,
    );

    final textTheme = _textTheme(base);

    return base.copyWith(
      textTheme: textTheme,
      // iOS parity: force Android-like page transitions everywhere.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: <TargetPlatform, PageTransitionsBuilder>{
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.macOS: ZoomPageTransitionsBuilder(),
          TargetPlatform.linux: ZoomPageTransitionsBuilder(),
          TargetPlatform.windows: ZoomPageTransitionsBuilder(),
          TargetPlatform.fuchsia: ZoomPageTransitionsBuilder(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(color: scheme.onSurface),
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardTheme(
        color: _surfaceHigh,
        elevation: 10,
        shadowColor: Colors.black.withOpacity(0.65),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(
            color: scheme.outlineVariant.withOpacity(0.35),
            width: 1,
          ),
        ),
      ),
      listTileTheme: ListTileThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 68,
        backgroundColor: scheme.surface,
        indicatorColor: scheme.surfaceVariant,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: scheme.surfaceVariant,
        selectedIconTheme: IconThemeData(color: scheme.onSurface),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        unselectedLabelTextStyle: textTheme.labelMedium?.copyWith(
          color: scheme.onSurfaceVariant,
          fontWeight: FontWeight.w600,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          ),
          elevation: const WidgetStatePropertyAll(10),
          shadowColor: WidgetStatePropertyAll(Colors.black.withOpacity(0.55)),
          backgroundColor: const WidgetStatePropertyAll(_surfaceHighest),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          ),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest.withOpacity(0.9),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(0.7),
        thickness: 1,
        space: 1,
      ),
      extensions: const <ThemeExtension<dynamic>>{
        ConnectionButtonTheme.light,
      },
    );
  }

  ThemeData lightTheme(ColorScheme? lightColorScheme) {
    final scheme = (lightColorScheme ??
            ColorScheme.fromSeed(
              seedColor: _seed,
              brightness: Brightness.dark,
            ))
        .copyWith(
      primary: const Color(0xFFBDBDBD),
      onPrimary: Colors.black,
      primaryContainer: _surfaceHighest,
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF9E9E9E),
      onSecondary: Colors.black,
      secondaryContainer: _surfaceHighest,
      onSecondaryContainer: Colors.white,
      surface: _surface,
      surfaceTint: Colors.transparent,
      surfaceVariant: _surfaceHigh,
      background: _surfaceLow,
      outline: Colors.white.withOpacity(0.12),
      outlineVariant: Colors.white.withOpacity(0.08),
      error: const Color(0xFFFF3B30),
    );
    final base = _baseTheme(scheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
    );
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final scheme = (darkColorScheme ??
            ColorScheme.fromSeed(
              seedColor: _seed,
              brightness: Brightness.dark,
            ))
        .copyWith(
      primary: const Color(0xFFBDBDBD),
      onPrimary: Colors.black,
      primaryContainer: _surfaceHighest,
      onPrimaryContainer: Colors.white,
      secondary: const Color(0xFF9E9E9E),
      onSecondary: Colors.black,
      secondaryContainer: _surfaceHighest,
      onSecondaryContainer: Colors.white,
      surface: _surface,
      surfaceTint: Colors.transparent,
      surfaceVariant: _surfaceHigh,
      background: _surfaceLow,
      outline: Colors.white.withOpacity(0.12),
      outlineVariant: Colors.white.withOpacity(0.08),
      error: const Color(0xFFFF3B30),
    );

    final base = _baseTheme(scheme);
    return base.copyWith(
      scaffoldBackgroundColor: Colors.transparent,
    );
  }
}
