import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/theme/theme_extensions.dart';
import 'package:hiddify/core/widget/animated_text.dart';
import 'package:hiddify/features/config_option/data/config_option_repository.dart';
import 'package:hiddify/features/config_option/notifier/config_option_notifier.dart';
import 'package:hiddify/features/connection/model/connection_status.dart';
import 'package:hiddify/features/connection/notifier/connection_notifier.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// TODO: rewrite
class ConnectionButton extends HookConsumerWidget {
  const ConnectionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final connectionStatus = ref.watch(connectionNotifierProvider);
    final activeProxy = ref.watch(activeProxyNotifierProvider);
    final delay = activeProxy.valueOrNull?.urlTestDelay ?? 0;

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

    return _ConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Disconnected()) || AsyncError() => () async => ref.read(connectionNotifierProvider.notifier).toggleConnection(),
        AsyncData(value: Connected()) => () async {
            if (requiresReconnect == true) {
              return await ref.read(connectionNotifierProvider.notifier).reconnect(await ref.read(activeProfileProvider.future));
            }
            return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
          },
        _ => () {},
      },
      enabled: switch (connectionStatus) {
        AsyncData(value: Connected()) || AsyncData(value: Disconnected()) || AsyncError() => true,
        _ => false,
      },
      label: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => t.connection.reconnect,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => t.connection.connecting,
        AsyncData(value: final status) => status.present(t),
        _ => "",
      },
      // GO BULL: Бордово-золотая цветовая схема
      buttonColor: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => const Color(0xFFDDAA45), // янтарный “reconnect”
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => const Color(0xFFE3B23C), // тёплый “подключаем”
        AsyncData(value: Connected()) => const Color(0xFF2FBF71), // зелёный “подключено”
        AsyncData(value: _) => const Color(0xFF8E1B1B), // бордо “ожидание/откл”
        _ => const Color(0xFFC62828), // красный “ошибка”
      },
    );
  }
}

class _ConnectionButton extends StatelessWidget {
  const _ConnectionButton({
    required this.onTap,
    required this.enabled,
    required this.label,
    required this.buttonColor,
  });

  final VoidCallback onTap;
  final bool enabled;
  final String label;
  final Color buttonColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Semantics(
          button: true,
          enabled: enabled,
          label: label,
          child: Container(
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: cs.surface,
              border: Border.all(
                color: buttonColor.withOpacity(0.6),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 48,
                  spreadRadius: 4,
                  color: buttonColor.withOpacity(0.35),
                ),
              ],
            ),
            width: 140,
            height: 140,
            child: Material(
              key: const ValueKey("home_connection_button"),
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                customBorder: const CircleBorder(),
                child: TweenAnimationBuilder(
                  tween: ColorTween(end: buttonColor),
                  duration: const Duration(milliseconds: 250),
                  builder: (context, value, child) {
                    return Center(
                      child: Icon(
                        Icons.bolt_rounded,
                        color: value ?? buttonColor,
                        size: 56,
                      ),
                    );
                  },
                ),
              ),
            ).animate(target: enabled ? 0 : 1).blurXY(end: 0.8),
          ).animate(target: enabled ? 0 : 1).scaleXY(end: .97, curve: Curves.easeIn),
        ),
        const Gap(14),
        Text(
          label,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: buttonColor,
          ),
        ),
      ],
    );
  }
}
