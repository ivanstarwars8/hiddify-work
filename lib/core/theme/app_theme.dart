import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/theme/app_theme_mode.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';

class AppTheme {
  AppTheme(this.mode, this.fontFamily);
  final AppThemeMode mode;
  final String fontFamily;

  // GO BULL: Бордово-золотая тема с “пыльным” характером
  static const _seed = Color(0xFF6D1B1B); // Глубокий бордо (бык)
  static const _bullGold = Color(0xFFE3B23C); // Тёплый золотой акцент
  static const _bullAmber = Color(0xFFD4A017); // Янтарный
  static const _bullSurface = Color(0xFF130808); // Тёмная поверхность
  static const _bullSurfaceHigh = Color(0xFF1C0D0D);
  static const _bullSurfaceLow = Color(0xFF0F0606);

  TextTheme _textTheme(ThemeData base) {
    // GO BULL: Жирный, мощный шрифт - как бык
    final t = base.textTheme;
    return t.copyWith(
      displayLarge: t.displayLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -1),
      displayMedium: t.displayMedium?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.5),
      headlineLarge: t.headlineLarge?.copyWith(fontWeight: FontWeight.w900),
      headlineMedium: t.headlineMedium?.copyWith(fontWeight: FontWeight.w800),
      headlineSmall: t.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
      titleLarge: t.titleLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: -0.3),
      titleMedium: t.titleMedium?.copyWith(fontWeight: FontWeight.w700),
      titleSmall: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
      labelLarge: t.labelLarge?.copyWith(fontWeight: FontWeight.w800, letterSpacing: 0.5),
      labelMedium: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
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
        color: _bullSurfaceHigh,
        elevation: 3,
        shadowColor: _bullAmber.withOpacity(0.18),
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: scheme.outlineVariant.withOpacity(0.35), width: 1),
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
        backgroundColor: _bullSurface,
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: _bullSurface,
        indicatorColor: scheme.primaryContainer,
        selectedIconTheme: IconThemeData(color: scheme.onPrimaryContainer),
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
          elevation: const WidgetStatePropertyAll(6),
          shadowColor: WidgetStatePropertyAll(_bullAmber.withOpacity(0.35)),
          backgroundColor: WidgetStatePropertyAll(_seed),
          foregroundColor: const WidgetStatePropertyAll(Colors.white),
          shape: WidgetStatePropertyAll(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          textStyle: WidgetStatePropertyAll(
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w900, letterSpacing: 0.8),
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
            textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w800),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
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
      primary: _seed,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF922626),
      onPrimaryContainer: Colors.white,
      secondary: _bullGold,
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF3B2A14),
      onSecondaryContainer: Colors.white,
      surface: _bullSurface,
      surfaceTint: Colors.transparent,
      surfaceVariant: _bullSurfaceHigh,
      background: _bullSurfaceLow,
      outline: Colors.white.withOpacity(0.12),
      outlineVariant: Colors.white.withOpacity(0.08),
    );
    return _baseTheme(scheme);
  }

  ThemeData darkTheme(ColorScheme? darkColorScheme) {
    final scheme = (darkColorScheme ??
            ColorScheme.fromSeed(
              seedColor: _seed,
              brightness: Brightness.dark,
            ))
        .copyWith(
      primary: _seed,
      onPrimary: Colors.white,
      primaryContainer: const Color(0xFF922626),
      onPrimaryContainer: Colors.white,
      secondary: _bullGold,
      onSecondary: Colors.black,
      secondaryContainer: const Color(0xFF3B2A14),
      onSecondaryContainer: Colors.white,
      surface: _bullSurface,
      surfaceTint: Colors.transparent,
      surfaceVariant: _bullSurfaceHigh,
      background: _bullSurfaceLow,
      outline: Colors.white.withOpacity(0.12),
      outlineVariant: Colors.white.withOpacity(0.08),
    );

    final base = _baseTheme(scheme);
    return base.copyWith(
      scaffoldBackgroundColor: mode.trueBlack ? Colors.black : scheme.background,
    );
  }
}
