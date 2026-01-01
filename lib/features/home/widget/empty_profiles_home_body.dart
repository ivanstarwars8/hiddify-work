import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class EmptyProfilesHomeBody extends HookConsumerWidget {
  const EmptyProfilesHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(26),
            ),
            child: Assets.images.logo.svg(
              colorFilter: ColorFilter.mode(
                Theme.of(context).colorScheme.onPrimaryContainer,
                BlendMode.srcIn,
              ),
            ),
          ),
          const Gap(14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              t.home.emptyProfilesMsg,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          const Gap(16),
          FilledButton.icon(
            onPressed: () => const AddProfileRoute().push(context),
            icon: const Icon(Icons.add_rounded),
            label: Text(t.profile.add.buttonText),
          ),
        ],
      ),
    );
  }
}

class EmptyActiveProfileHomeBody extends HookConsumerWidget {
  const EmptyActiveProfileHomeBody({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return SliverFillRemaining(
      hasScrollBody: false,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(t.home.noActiveProfileMsg),
          const Gap(16),
          OutlinedButton(
            onPressed: () => const ProfilesOverviewRoute().push(context),
            child: Text(t.profile.overviewPageTitle),
          ),
        ],
      ),
    );
  }
}
