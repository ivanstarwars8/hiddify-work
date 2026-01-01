import 'package:flutter/material.dart';

class AdaptiveIcon {
  AdaptiveIcon(BuildContext context) : platform = Theme.of(context).platform;

  final TargetPlatform platform;

  IconData get more => switch (platform) {
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          Icons.more_horiz,
        _ => Icons.more_vert,
      };

  IconData get share => switch (platform) {
        TargetPlatform.android => Icons.share_rounded,
        TargetPlatform.iOS ||
        TargetPlatform.macOS =>
          Icons.ios_share_rounded,
        _ => Icons.share,
      };
}
