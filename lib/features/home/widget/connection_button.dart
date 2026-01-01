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
            // GO BULL: Круглая «кнопка-герой»
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  buttonColor.withOpacity(0.30),
                  buttonColor.withOpacity(0.10),
                  cs.surfaceContainerLow,
                ],
                center: Alignment.topLeft,
                radius: 1.0,
              ),
              border: Border.all(
                color: buttonColor.withOpacity(0.45),
                width: 2.4,
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 36,
                  spreadRadius: 6,
                  color: buttonColor.withOpacity(0.45),
                ),
                BoxShadow(
                  blurRadius: 10,
                  spreadRadius: 0,
                  color: buttonColor.withOpacity(0.28),
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            width: 180,
            height: 180,
            child: Material(
              key: const ValueKey("home_connection_button"),
              color: cs.surface,
              surfaceTintColor: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: TweenAnimationBuilder(
                    tween: ColorTween(end: buttonColor),
                    duration: const Duration(milliseconds: 250),
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 56,
                            height: 56,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: (value ?? buttonColor).withOpacity(0.14),
                              border: Border.all(
                                color: (value ?? buttonColor).withOpacity(0.3),
                              ),
                            ),
                            child: Icon(
                              enabled ? Icons.bolt_rounded : Icons.bolt_outlined,
                              color: value ?? buttonColor,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.2,
                                color: cs.onSurface,
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ).animate(target: enabled ? 0 : 1).blurXY(end: 0.8),
          ).animate(target: enabled ? 0 : 1).scaleXY(end: .97, curve: Curves.easeIn),
        ),
        const Gap(10),
      ],
    );
  }
}
