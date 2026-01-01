import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/failures.dart';
import 'package:hiddify/core/widget/go_bull_section_card.dart';
import 'package:hiddify/features/common/nested_app_bar.dart';
import 'package:hiddify/features/proxy/overview/proxies_overview_notifier.dart';
import 'package:hiddify/features/proxy/widget/proxy_tile.dart';
import 'package:hiddify/utils/utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxiesOverviewPage extends HookConsumerWidget with PresLogger {
  const ProxiesOverviewPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    final asyncProxies = ref.watch(proxiesOverviewNotifierProvider);
    final notifier = ref.watch(proxiesOverviewNotifierProvider.notifier);
    final sortBy = ref.watch(proxiesSortNotifierProvider);

    final selectActiveProxyMutation = useMutation(
      initialOnFailure: (error) =>
          CustomToast.error(t.presentShortError(error)).show(context),
    );

    final appBar = NestedAppBar(title: Text(t.proxies.pageTitle));

    switch (asyncProxies) {
      case AsyncData(value: final groups):
        if (groups.isEmpty) {
          return Scaffold(
            body: CustomScrollView(
              slivers: [
                appBar,
                SliverFillRemaining(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(t.proxies.emptyProxiesMsg),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        final group = groups.first;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              appBar,
              SliverToBoxAdapter(
                child: GoBullSectionCard(
                  title: t.proxies.pageTitle,
                  icon: Icons.public_rounded,
                  trailing: FilledButton.tonalIcon(
                    onPressed: () async => notifier.urlTest(group.tag),
                    icon: const Icon(Icons.speed_rounded),
                    label: Text(t.proxies.delayTestTooltip),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    child: Row(
                      children: [
                        const Icon(Icons.sort_rounded, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<ProxiesSort>(
                            value: sortBy,
                            decoration: InputDecoration(
                              isDense: true,
                              labelText: t.proxies.sortTooltip,
                            ),
                            items: [
                              ...ProxiesSort.values.map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text(e.present(t)),
                                ),
                              ),
                            ],
                            onChanged: (v) {
                              if (v == null) return;
                              ref.read(proxiesSortNotifierProvider.notifier).update(v);
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverLayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.crossAxisExtent;
                  if (!PlatformUtils.isDesktop && width < 648) {
                    return SliverPadding(
                      padding: const EdgeInsets.only(bottom: 16),
                      sliver: SliverList.builder(
                        itemBuilder: (_, index) {
                          final proxy = group.items[index];
                          return ProxyTile(
                            proxy,
                            selected: group.selected == proxy.tag,
                            onSelect: () async {
                              if (selectActiveProxyMutation
                                  .state.isInProgress) {
                                return;
                              }
                              selectActiveProxyMutation.setFuture(
                                notifier.changeProxy(group.tag, proxy.tag),
                              );
                            },
                          );
                        },
                        itemCount: group.items.length,
                      ),
                    );
                  }

                  return SliverGrid.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: (width / 268).floor(),
                      mainAxisExtent: 94,
                    ),
                    itemBuilder: (context, index) {
                      final proxy = group.items[index];
                      return ProxyTile(
                        proxy,
                        selected: group.selected == proxy.tag,
                        onSelect: () async {
                          if (selectActiveProxyMutation.state.isInProgress) {
                            return;
                          }
                          selectActiveProxyMutation.setFuture(
                            notifier.changeProxy(
                              group.tag,
                              proxy.tag,
                            ),
                          );
                        },
                      );
                    },
                    itemCount: group.items.length,
                  );
                },
              ),
            ],
          ),
        );

      case AsyncError(:final error):
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              appBar,
              SliverErrorBodyPlaceholder(
                t.presentShortError(error),
                icon: null,
              ),
            ],
          ),
        );

      case AsyncLoading():
        return Scaffold(
          body: CustomScrollView(
            slivers: [
              appBar,
              const SliverLoadingBodyPlaceholder(),
            ],
          ),
        );

      // TODO: remove
      default:
        return const Scaffold();
    }
  }
}
