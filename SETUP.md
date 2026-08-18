# Momentum — setup

Steps 1–5 are **done**. This is the record of what was applied and what is left.

Verified on this machine:

```
Flutter 3.47.0 • Dart 3.13.0
flutter analyze  ->  No issues found!
flutter test     ->  16/16 passed
```

The Flutter SDK was installed at `~/flutter` (git checkout, stable channel). Add
it to your shell profile so `flutter` is on PATH in new terminals:

```bash
echo 'export PATH="$HOME/flutter/bin:$PATH"' >> ~/.zshrc
```

---

## 1. Platform scaffolding — done

```bash
flutter create --org com.momentum --project-name momentum --platforms=android,ios .
```

`android/` and `ios/` exist. `lib/` and `pubspec.yaml` were untouched;
`analysis_options.yaml` picked up the standard platform excludes.

The default `test/widget_test.dart` was deleted — it referenced a counter app
that does not exist here.

## 2. Dependencies and code generation — done

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

Generation produced `app_database.g.dart`, `daos/tasks_dao.g.dart` and
`daos/notifications_dao.g.dart`. Re-run it after touching any table or DAO.

**Two of the brief's pins had to move.** Both `flutter_timezone 2.x` and
`workmanager 0.5.2` are built against Flutter's **v1 embedding**
(`PluginRegistry.Registrar`), which no longer exists — they fail to compile, not
at analyze time but partway through the Android build:

| Package | Brief | Now | Why |
|---|---|---|---|
| `flutter_timezone` | `^2.0.0` | `^5.1.0` | v1 embedding removed |
| `workmanager` | `^0.5.2` | `^0.10.7` | v1 embedding removed |

Two small API renames came with them, already applied:
`NetworkType.not_required` → `notRequired`, and `getLocalTimezone()` now returns
a `TimezoneInfo` whose `.identifier` holds the IANA name.

Everything else resolved on the brief's original constraints.
`flutter_local_notifications` sits at 17.2.4, which still requires the
`uiLocalNotificationDateInterpretation` argument the code passes — delete that
line in `lib/services/notification_service.dart` if you ever move to 18+.

`flutter pub outdated` reports ~46 newer-but-incompatible packages. That is
expected with the remaining pins and nothing is broken by it.

## 3. Android — done

`android/app/src/main/AndroidManifest.xml` now carries the seven permissions
from the brief, the app label `Momentum`, and the two
`flutter_local_notifications` receivers. The boot receiver matters: without it
every pending reminder is lost when the phone restarts.

`android/app/build.gradle.kts` (Kotlin DSL — this Flutter version no longer
generates Groovy):

- `minSdk = 26`, per the brief and the floor for exact alarms.
- `isCoreLibraryDesugaringEnabled = true` plus
  `coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.4")`.
  `flutter_local_notifications` does not build without this.

`android/gradle.properties` also sets `kotlin.jvm.target.validation.mode=warning`.
`flutter_timezone` and `workmanager_android` still declare Kotlin `jvmTarget 1.8`
while AGP compiles their Java at 17, and Gradle treats that mismatch as a hard
error. 1.8 bytecode against a higher Java target is the safe direction and it is
all dexed anyway. Drop the line once those plugins modernise.

All the Android plugins declare a `namespace`, so none trip the AGP 8
requirement.

## 4. iOS — done

`ios/Runner/Info.plist` has `UIBackgroundModes` (`fetch`, `processing`) and
`NSUserNotificationUsageDescription`.

`ios/Runner/AppDelegate.swift` sets `UNUserNotificationCenter.current().delegate`
so a foreground tap reaches Dart.

Deployment target is already 15.0 — above the brief's iOS 14 floor, so it was
left alone. There is no `Podfile` yet; CocoaPods generates one on the first iOS
build.

## 5. Fonts — done

