import 'package:flutter/material.dart';
import 'package:hiddify/features/proxy/model/proxy_entity.dart';
import 'package:hiddify/gen/fonts.gen.dart';
import 'package:hiddify/utils/custom_loggers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ProxyTile extends HookConsumerWidget with PresLogger {
  const ProxyTile(
    this.proxy, {
    super.key,
    required this.selected,
    required this.onSelect,
  });

  final ProxyItemEntity proxy;
  final bool selected;
  final VoidCallback onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final delay = proxy.urlTestDelay;
    final hasDelay = delay != 0;
    final timeout = delay > 65000;

    String delayText() {
      if (!hasDelay) return "…";
      if (timeout) return "TIMEOUT";
      return "${delay}ms";
    }

    final delayColor = hasDelay
        ? (timeout ? cs.error : delayColorFor(context, delay))
        : cs.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onSelect,
          onLongPress: () async {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                content: SelectionArea(child: Text(proxy.name)),
                actions: [
                  TextButton(
                    onPressed: Navigator.of(context).pop,
                    child: Text(MaterialLocalizations.of(context).closeButtonLabel),
                  ),
                ],
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 10,
                  height: 38,
                  decoration: BoxDecoration(
                    color: selected ? cs.primary : cs.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        proxy.name,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: FontFamily.emoji,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proxy.selectedName != null
                            ? "${proxy.type.label} · ${proxy.selectedName}"
                            : proxy.type.label,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: delayColor.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: delayColor.withOpacity(0.25)),
                  ),
                  child: Text(
                    delayText(),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: delayColor,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Icon(
                  Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Color delayColorFor(BuildContext context, int delay) {
    if (Theme.of(context).brightness == Brightness.dark) {
      return switch (delay) { < 800 => Colors.lightGreen, < 1500 => Colors.orange, _ => Colors.redAccent };
    }
    return switch (delay) { < 800 => Colors.green, < 1500 => Colors.deepOrangeAccent, _ => Colors.red };
  }
}
