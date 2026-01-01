import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/widget/go_bull_section_card.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/settings/widgets/widgets.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class SettingsOverviewPage extends HookConsumerWidget {
  const SettingsOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          NestedAppBar(
            title: Text(t.settings.pageTitle),
          ),
          SliverToBoxAdapter(
            child: Column(
              children: [
                GoBullSectionCard(
                  title: t.settings.general.sectionTitle,
                  icon: Icons.tune_rounded,
                  child: const Column(
                    children: [
                      GeneralSettingTiles(),
                      PlatformSettingsTiles(),
                    ],
                  ),
                ),
                GoBullSectionCard(
                  title: t.settings.advanced.sectionTitle,
                  icon: Icons.build_rounded,
                  child: const AdvancedSettingTiles(),
                ),
                const Gap(16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
