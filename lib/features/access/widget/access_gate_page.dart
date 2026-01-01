import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/core/model/constants.dart';
import 'package:hiddify/core/preferences/general_preferences.dart';
import 'package:hiddify/core/router/routes.dart';
import 'package:hiddify/features/access/notifier/access_gate_provider.dart';
import 'package:hiddify/features/profile/notifier/profile_notifier.dart';
import 'package:hiddify/utils/alerts.dart';
import 'package:hiddify/utils/link_parsers.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccessGatePage extends HookConsumerWidget {
  const AccessGatePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final hasAccess =
        ref.watch(hasValidGoBullSubscriptionProvider).valueOrNull ?? false;
    final addState = ref.watch(addProfileProvider);

    final controller = useTextEditingController();
    final focusNode = useFocusNode();

    useEffect(
      () {
        if (!hasAccess) return null;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!context.mounted) return;
          // Mark first-setup as completed so we never gate again.
          ref.read(Preferences.firstSetupCompleted.notifier).update(true);
          context.go(const HomeRoute().location);
        });
        return null;
      },
      [hasAccess],
    );

    Future<void> submit() async {
      final url = controller.text.trim();
      if (url.isEmpty) {
        CustomToast.error("Вставьте ссылку подписки.").show(context);
        return;
      }
      if (!isAllowedSubscriptionUrl(url)) {
        CustomToast.error("Нужна ссылка подписки Go Bull (panel.go-bull.pro).")
            .show(context);
        return;
      }
      await ref.read(addProfileProvider.notifier).add(url);
    }

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          "Первый запуск ${Constants.appName}",
                          style: Theme.of(context).textTheme.titleLarge,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(8),
                        Text(
                          "Добавьте подписку Go Bull. Без валидной подписки вход закрыт.\n\nВажно: экран показывается только один раз — после успешного входа он больше не появится, даже если вы потом удалите подписку.",
                          style: Theme.of(context).textTheme.bodyMedium,
                          textAlign: TextAlign.center,
                        ),
                        const Gap(16),
                        TextField(
                          controller: controller,
                          focusNode: focusNode,
                          autofillHints: const [AutofillHints.url],
                          keyboardType: TextInputType.url,
                          textInputAction: TextInputAction.done,
                          onSubmitted: (_) => submit(),
                          decoration: const InputDecoration(
                            labelText: "Ссылка подписки",
                            hintText: "https://panel.go-bull.pro/api/sub/...",
                            prefixIcon: Icon(Icons.link),
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const Gap(12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: addState.isLoading
                                    ? null
                                    : () async {
                                        final data = await Clipboard.getData(
                                          Clipboard.kTextPlain,
                                        );
                                        final text =
                                            (data?.text ?? '').trim();
                                        controller.text = text;
                                        focusNode.requestFocus();
                                      },
                                child: Text(t.profile.add.fromClipboard),
                              ),
                            ),
                            const Gap(12),
                            Expanded(
                              child: FilledButton(
                                onPressed: addState.isLoading ? null : submit,
                                child: addState.isLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Text("Проверить"),
                              ),
                            ),
                          ],
                        ),
                        const Gap(8),
                        TextButton(
                          onPressed: () async {
                            await Clipboard.setData(
                              const ClipboardData(
                                text: Constants.telegramChannelUrl,
                              ),
                            );
                            if (!context.mounted) return;
                            CustomToast.success("Ссылка на TG скопирована.")
                                .show(context);
                          },
                          child: const Text("TG группа: @go_bull"),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


