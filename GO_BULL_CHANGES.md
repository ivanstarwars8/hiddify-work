# Go Bull — список внесённых изменений (27 Dec 2025)

Этот файл — “памятка”, что было изменено в проекте и где это искать.

## 1) Гейт доступа по подписке Go Bull

**Требование**: если валидная подписка Go Bull (remote subscription) не добавлена — доступа к приложению нет; при запуске показывается экран ввода ссылки подписки; доступ открывается только если ссылка валидна.

**Реализация**:
- Добавлен экран **Access Gate** (маршрут `/access`) с полем ввода URL и кнопками “Вставить из буфера” / “Проверить”.
- Доступ в приложение контролируется в роутере через `redirect`: пока подписки нет — принудительно редирект на `/access` и блокировка “назад”.
- Валидация URL основана на уже существующем ограничении домена подписок: `panel.go-bull.pro` (`lib/utils/link_parsers.dart`).
- Импорт подписки выполняется через существующий `addProfileProvider.notifier.add(url)` (тот же механизм, что “Add profile”).

**Файлы**:
- `lib/features/access/widget/access_gate_page.dart`
- `lib/features/access/notifier/access_gate_provider.dart`
- `lib/core/router/app_router.dart` (добавлен `GoRoute('/access')` + redirect-логика)

## 2) Ребрендинг: убрать Hiddify, заменить на Go Bull

**Основное**:
- `Constants.appName` теперь `"Go Bull"`.
- `Constants.telegramChannelUrl` → `https://t.me/go_bull`
- `Constants.githubUrl` и ссылки на releases/appcast → на репозиторий `ivanstarwars8/hiddify-work`.
- В UI, где ранее использовался `t.general.appTitle`, заменено на `Constants.appName` (чтобы не зависеть от генерации переводов).
- В `assets/translations/*.i18n.json` заменены упоминания `Hiddify` → `Go Bull`.
- В `lib/gen/translations.g.dart` вручную поправлены значения `general.appTitle` и часть `play.*` (в этом окружении генераторы не запускались).

**Файлы**:
- `lib/core/model/constants.dart`
- `assets/translations/strings_*.i18n.json`
- `lib/gen/translations.g.dart`
- `lib/features/settings/about/about_page.dart`
- `lib/features/home/widget/home_page.dart`
- `android/app/src/main/kotlin/com/hiddify/hiddify/bg/ServiceNotification.kt` (строки уведомления сервиса)
- `android/app/src/main/AndroidManifest.xml` (`android:label="Go Bull"`)

## 3) Цветовая схема → красная

**Реализация**:
- В `AppTheme` seedColor изменён на красный `#B00020`.
- `DynamicColorBuilder` отключён, чтобы не переопределялся seed (всегда красная тема).
- Android adaptive icon/splash векторные ресурсы перекрашены в `#B00020`.

**Файлы**:
- `lib/core/theme/app_theme.dart`
- `lib/features/app/widget/app.dart`
- `android/app/src/main/res/drawable/ic_launcher_foreground.xml`
- `android/app/src/main/res/drawable/ic_banner_foreground.xml`
- `android/app/src/main/res/drawable/android12splash.xml`
- `assets/images/logo.svg` (перекрашен в красный; это НЕ новый логотип, а перекрас старого svg)

## 4) Сборка APK (release) + подпись

**Сделано**:
- Создан локальный release keystore и `android/key.properties`, чтобы release APK был подписан и ставился на устройства.
  - Keystore: `android/keystore/go-bull-release.jks`
  - Properties: `android/key.properties`

**Важно**: это “локальная” подпись для сборки в этом окружении. Для публикации в Play нужен ваш стабильный production keystore.

**Команда сборки**:
```bash
/opt/flutter-3.24.3/flutter/bin/flutter pub get
/opt/flutter-3.24.3/flutter/bin/flutter build apk --release
```

**Готовый APK**:
- `/root/work/go-bull-app-release.apk`
- SHA256: `/root/work/go-bull-app-release.apk.sha256`

Также собраны ABI-апк:
- `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk`
- `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk`
- `build/app/outputs/flutter-apk/app-x86_64-release.apk`

## 5) Что НЕ доделано (логотипы “как на картинке”)

Требование “замени ещё логотипы все от хидифи на это фото” пока выполнено **частично**:
- Перекрашен текущий `assets/images/logo.svg` и векторные android-иконки (это не замена на ваш bull-логотип).
- Android launcher webp (`mipmap-*/ic_launcher*.webp`) и `ic_stat_logo.png` **не заменены** на вашу картинку.

Чтобы завершить замену, нужен файл картинки в проекте или прямая ссылка на скачивание (png/jpg). После этого можно:
- Сгенерировать `mipmap-*` и `ic_launcher_foreground` (или заменить на bitmap),
- Заменить `ic_stat_logo.png`,
- Обновить `assets/images/logo.svg` на картинку или новый svg.


