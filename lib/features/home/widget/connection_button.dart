import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/access/notifier/access_gate_provider.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProfile = ref.watch(activeProfileProvider);
    final hasAccess = ref.watch(hasValidGoBullSubscriptionProvider).valueOrNull;

    final requiresReconnect = ref.watch(configOptionNotifierProvider).valueOrNull;

    ref.listen(
      connectionNotifierProvider,
      (_, next) {
        if (next case AsyncError(:final error)) {
          CustomAlertDialog.fromErr(t.presentError(error)).show(context);
        }
        if (next case AsyncData(value: Disconnected(:final connectionFailure?))) {
          CustomAlertDialog.fromErr(t.presentError(connectionFailure)).show(context);
        }
      },
    );

    final buttonTheme = Theme.of(context).extension<ConnectionButtonTheme>()!;

    final stateColor = switch (connectionStatus) {
      AsyncData(value: Connected()) => buttonTheme.connectedColor ?? const Color(0xFF00FF88),
      AsyncData(value: Disconnected()) => buttonTheme.idleColor ?? const Color(0xFFFF3B30),
      // Connecting / error: no vivid accent; keep subtle white.
      _ => Colors.white.withOpacity(0.65),
    };

    // Gate by the same condition as Access Gate: no valid Go Bull subscription -> block enabling.
    final isSubscriptionInactive = (hasAccess == false) ||
        switch (activeProfile) {
          AsyncData(value: RemoteProfileEntity(:final subInfo)) => subInfo?.isExpired == true,
          _ => false,
        };

    // Block ONLY enabling VPN when subscription is inactive (disconnect is always allowed).
    final blockConnect = isSubscriptionInactive &&
        connectionStatus is AsyncData<ConnectionStatus> &&
        connectionStatus.value is Disconnected;

    void showPaywall() {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Оплатите подписку и обновите её через меню"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }

    final computedOnTap = switch (connectionStatus) {
      AsyncData(value: Disconnected()) || AsyncError() =>
        () async => ref.read(connectionNotifierProvider.notifier).toggleConnection(),
      AsyncData(value: Connected()) => () async {
          if (requiresReconnect == true) {
            return await ref
                .read(connectionNotifierProvider.notifier)
                .reconnect(await ref.read(activeProfileProvider.future));
          }
          return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
        },
      _ => () {},
    };

    final computedEnabled = switch (connectionStatus) {
      AsyncData(value: Connected()) ||
      AsyncData(value: Disconnected()) ||
      AsyncError() =>
        true,
      _ => false,
    };

    return _ConnectionButton(
      onTap: blockConnect ? showPaywall : computedOnTap,
      enabled: computedEnabled && !blockConnect,
      disabledTap: blockConnect ? showPaywall : null,
      blocked: blockConnect,
      semanticsLabel: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: final status) => status.present(t),
        _ => "",
      },
      stateColor: stateColor,
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.blocked,
    required this.semanticsLabel,
    required this.stateColor,
    this.disabledTap,
  });

  final VoidCallback onTap;
  final bool enabled;
  final bool blocked;
  final String semanticsLabel;
  final Color stateColor;
  final VoidCallback? disabledTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    const materialTop = Color(0xFF3A3A3A);
    const materialBottom = Color(0xFF2A2A2A);

    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel,
      child: Container(
        width: 180,
        height: 180,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [materialTop, materialBottom],
          ),
          boxShadow: [
            // Deep drop shadow (physical button)
            BoxShadow(
              color: Colors.black.withOpacity(0.75),
              blurRadius: 48,
              offset: const Offset(0, 22),
            ),
            // Soft top highlight
            BoxShadow(
              color: Colors.white.withOpacity(0.06),
              blurRadius: 20,
              offset: const Offset(0, -8),
            ),
            // State glow (thin neon edge + soft halo)
            BoxShadow(
              color: stateColor.withOpacity(0.22),
              blurRadius: 36,
              spreadRadius: 2,
            ),
          ],
          border: Border.all(
            color: stateColor.withOpacity(0.9),
            width: 2,
          ),
        ),
        child: Material(
          key: const ValueKey("home_connection_button"),
          color: Colors.transparent,
          child: InkWell(
            onTap: enabled ? onTap : (disabledTap ?? null),
            customBorder: const CircleBorder(),
            splashColor: Colors.white.withOpacity(0.06),
            highlightColor: Colors.white.withOpacity(0.03),
            child: Center(
              child: Icon(
                Icons.power_settings_new_rounded,
                color: cs.onSurface.withOpacity(0.9),
                size: 56,
              ),
            ),
          ),
        )
            .animate(target: enabled && !blocked ? 0 : 1)
            .blurXY(end: 0.9)
            .fade(end: 0.85),
      ).animate(target: enabled && !blocked ? 0 : 1).scaleXY(end: .98, curve: Curves.easeIn),
    );
  }
}
