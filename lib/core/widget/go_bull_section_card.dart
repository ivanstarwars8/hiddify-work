import 'package:flutter/material.dart';

class GoBullSectionCard extends StatelessWidget {
  const GoBullSectionCard({
    super.key,
    required this.title,
    this.icon,
    this.trailing,
    required this.child,
    this.margin = const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
    this.padding = const EdgeInsets.fromLTRB(14, 14, 14, 10),
  });

  final String title;
  final IconData? icon;
  final Widget? trailing;
  final Widget child;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Padding(
      padding: margin,
      child: Card(
        child: Padding(
          padding: padding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  if (icon != null) ...[
                    Icon(icon, color: cs.onSurfaceVariant),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    child: Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                  if (trailing != null) trailing!,
                ],
              ),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}


