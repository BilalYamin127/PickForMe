# PickForMe ✳

An offline Flutter decision maker. Add possibilities, spin an animated wheel or shuffle a list, and share the winner. Material 3, Riverpod, Hive CE, GoRouter and share_plus. No account, server, analytics or paid API.

## Run

Requires Flutter **3.47.9** / Dart **3.13.7** or compatible newer stable SDK, plus the target platform toolchain.

```sh
flutter pub get
flutter run
```

## MVVM structure

```text
lib/
  main.dart                         # Hive bootstrap and dependency injection
  app/
    app.dart                        # Reactive theme and application root
    router.dart                     # GoRouter routes and missing-state handling
    theme.dart                      # Light/dark Material 3 themes
  core/services/
    random_service.dart             # Secure selection and wheel geometry
  data/
    models/
      decision.dart                 # Immutable list, result and mode models
      app_settings.dart             # Immutable preferences
    repositories/
      local_repository.dart         # Hive CE JSON storage boundary
  features/
    home/views/home_view.dart
    decisions/
      view_models/
        app_view_model.dart         # Riverpod application state and persistence
        editor_view_model.dart      # Editing and validation
        picker_view_model.dart      # Winner selection and picker state
      views/
        editor_view.dart
        picker_view.dart            # AnimationController lifecycle
        result_view.dart
      widgets/decision_wheel.dart   # CustomPainter and fixed pointer
    library/views/library_view.dart # Saved lists and history
    settings/views/settings_view.dart
  shared/widgets/page_frame.dart
```

Views render state and own Flutter animation lifecycles. View models validate and coordinate operations. The repository owns serialization/storage; models have no UI dependencies. Riverpod injects the repository and observes immutable application snapshots. No code generation is required.

## Features

- Home with reusable starter ideas and recent results.
- Create/edit titles and choices; add, remove and drag to reorder. Blank choices are discarded; a title and two nonempty choices are required.
- Save, edit, duplicate, delete and launch lists. One-off decisions need not be saved.
- Equal wheel segments, fixed top pointer, eased six-plus-turn animation and truncated long labels.
- Animated list shuffle with the same unbiased selection logic.
- Result celebration, repeat selection and native text sharing (including iPad share anchor).
- Persisted history with local timestamps and selection mode, plus confirmed clearing.
- Persisted sound, supported-device haptics, and system/light/dark appearance.

`Random.secure().nextInt(count)` chooses the winner **before** animation begins. There is no repeat suppression. At zero rotation segment zero begins at twelve o'clock. Final rotation places the selected segment's center under the top pointer. Tests cover each winner at several counts and prior rotations. Sound uses platform system clicks; sound/haptic availability follows device support and OS settings.

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
flutter build web --release
```

Tests include wheel geometry, random bounds, editor validation/reordering, real Hive close/reopen persistence, and a widget flow from home through creating, saving, spinning and revealing a recorded result.

## Builds and distribution

```sh
flutter build apk --release
flutter build appbundle --release
# macOS with Xcode and an Apple signing team:
flutter build ipa --release
```

The checked-in Android configuration uses Flutter's debug signing key for a **preview APK**. Before Play Store distribution, configure a private release keystore/signing config (keep credentials out of Git), then build an AAB. Set the iOS signing team and provisioning in Xcode before producing a signed IPA. Application ID: `com.bilalyamin.pick_for_me`.

GitHub Actions runs formatting, analysis, tests and a web release build, and produces an Android preview APK artifact. iOS builds require macOS/Xcode and are not validated in the Linux development environment. Native apps work offline; the web target is for browser preview and requires its initial assets to load. No native Internet permission is requested by the release application.

Local storage is device-specific and removed when application data is cleared/uninstalled. History clearing is permanent. Browser reloads of temporary picker/result routes return safely to choosing a decision.
