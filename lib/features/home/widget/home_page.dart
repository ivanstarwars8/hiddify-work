import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
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
    final connectionStatus = ref.watch(connectionNotifierProvider);

    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;
    final pingText = (delay > 0 && delay < 65000) ? "$delay ms" : "—";

    final statusText = switch (connectionStatus) {
      AsyncData(value: Connected()) => "Подключено",
      AsyncData(value: Disconnected()) => "Отключено",
      _ => "Подключение",
    };

    final statusColor = switch (connectionStatus) {
      AsyncData(value: Connected()) => const Color(0xFF00FF88),
      AsyncData(value: Disconnected()) => const Color(0xFFFF3B30),
      _ => Colors.white.withOpacity(0.7),
    };

    final expire = switch (activeProfile) {
      AsyncData(value: RemoteProfileEntity(:final subInfo)) => subInfo?.expire,
      _ => null,
    };

    final locale = Localizations.localeOf(context);
    final expireText = expire == null
        ? "—"
        : DateFormat.yMMMd(locale.toLanguageTag()).format(expire);

    final subActive = switch (activeProfile) {
      AsyncData(value: RemoteProfileEntity(:final subInfo)) =>
        subInfo == null ? true : !subInfo.isExpired,
      _ => null,
    };

    final subStatusText = subActive == null
        ? null
        : (subActive ? "Подписка активна" : "Подписка не активна");

    final subStatusColor = subActive == null
        ? null
        : (subActive ? cs.onSurface.withOpacity(0.45) : cs.error.withOpacity(0.85));

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
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
              const SizedBox(height: 8),
              Text(
                statusText,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
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
              if (subStatusText != null) ...[
                const SizedBox(height: 4),
                Text(
                  subStatusText,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: subStatusColor,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
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
    );
  }
}
