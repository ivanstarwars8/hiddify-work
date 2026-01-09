import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/general_pref_tiles.dart';
import 'package:hiddify/features/per_app_proxy/model/per_app_proxy_mode.dart';
import 'package:hiddify/features/settings/notifier/platform_settings_notifier.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AdvancedSettingTiles extends HookConsumerWidget {
  const AdvancedSettingTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final debug = ref.watch(debugModeNotifierProvider);
    final perAppProxy = ref.watch(Preferences.perAppProxyMode).enabled;
    final disableMemoryLimit = ref.watch(Preferences.disableMemoryLimit);

    return Column(
      children: [
        ListTile(
          title: Text(t.config.pageTitle),
          subtitle: const Text("DNS, IPv6, маршрутизация"),
          leading: const Icon(Icons.dns_rounded),
          onTap: () async {
            await const ConfigOptionsRoute().push(context);
          },
        ),
        // const RegionPrefTile(),
        // ListTile(
        //   title: Text(t.settings.geoAssets.pageTitle),
        //   leading: const Icon(
        //     Icons.route_rounded,
        //   ),
        //   onTap: () async {
        //     // await const GeoAssetsRoute().push(context);
        //   },
        // ),
        // iOS parity: show the same tile as Android. On iOS it's not supported,
        // so we keep the layout but block interaction with a clear message.
        if (!PlatformUtils.isDesktop) ...[
          ListTile(
            title: Text(t.settings.network.perAppProxyPageTitle),
            leading: const Icon(Icons.apps_rounded),
            subtitle: Platform.isIOS
                ? const Text("Доступно только на Android")
                : null,
            trailing: Switch(
              value: perAppProxy,
              onChanged: Platform.isIOS
                  ? null
                  : (value) async {
                      final newMode = perAppProxy
                          ? PerAppProxyMode.off
                          : PerAppProxyMode.exclude;
                      await ref
                          .read(Preferences.perAppProxyMode.notifier)
                          .update(newMode);
                      if (!perAppProxy && context.mounted) {
                        await const PerAppProxyRoute().push(context);
                      }
                    },
            ),
            onTap: Platform.isIOS
                ? null
                : () async {
                    if (!perAppProxy) {
                      await ref
                          .read(Preferences.perAppProxyMode.notifier)
                          .update(PerAppProxyMode.exclude);
                    }
                    if (context.mounted) {
                      await const PerAppProxyRoute().push(context);
                    }
                  },
          ),
        ],
        SwitchListTile(
          title: Text(t.settings.advanced.memoryLimit),
          subtitle: Text(t.settings.advanced.memoryLimitMsg),
          value: !disableMemoryLimit,
          secondary: const Icon(Icons.memory_rounded),
          onChanged: (value) async {
            await ref.read(Preferences.disableMemoryLimit.notifier).update(!value);
          },
        ),
        // iOS-only action. Hide by default to keep settings layout identical to Android.
        if (Platform.isIOS && debug)
          ListTile(
            title: Text(t.settings.advanced.resetTunnel),
            leading: const Icon(Icons.restart_alt_rounded),
            onTap: () async {
              await ref.read(resetTunnelProvider.notifier).run();
            },
          ),
        SwitchListTile(
          title: Text(t.settings.advanced.debugMode),
          value: debug,
          secondary: const Icon(Icons.developer_mode_rounded),
          onChanged: (value) async {
            if (value) {
              await showDialog<bool>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: Text(t.settings.advanced.debugMode),
                    content: Text(t.settings.advanced.debugModeMsg),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).maybePop(true),
                        child: Text(
                          MaterialLocalizations.of(context).okButtonLabel,
                        ),
                      ),
                    ],
                  );
                },
              );
            }
            await ref.read(debugModeNotifierProvider.notifier).update(value);
          },
        ),
      ],
    );
  }
}
