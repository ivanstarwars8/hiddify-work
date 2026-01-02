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
import 'package:flutter_svg/flutter_svg.dart';
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

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Stack(
          children: [
            // Фон градиент + шум
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF2B0F0F),
                    Color(0xFF1A0A0A),
                    Color(0xFF0D0505),
                  ],
                ),
              ),
            ),
            IgnorePointer(
              child: SvgPicture.asset(
                'assets/images/noise_overlay.svg',
                fit: BoxFit.cover,
                colorFilter: ColorFilter.mode(
                  Colors.white.withOpacity(0.08),
                  BlendMode.srcIn,
                ),
              ),
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 520),
                    child: Card(
                      color: cs.surface.withOpacity(0.92),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                        side: BorderSide(color: cs.primary.withOpacity(0.35)),
                      ),
                      elevation: 8,
                      shadowColor: cs.primary.withOpacity(0.25),
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Assets.images.logo.svg(width: 52, height: 52),
                                const Gap(12),
                                Text(
                                  "Go Bull — доступ по подписке",
                                  style: theme.textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            const Gap(10),
                            Text(
                              "Вставьте ссылку подписки Go Bull, чтобы войти. Экран появится только один раз — после успешного входа больше не покажется (даже если удалить подписку).",
                              style: theme.textTheme.bodyMedium,
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
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.paste_rounded),
                                    onPressed: addState.isLoading
                                        ? null
                                        : () async {
                                            final data = await Clipboard.getData(
                                              Clipboard.kTextPlain,
                                            );
                                            final text = (data?.text ?? '').trim();
                                            controller.text = text;
                                            focusNode.requestFocus();
                                          },
                                    label: Text(t.profile.add.fromClipboard),
                                  ),
                                ),
                                const Gap(12),
                                Expanded(
                                  child: FilledButton.icon(
                                    icon: addState.isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Icon(Icons.verified_rounded),
                                    onPressed: addState.isLoading ? null : submit,
                                    label: const Text("Проверить"),
                                  ),
                                ),
                              ],
                            ),
                            const Gap(8),
                            TextButton.icon(
                              icon: const Icon(Icons.telegram),
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
                              label: const Text("TG группа: @go_bull"),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


