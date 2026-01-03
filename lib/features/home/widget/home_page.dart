import 'package:dartx/dartx.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/app_info/app_info_provider.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/home/widget/connection_button.dart';
import 'package:hiddify/features/home/widget/empty_profiles_home_body.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/widget/profile_tile.dart';
import 'package:hiddify/features/proxy/active/active_proxy_delay_indicator.dart';
import 'package:hiddify/features/proxy/active/active_proxy_footer.dart';
import 'package:hiddify/features/proxy/active/active_proxy_notifier.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

class HomePage extends HookConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAnyProfile = ref.watch(hasAnyProfileProvider);
    final activeProfile = ref.watch(activeProfileProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Бордовый градиент + “пыльный” слой
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF160808),
                    Color(0xFF2A0F0F),
                    Color(0xFF120606),
                  ],
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: SvgPicture.asset(
                'assets/images/noise_overlay.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.25),
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          CustomScrollView(
            slivers: [
              _GoBullHomeHeader(
                title: Constants.appName,
                onAddProfile: () => const AddProfileRoute().push(context),
                addProfileTooltip: t.profile.add.buttonText,
              ),
              switch (activeProfile) {
                AsyncData(value: final profile?) => MultiSliver(
                    children: [
                      const SliverToBoxAdapter(child: SizedBox(height: 8)),
                      ProfileTile(profile: profile, isMain: true),
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ConnectionButton(),
                                  ActiveProxyDelayIndicator(),
                                ],
                              ),
                            ),
                            if (MediaQuery.sizeOf(context).width < 840) const ActiveProxyFooter(),
                          ],
                        ),
                      ),
                    ],
                  ),
                AsyncData() => switch (hasAnyProfile) {
                    AsyncData(value: true) => const EmptyActiveProfileHomeBody(),
                    _ => const EmptyProfilesHomeBody(),
                  },
                AsyncError(:final error) => SliverErrorBodyPlaceholder(t.presentShortError(error)),
                _ => const SliverToBoxAdapter(),
              },
            ],
          ),
        ],
      ),
    );
  }
}

class _GoBullHomeHeader extends StatelessWidget {
  const _GoBullHomeHeader({
    required this.title,
    required this.onAddProfile,
    required this.addProfileTooltip,
  });

  final String title;
  final VoidCallback onAddProfile;
  final String addProfileTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return SliverAppBar(
      pinned: true,
      expandedHeight: 132,
      automaticallyImplyLeading: false,
      backgroundColor: cs.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        expandedTitleScale: 1.0,
        titlePadding: const EdgeInsetsDirectional.only(start: 16, bottom: 14, end: 16),
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: cs.primaryContainer,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Assets.images.logo.svg(
                colorFilter: ColorFilter.mode(cs.onPrimaryContainer, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const AppVersionLabel(),
          ],
        ),
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                const Color(0xFF3A1212),
                cs.surface,
              ],
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsetsDirectional.only(top: 8, end: 12),
                child: IconButton.filled(
                  onPressed: onAddProfile,
                  tooltip: addProfileTooltip,
                  icon: const Icon(Icons.add_rounded),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppVersionLabel extends HookConsumerWidget {
  const AppVersionLabel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final theme = Theme.of(context);

    final version = ref.watch(appInfoProvider).requireValue.presentVersion;
    if (version.isBlank) return const SizedBox();

    return Semantics(
      label: t.about.version,
      button: false,
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: 4,
          vertical: 1,
        ),
        child: Text(
          version,
          textDirection: TextDirection.ltr,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSecondaryContainer,
          ),
        ),
      ),
    );
  }
}
