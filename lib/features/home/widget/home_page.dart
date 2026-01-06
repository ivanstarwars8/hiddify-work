import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final activeProfile = ref.watch(activeProfileProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);

    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;
    final pingText = (delay > 0 && delay < 65000) ? "$delay ms" : "—";

    final expire = switch (activeProfile) {
      AsyncData(value: final p?) => p.subInfo?.expire,
      _ => null,
    };

    final locale = Localizations.localeOf(context);
    final expireText = expire == null
        ? "—"
        : DateFormat.yMMMd(locale.toLanguageTag()).format(expire);

    return Scaffold(
      body: Stack(
        children: [
          // Premium black background with subtle depth gradient.
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFF0A0A0A),
                    Color(0xFF0F0F0F),
                    Color(0xFF0A0A0A),
                  ],
                ),
              ),
            ),
          ),
          Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const ConnectionButton(),
                  const SizedBox(height: 22),
                  Text(
                    pingText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.displaySmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    expireText,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: cs.onSurface.withOpacity(0.65),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (activeProfile case AsyncError(:final error)) ...[
                    const SizedBox(height: 18),
                    Text(
                      ref.watch(translationsProvider).presentShortError(error),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: cs.error.withOpacity(0.9),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
