import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/core/utils/preferences_utils.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

bool _testExperimentalNotice = false;

final disableExperimentalFeatureNoticeProvider =
    PreferencesNotifier.createAutoDispose(
  "disable_experimental_feature_notice",
  false,
  overrideValue: _testExperimentalNotice && kDebugMode ? false : null,
);

class ExperimentalFeatureNoticeDialog extends HookConsumerWidget {
  const ExperimentalFeatureNoticeDialog({super.key});

  Future<bool?> show(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => this,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final disableNotice = ref.watch(disableExperimentalFeatureNoticeProvider);

    return AlertDialog(
      title: Text(t.connection.experimentalNotice),
      content: SingleChildScrollView(
        child: SizedBox(
          width: 468,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t.connection.experimentalNoticeMsg),
              const Gap(8),
              CheckboxListTile(
                value: disableNotice,
                title: Text(t.connection.disableExperimentalNotice),
                secondary: const Icon(Icons.visibility_off_rounded),
                onChanged: (value) async => ref
                    .read(disableExperimentalFeatureNoticeProvider.notifier)
                    .update(value ?? false),
                dense: true,
              ),
              ListTile(
                title: Text(t.config.pageTitle),
                leading: const Icon(Icons.tune_rounded),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () async {
                  await Navigator.of(context).maybePop(false);
                  if (context.mounted) {
                    const ConfigOptionsRoute().push(context);
                  }
                },
                dense: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(false),
          child: Text(
            MaterialLocalizations.of(context).cancelButtonLabel.toUpperCase(),
          ),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).maybePop(true),
          child: Text(t.connection.connectAnyWay.toUpperCase()),
        ),
      ],
    );
  }
}
