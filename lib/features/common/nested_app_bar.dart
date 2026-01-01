import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/bootstrap.dart';
import 'package:hiddify/core/router/router.dart';
import 'package:hiddify/features/common/adaptive_root_scaffold.dart';
import 'package:hiddify/gen/assets.gen.dart';
import 'package:hiddify/utils/utils.dart';

bool showDrawerButton(BuildContext context) {
  if (!useMobileRouter) return true;
  final String location = GoRouterState.of(context).uri.path;
  if (location == const HomeRoute().location || location == const ProfilesOverviewRoute().location) return true;
  if (location.startsWith(const ProxiesRoute().location)) return true;
  return false;
}

class NestedAppBar extends StatelessWidget {
  const NestedAppBar({
    super.key,
    this.title,
    this.actions,
    this.pinned = true,
    this.forceElevated = false,
    this.bottom,
    this.showGoBullMark = true,
    this.expandedHeight = 96,
  });

  final Widget? title;
  final List<Widget>? actions;
  final bool pinned;
  final bool forceElevated;
  final PreferredSizeWidget? bottom;
  final bool showGoBullMark;
  final double expandedHeight;

  Widget? _decorateTitle(BuildContext context) {
    if (title == null) return null;
    if (!showGoBullMark) return title;

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: cs.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Assets.images.logo.svg(
            colorFilter: ColorFilter.mode(cs.onPrimaryContainer, BlendMode.srcIn),
          ),
        ),
        const SizedBox(width: 10),
        Flexible(child: DefaultTextStyle.merge(maxLines: 1, overflow: TextOverflow.ellipsis, child: title!)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    RootScaffold.canShowDrawer(context);

    return SliverAppBar(
      leading: (RootScaffold.stateKey.currentState?.hasDrawer ?? false) && showDrawerButton(context)
          ? DrawerButton(
              onPressed: () {
                RootScaffold.stateKey.currentState?.openDrawer();
              },
            )
          : (Navigator.of(context).canPop()
              ? IconButton(
                  icon: Icon(context.isRtl ? Icons.arrow_forward : Icons.arrow_back),
                  padding: EdgeInsets.only(right: context.isRtl ? 50 : 0),
                  onPressed: () {
                    Navigator.of(context).pop(); // Pops the current route off the navigator stack
                  },
                )
              : null),
      title: _decorateTitle(context),
      actions: actions,
      pinned: pinned,
      forceElevated: forceElevated,
      bottom: bottom,
      expandedHeight: expandedHeight,
      backgroundColor: Theme.of(context).colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.10),
                Theme.of(context).colorScheme.surface,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
