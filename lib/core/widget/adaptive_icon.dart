import 'package:flutter/material.dart';

class AdaptiveIcon {
  AdaptiveIcon(BuildContext context) : platform = Theme.of(context).platform;

  final TargetPlatform platform;

  // Go Bull iOS parity: use the same Material icons as Android everywhere.
  IconData get more => Icons.more_vert;

  IconData get share => Icons.share_rounded;
}
