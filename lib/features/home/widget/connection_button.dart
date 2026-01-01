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
import 'package:hiddify/features/connection/widget/experimental_feature_notice.dart';
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

    Future<bool> showExperimentalNotice() async {
      final hasExperimental = ref.read(ConfigOptions.hasExperimentalFeatures);
      final canShowNotice = !ref.read(disableExperimentalFeatureNoticeProvider);
      if (hasExperimental && canShowNotice && context.mounted) {
        return await const ExperimentalFeatureNoticeDialog().show(context) ?? false;
      }
      return true;
    }

    return _ConnectionButton(
      onTap: switch (connectionStatus) {
        AsyncData(value: Disconnected()) || AsyncError() => () async {
            if (await showExperimentalNotice()) {
              return await ref.read(connectionNotifierProvider.notifier).toggleConnection();
            }
          },
        AsyncData(value: Connected()) => () async {
            if (requiresReconnect == true && await showExperimentalNotice()) {
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
      buttonColor: switch (connectionStatus) {
        AsyncData(value: Connected()) when requiresReconnect == true => Colors.teal,
        AsyncData(value: Connected()) when delay <= 0 || delay >= 65000 => Color.fromARGB(255, 185, 176, 103),
        AsyncData(value: Connected()) => buttonTheme.connectedColor!,
        AsyncData(value: _) => buttonTheme.idleColor!,
        _ => Colors.red,
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
              borderRadius: BorderRadius.circular(34),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  buttonColor.withOpacity(0.22),
                  cs.surfaceContainerLow,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  blurRadius: 28,
                  spreadRadius: 2,
                  color: buttonColor.withOpacity(0.35),
                ),
              ],
            ),
            width: 188,
            height: 136,
            child: Material(
              key: const ValueKey("home_connection_button"),
              color: cs.surface,
              surfaceTintColor: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 18),
                  child: TweenAnimationBuilder(
                    tween: ColorTween(end: buttonColor),
                    duration: const Duration(milliseconds: 250),
                    builder: (context, value, child) {
                      return Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: (value ?? buttonColor).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: (value ?? buttonColor).withOpacity(0.25),
                              ),
                            ),
                            child: Icon(
                              enabled ? Icons.bolt_rounded : Icons.bolt_outlined,
                              color: value ?? buttonColor,
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
            ).animate(target: enabled ? 0 : 1).blurXY(end: 1),
          ).animate(target: enabled ? 0 : 1).scaleXY(end: .96, curve: Curves.easeIn),
        ),
        const Gap(10),
      ],
    );
  }
}