`assets/fonts/SpaceGrotesk.ttf` (137 KB) is the OFL variable font from
[github.com/google/fonts](https://github.com/google/fonts/tree/main/ofl/spacegrotesk),
licence alongside it in `OFL.txt`. One file carries the whole 300–700 weight
axis, so the w400/w500/w600 in `AppTypography` interpolate from it and
`pubspec.yaml` needs only a single asset entry.

Asset *bundling* is the one thing not yet exercised — `flutter build bundle`
needs the Android SDK. The path and the file are confirmed correct.

## 6. Running it locally

This app is not going to any store. There are no store assets and no obfuscated
build — but there *is* a signing config now, because updates delivered over
GitHub Releases have to be signed with a stable key (see
[Shipping updates](#7-shipping-updates-over-github-releases)).

Android is the target here — iOS would need full Xcode from the App Store.

```bash
flutter run
```

```bash
flutter test
```

To hand yourself an installable file:

```bash
flutter build apk --debug
```

`build/app/outputs/flutter-apk/app-debug.apk` can be dragged onto a running
emulator or side-loaded with `adb install`. It is signed with the standard debug
key, which is all a personal install needs.

### Toolchain

Installed by this setup, none of it requiring sudo:

| What | Where |
|---|---|
| Flutter 3.47.0 | `~/flutter` |
| JDK 17 (Temurin) | `~/jdks/jdk-17.0.20+8/Contents/Home` |
| JDK 17 (Homebrew) | `/opt/homebrew/opt/openjdk@17` |
| Android SDK | `~/Library/Android/sdk` |

Both JDKs work; Flutter is pointed at the Homebrew one. Gradle needs 17
specifically — a newer JDK will fail against this AGP version.

## Verifying auto-promotion

1. Create a task starting two minutes out — it lands in **Scheduled**.
2. Background the app. The start notification fires at its exact time.
3. Reopen: the resume pass promotes it to **In Progress**, the card pulses, a
   toast appears and a row lands on the Notifications tab.

On Android the workmanager job repeats that every 15 minutes with the app
closed. On iOS no periodic background work is registered — the OS-scheduled
notification still fires on time, and the status catches up on next open.

---

## 7. Shipping updates over GitHub Releases

Free, no Play Store. GitHub Actions builds a signed APK on every `v*` tag and
attaches it to a release; the app checks that release feed and offers the
download.

Android has no silent self-update outside the Play Store, so "auto update" here
means: the app notices, tells you, and hands the APK to Android's installer.
You still tap **Install**. That is the ceiling for a sideloaded app.

### One-time: the signing key

**Do this before the first release.** Android only lets an APK install over an
existing app when both were signed with the same key. The debug key is generated
per machine, so a CI-built APK signed with a debug key could never update the
copy on your phone.

Pick a password and keep it somewhere you will not lose — if the keystore or its
password goes missing, no future build can ever update an installed Momentum.
You would have to uninstall and lose the database.

```bash
keytool -genkey -v -keystore ~/momentum-release.jks -storetype JKS \
  -keyalg RSA -keysize 2048 -validity 10000 -alias momentum
```

Point local release builds at it (this file is gitignored):

```bash
cat > android/key.properties <<'PROPS'
storeFile=/Users/administrator/momentum-release.jks
storePassword=<the password you chose>
keyAlias=momentum
keyPassword=<the password you chose>
PROPS
```

Then give CI the same key, as four repository secrets — **Settings → Secrets and
variables → Actions**:

| Secret | Value |
|---|---|
| `KEYSTORE_BASE64` | `base64 -i ~/momentum-release.jks \| pbcopy` |
| `KEYSTORE_PASSWORD` | the password you chose |
| `KEY_ALIAS` | `momentum` |
| `KEY_PASSWORD` | the password you chose |

The workflow decodes the keystore into a temp file, builds, and deletes it.

### One-time: the first install

The copy on your phone right now is debug-signed, which is a different key.
Uninstall it once, then install the first release APK. Every update after that
installs straight over the top.

Uninstalling wipes the local database, so do it while you have nothing to lose.

### Cutting a release

```bash
git tag v1.0.1 && git push origin v1.0.1
```

The tag is the version — the workflow strips the `v`, passes it in as
`APP_VERSION`, and the app compares that against future releases. Nothing needs
editing in `pubspec.yaml`. Release notes are generated from the commits since
the previous tag.

The `versionCode` comes from the workflow's run number, so it always increases.

### How the app checks

`lib/services/update_service.dart`, called from two places:

- app start, throttled to once every 24 h
- **Settings → Check for updates**, unthrottled

It reads `GET /repos/<owner>/<repo>/releases/latest` unauthenticated (60 calls
per hour per IP — irrelevant at one a day), compares the tag, and shows the
update sheet only when the tag is genuinely newer and the release carries an
`.apk` asset. Any failure — offline, rate limited, malformed tag — is silent.

Both the repo name and the current version arrive via `--dart-define` from the
workflow. A local build has neither, so **updates are switched off in debug
builds** and the Settings row reads "Updates only work on release builds". That
is expected, not a bug.

### Two traps that only exist in release builds

Flutter turns on R8 and resource shrinking for `--release`, so a debug build
proves nothing about either of these. Both were found by installing v1.0.0 on an
emulator and reading logcat — the app showed a black screen and said nothing.

**1. Resources named only from Dart get deleted.** The shrinker scans Java and
XML. `ic_notification` and `ic_notification_large` are referenced only as strings
in `notification_service.dart`, so it removed them, and
`notifications.initialize()` threw `invalid_icon`. Because `main()` awaits that
before `runApp`, the result was a permanent black screen on launch.

Anything new that Dart names as a string has to be listed in
`android/app/src/main/res/raw/keep.xml`.

**2. R8 breaks flutter_local_notifications' Gson store.** Its pending-reminder
store is JSON via Gson, which needs generic signatures that R8 strips:

```
java.lang.RuntimeException: Missing type parameter.
```

This one is worse than a crash — `NotificationService` catches it, so the app
runs fine and simply never fires a reminder. `android/app/proguard-rules.pro`
keeps the signatures. Verify it survived a change with:

```bash
adb shell dumpsys alarm | grep -A1 com.momentum.momentum
```

A task scheduled an hour out should show an `RTC_WAKEUP` alarm ~59 minutes away.
No alarm means the store is broken again.

`main()` now also wraps notification setup in a try/catch, so no future plugin
failure can black-screen the app — it just starts without reminders.

**3. Android 11+ hides other apps unless you declare them.** The update sheet's
Download button did nothing on a real phone: package-visibility filtering meant
`url_launcher` could not see a single browser, so `launchUrl` returned false.
The `<queries>` block in the manifest needs an `android.intent.action.VIEW` +
`https` entry. Confirmed by A/B on one device — without it, tapping Download
fires zero VIEW intents; with it, Chrome opens the APK link.

Anything else the app hands off to another app (email, maps, dialler) needs its
own entry there too.
