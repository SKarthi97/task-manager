# Task Manager — Learning Notes

Notes kept while building this project, in two parts:

1. [**Commands I ran**](#commands-i-ran) — the chronological log: each command, its relevant
   output, and anything that needed following up.
2. [**Concepts I learned**](#concepts-i-learned) — the Flutter and Dart ideas behind the code.

Source files carry only brief comments and point back to the concepts section, so the explanations
live in one place.

## Environment

- **Date:** 2026-08-06
- **Host:** `LKCOL-WN-ENG-KarthickS` — WSL2, Ubuntu 24.04.1 LTS (kernel 5.15.167.4-microsoft-standard-WSL2)
- **Repository path:** `/mnt/d/Projects/task-manager` (`d:\Projects\task-manager` on Windows)
- **Flutter:** 3.44.8 (stable channel)
- **Dart SDK constraint:** `^3.12.2`
- **Locale:** `C.UTF-8`

---

# Commands I ran

## 1 — Verify the toolchain

```bash
flutter doctor
```

| Check | Status | Notes |
| --- | --- | --- |
| Flutter (stable 3.44.8) | ✓ | Ubuntu 24.04.1 LTS on WSL2 |
| Android toolchain | ✗ | **Android SDK not found** |
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

## 2 — Create the Flutter project

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
[`task_manager/lib/main.dart`](../task_manager/lib/main.dart), which at this point was still the
default counter demo.

## 3 — Run the app

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

**Hot reload key commands**

| Key | Action |
| --- | --- |
| `r` | Hot reload |
| `R` | Hot restart |
| `h` | List all available interactive commands |
| `d` | Detach (leave the app running, terminate `flutter run`) |
| `c` | Clear the screen |
| `q` | Quit (terminate the app on the device) |

**Debug endpoints** (port and auth token change on every run)

- Dart VM Service: `http://127.0.0.1:45187/ZJ8F9sxP90c=`
- DevTools: `http://127.0.0.1:45187/ZJ8F9sxP90c=/devtools/?uri=ws://127.0.0.1:45187/ZJ8F9sxP90c=/ws`

## 4 — Add repository ignore rules

A repository-root [`.gitignore`](../.gitignore) was added on top of the Flutter-generated
[`task_manager/.gitignore`](../task_manager/.gitignore). It covers build output, IDE files, and
machine-specific or sensitive files:

- `**/android/local.properties` (contains the local `flutter.sdk` path) — also already excluded by
  the generated [`task_manager/android/.gitignore`](../task_manager/android/.gitignore); the
  root rule makes the intent explicit for any future Android module
- Signing material: `key.properties`, `*.jks`, `*.keystore`
- Generated Xcode configs and per-platform `ephemeral/` directories
- `.env` files (with `.env.example` kept)

## 5 — Replace the counter demo with the app shell

[`lib/main.dart`](../task_manager/lib/main.dart) was rewritten: the generated counter demo
(97 lines) became a 15-line app shell.

| Before (`flutter create`) | After |
| --- | --- |
| `MyApp` | `TaskManagerApp` |
| `MyHomePage` — a `StatefulWidget` | `HomeScreen` — a `StatelessWidget` |
| `title: 'Flutter Demo'` | `title: 'Task Manager'` |
| Seed colour `Colors.deepPurple` | Seed colour `Colors.orangeAccent` |
| Debug banner shown (default) | `debugShowCheckedModeBanner: false` |
| Counter `Column` + `FloatingActionButton` | A single centred `Text` |
| `_counter` field, `_incrementCounter()`, `setState` | No state |

## 6 — Rewrite the widget test

Renaming `MyApp` broke [`test/widget_test.dart`](../task_manager/test/widget_test.dart): the
generated test imported `MyApp` and asserted on the counter, so the suite no longer compiled. It was
replaced with five tests covering the app shell.

```bash
cd task_manager/
flutter test
```

| Test | Asserts |
| --- | --- |
| renders the app bar title | `find.text('Task Manager')` matches exactly one widget |
| renders the centred welcome message | the welcome `Text` exists **and** is a descendant of `Center` |
| builds the expected Material scaffolding | `MaterialApp`, `HomeScreen`, `Scaffold`, `AppBar` present; `FloatingActionButton` absent |
| applies the orange seed colour scheme | the theme's `colorScheme.primary` equals one derived from the same seed |
| hides the debug banner | `debugShowCheckedModeBanner == false`, `title == 'Task Manager'` |

## 7 — Branch, commit, merge

```bash
git checkout -b feature/project-setup develop
git add -A
git commit                      # .gitignore + these notes + the scaffold
# → merged into develop via pull request #1

git checkout -b feature/first-experiment develop
git cherry-pick <sha>           # moved the app-shell commit onto the new branch
git push -u origin feature/first-experiment
```

> **Note:** `git cherry-pick` was needed because the app-shell commit was made on
> `feature/project-setup` *after* that branch's pull request had already been merged, so it was not
> part of `develop` and not inherited by the new branch.

## 8 — Move `HomeScreen` into its own file

`HomeScreen` was extracted from `main.dart` into
[`lib/screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart), so `main.dart` holds
only the entry point and app-wide configuration. `main.dart` now imports the screen:

```dart
import 'package:task_manager/screens/home_screen.dart';
```

## 9 — Run the analyzer

```bash
flutter analyze
```

The first run failed, because moving `HomeScreen` broke the test:

```text
error • Undefined name 'HomeScreen'. Try correcting the name to one that is defined, or
        defining the name • test/widget_test.dart:46:26 • undefined_identifier

1 issue found. (ran in 10.7s)
```

The fix was to import the screen in the test as well — see
[imports are not transitive](#imports-are-not-transitive). After that:

```bash
flutter analyze     # No issues found!
flutter test        # 5 tests passed
```

> **Note:** Flutter lives in WSL (`/home/karthick/flutter/bin`), so these run from the Ubuntu
> distro. The default WSL distro is `docker-desktop`, which has no shell of its own — hence
> `wsl -d Ubuntu` when invoking from Windows.

---

# Concepts I learned

## Everything is a widget

The UI is a *tree* of widgets, each describing a small piece of the screen. `runApp` takes the root
widget and mounts it. The current tree:

```text
TaskManagerApp
└── MaterialApp          app-wide plumbing: navigation, theme, localisation
    └── HomeScreen
        └── Scaffold     the standard Material screen layout
            ├── AppBar   → Text('Task Manager')
            └── Center   → Text('Welcome to Flutter!')
```

`MaterialApp` is the conventional root of a Material app; `Scaffold` provides the named slots a
screen needs (`appBar`, `body`, `floatingActionButton`, `drawer`, `bottomNavigationBar`) and keeps
content clear of the keyboard and system bars.

## Stateless vs stateful

A `StatelessWidget` is a pure description of UI — same inputs, same output, nothing to mutate. A
`StatefulWidget` owns a companion `State` object holding mutable fields, and calls `setState()` to
tell Flutter to re-run `build`.

The generated demo needed `StatefulWidget` for its `_counter`. The current screen renders fixed
content, so both widgets are stateless. `HomeScreen` becomes stateful — or delegates to a
state-management package — once tasks can be added and completed.

## `build` and `BuildContext`

`build` describes a widget in terms of other widgets. Flutter may call it many times per second, so
it must be fast and free of side effects.

`BuildContext` is the widget's handle on its own position in the tree. That is what lets
`Theme.of(context)` and `Navigator.of(context)` walk *upwards* to find ancestor widgets.

## `const` constructors and `key`

A `const` widget can be reused across rebuilds instead of reallocated — a cheap, real performance
win, and why `flutter_lints` nudges toward it.

`super.key` forwards the optional `key`, which is how Flutter tells sibling widgets apart when a
list is reordered, so the right state stays with the right item.

## Theming from one seed colour

`ColorScheme.fromSeed(seedColor: Colors.orangeAccent)` generates a full, accessible Material 3
palette — primary, secondary, surface, error, plus the matching `on*` colours for content drawn on
top of each.

`AppBar` never mentions orange; it reads the scheme from the theme. Changing the seed re-tints the
whole app coherently.

## Layout by composition

Flutter has no layout attributes on individual widgets. Instead you *wrap*: `Center` takes one
`child` and positions it in the middle of the available space, and `Padding`, `Column`, `Row` and
friends each do one job. Nesting them produces the layout.

> Inline `style: TextStyle(fontSize: 24)` works, but reading from `Theme.of(context).textTheme` is
> the better habit — it keeps typography consistent and respects the user's platform text-scaling
> setting.

## The three test tiers

| Tier | Scope | Speed |
| --- | --- | --- |
| Unit test | plain Dart, no widgets | fastest |
| Widget test | one widget tree, headless — no device needed | fast |
| Integration test | the whole app on a real device or browser | slow |

## `testWidgets` and pumping

Widget tests use `testWidgets`, not `test`, and receive a `WidgetTester`.
`await tester.pumpWidget(...)` mounts the tree and renders **one frame** — tests drive the frame
loop by hand rather than waiting on a real clock. Once the app has animations or async loading,
`tester.pump()` and `tester.pumpAndSettle()` advance it further.

## Finders and matchers

A *finder* locates widgets; a *matcher* states the expectation.

| Finder | Locates by |
| --- | --- |
| `find.text('...')` | displayed string |
| `find.byType(Center)` | widget class |
| `find.byIcon(Icons.add)` | icon |
| `find.descendant(of:, matching:)` | position in the tree |

Matchers: `findsOneWidget`, `findsNothing`, `findsNWidgets(n)`. Asserting `findsNothing` on the
removed `FloatingActionButton` is what stops it silently reappearing.

## Reading widgets and context back out

- `tester.widget<T>(finder)` returns the actual widget instance, so its properties can be inspected.
- `tester.element(finder)` returns its `BuildContext` — which is what `Theme.of(context)` needs.
  Same lookup as in `main.dart`, performed from a test.

## Testing a generated palette

`ColorScheme.fromSeed` *derives* a palette, so `colorScheme.primary` is **not** literally
`Colors.orangeAccent`. The test therefore compares against a scheme built from the same seed. That
proves the seed took effect without hard-coding a colour value Material could legitimately retune.

## Package-relative imports

Test files import the app as `package:task_manager/main.dart`, using the `name:` from
`pubspec.yaml`, rather than a relative path like `../lib/main.dart`.

## Imports are not transitive

Importing a file does **not** give you access to what *that* file imported. Each file must import
every name it uses, directly.

This is what broke the test when `HomeScreen` moved out of `main.dart`. The test imported
`main.dart`, and `main.dart` uses `HomeScreen` — but it *imports* the name rather than declaring it,
so `HomeScreen` was never visible to the test:

```text
widget_test.dart ──imports──▶ main.dart ──imports──▶ home_screen.dart
                 ✗ HomeScreen not visible here ────────────┘
```

The fix is one line in the test:

```dart
import 'package:task_manager/screens/home_screen.dart';
```

(Dart *can* forward names, with `export 'screens/home_screen.dart';` in a barrel file. That is worth
doing once there are many screens, but an explicit import per file is clearer while there are few.)

## One widget per file

Splitting `HomeScreen` out leaves `main.dart` holding only the entry point and app-wide
configuration, which is the conventional Flutter layout:

```text
lib/
├── main.dart              entry point + MaterialApp configuration
└── screens/
    └── home_screen.dart   one screen per file
```

Files under `lib/` are private to the package unless placed in `lib/src/`; the `screens/`,
`widgets/`, `models/` split is convention rather than something the tooling enforces.

---

# Current state

- The app shell runs: an orange-themed `Scaffold` with an `AppBar` and a centred welcome message.
- No task-manager functionality yet — there is no task model, no list, no persistence.
- `pubspec.yaml` carries the placeholder description `"A new Flutter project."` and no
  dependencies beyond `cupertino_icons` and `flutter_lints`.
- The Android application ID is still the placeholder `com.example.task_manager`.

# Next steps

1. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
2. Update `pubspec.yaml` (description, and dependencies for state management + persistence).
3. Replace the Android placeholder application ID.
4. Build the task-manager feature itself: a `Task` model, a state layer, and list/add/edit UI,
   extending the widget tests as each piece lands.
