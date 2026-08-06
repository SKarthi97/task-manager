# Task Manager — Setup Steps

A running log of the setup steps performed for this project, with the exact commands,
their relevant output, and notes on anything that needs follow-up.

- **Date:** 2026-08-06
- **Host:** `LKCOL-WN-ENG-KarthickS` — WSL2, Ubuntu 24.04.1 LTS (kernel 5.15.167.4-microsoft-standard-WSL2)
- **Repository path:** `/mnt/d/Projects/task-manager` (`d:\Projects\task-manager` on Windows)
- **Flutter:** 3.44.8 (stable channel)
- **Dart SDK constraint:** `^3.12.2`
- **Locale:** `C.UTF-8`

---

## Step 1 — Verify the toolchain

```bash
flutter doctor
```

Summary of the result:

| Check | Status | Notes |
| --- | --- | --- |
| Flutter (stable 3.44.8) | ✓ | Ubuntu 24.04.1 LTS on WSL2 |
| Android toolchain | ✗ | **Android SDK not found** — see follow-up below |
| Chrome — web | ✓ | Google Chrome 151.0.7922.75 |
| Linux toolchain — desktop | ✓ | Warning: `eglinfo` unavailable (`apt install mesa-utils`) |
| Connected devices | ✓ | 2 available (Linux desktop, Chrome) |
| Network resources | ✓ | |

The Android failure reported:

```text
[✗] Android toolchain - develop for Android devices
    ✗ Unable to locate Android SDK.
      Install Android Studio from: https://developer.android.com/studio/index.html
      On first launch it will assist you in installing the Android SDK components.
      (or visit https://flutter.dev/to/linux-android-setup for detailed instructions).
      If the Android SDK has been installed to a custom location, please use
      `flutter config --android-sdk` to update to that location.
```

> **Follow-up:** Android builds are blocked until the SDK is installed and registered with
> `flutter config --android-sdk <path>`. Only Chrome (web) and Linux desktop can be targeted today.

---

## Step 2 — Create the Flutter project

```bash
flutter create task_manager
```

```text
Creating project task_manager...
Resolving dependencies in `task_manager`...
Downloading packages...
Got dependencies in `task_manager`.
Wrote 131 files.

All done!
```

This produced the standard scaffold under [`task_manager/`](../task_manager/), including all six
platform targets (`android`, `ios`, `linux`, `macos`, `web`, `windows`). Application code lives in
[`task_manager/lib/main.dart`](../task_manager/lib/main.dart), which at this point is still the
default counter demo.

---

## Step 3 — Run the app

```bash
cd task_manager/
flutter run
```

Flutter prompted for a target device and `2` (Chrome) was selected:

```text
Connected devices:
Linux (desktop) • linux  • linux-x64      • Ubuntu 24.04.1 LTS 5.15.167.4-microsoft-standard-WSL2
Chrome (web)    • chrome • web-javascript • Google Chrome 151.0.7922.75
[1]: Linux (linux)
[2]: Chrome (chrome)
Please choose one (or "q" to quit): 2
```

The app launched in debug mode:

```text
Launching lib/main.dart on Chrome in debug mode...
Waiting for connection from debug service on Chrome...             37.7s
This app is linked to the debug service: ws://127.0.0.1:45187/ZJ8F9sxP90c=/ws
Starting application from main method in: org-dartlang-app:/web_entrypoint.dart.
WARNING: Falling back to CPU-only rendering. Reason: webGLVersion is -1
```

> **Note:** The CPU-only rendering warning is expected under WSL2 without GPU passthrough. It affects
> rendering performance in the browser only, not correctness of the build.

### Hot reload key commands

| Key | Action |
| --- | --- |
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | List all available interactive commands |
| `d` | Detach (leave the app running, terminate `flutter run`) |
| `c` | Clear the screen |
| `q` | Quit (terminate the app on the device) |

### Debug endpoints for this session

- Dart VM Service: `http://127.0.0.1:45187/ZJ8F9sxP90c=`
- DevTools: `http://127.0.0.1:45187/ZJ8F9sxP90c=/devtools/?uri=ws://127.0.0.1:45187/ZJ8F9sxP90c=/ws`

(Port and auth token are per-session and change on every run.)

---

## Step 4 — Add repository ignore rules

A repository-root [`.gitignore`](../.gitignore) was added on top of the Flutter-generated
[`task_manager/.gitignore`](../task_manager/.gitignore). It covers build output, IDE files, and —
importantly — machine-specific files the Flutter template does not exclude:

- `**/android/local.properties` (contains the local `flutter.sdk` path)
- Signing material: `key.properties`, `*.jks`, `*.keystore`
- Generated Xcode configs and per-platform `ephemeral/` directories
- `.env` files (with `.env.example` kept)

---

## Current state

- The scaffold builds and runs, but no task-manager functionality exists yet —
  `lib/main.dart` is still the generated counter demo.
- `pubspec.yaml` carries the placeholder description `"A new Flutter project."` and no
  dependencies beyond `cupertino_icons` and `flutter_lints`.
- The Android application ID is still the placeholder `com.example.task_manager`.

## Next steps

1. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
2. Update `pubspec.yaml` (description, and dependencies for state management + persistence).
3. Replace the Android placeholder application ID.
4. Replace the counter demo with the task-manager data model, state layer, and UI,
   and update `test/widget_test.dart` accordingly.
