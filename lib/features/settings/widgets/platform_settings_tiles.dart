import 'dart:io';

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/settings/notifier/platform_settings_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class PlatformSettingsTiles extends HookConsumerWidget {
  const PlatformSettingsTiles({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    ListTile buildIgnoreTile(bool enabled) => ListTile(
          title: Text(t.settings.general.ignoreBatteryOptimizations),
          subtitle: Platform.isAndroid
              ? Text(t.settings.general.ignoreBatteryOptimizationsMsg)
              : const Text("Доступно только на Android"),
          leading: const Icon(Icons.battery_saver_rounded),
          enabled: enabled,
          onTap: () async {
            await ref
                .read(ignoreBatteryOptimizationsProvider.notifier)
                .request();
          },
        );

    return Column(
      children: [
        if (Platform.isAndroid)
          switch (ref.watch(ignoreBatteryOptimizationsProvider)) {
            AsyncData(:final value) when value == false => buildIgnoreTile(true),
            AsyncData(:final value) when value == true => const SizedBox(),
            _ => buildIgnoreTile(false),
          }
        else
          buildIgnoreTile(false),
      ],
    );
  }
}
