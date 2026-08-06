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

## 10 — Turn the screen into a task-list empty state

The welcome text became an empty-state message, and a disabled "+" button was added:

| Before | After |
| --- | --- |
| `Text('Welcome to Flutter!')` | `Text('No tasks yet')` |
| no button | `FloatingActionButton` with `onPressed: null` |

`flutter analyze` stayed clean, but **two tests failed** — they still expected the old text and no
button:

```text
00:03 +3 -2: Some tests failed.

Failing tests:
  TaskManagerApp renders the centred welcome message
  TaskManagerApp builds the expected Material scaffolding
```

This is the tests doing their job: the UI changed, so the tests had to be updated to match.

| Test | Change |
| --- | --- |
| renders the centred welcome message | renamed to *empty-state message*, now looks for `'No tasks yet'` |
| builds the expected Material scaffolding | now expects the button to be **present**, not absent |
| *(new)* the add button is still disabled | checks `onPressed` is `null` |

```bash
flutter analyze     # No issues found!
flutter test        # 6 tests passed
```

---

# Concepts I learned

## Words to know

| Term | In plain words |
| --- | --- |
| Widget | One piece of the screen. Everything you see is a widget. |
| Widget tree | Widgets nested inside widgets, making up the whole screen. |
| `StatelessWidget` | Shows something, but does not manage changing data. |
| `StatefulWidget` | Can hold data that changes, and redraws when it does. |
| `build` | The method that says what to show. |
| `BuildContext` | A widget's "you are here" marker in the tree. |
| `const` | This never changes, so Flutter can reuse it. |
| `Scaffold` | The standard screen frame, with slots to fill. |
| Theme | The app's colours and fonts, set in one place. |
| Widget test | A test that builds the screen in memory and checks what it shows. |

## Everything is a widget

A widget is one piece of the screen. Widgets go inside other widgets, and that nesting is the
**widget tree**. `runApp` takes the outermost widget and puts it on screen.

The current tree, top to bottom:

```text
TaskManagerApp                    the app itself
└── MaterialApp                   provides theming and screen switching
    └── HomeScreen                the screen shown on open
        └── Scaffold              the screen frame
            ├── AppBar            → Text('Task Manager')
            ├── Center            → Text('No tasks yet')
            └── FloatingActionButton → Icon(Icons.add)
```

`Scaffold` is the standard screen frame. You do not position its parts — you drop them into named
slots (`appBar`, `body`, `floatingActionButton`, `drawer`, `bottomNavigationBar`) and it handles the
layout, including keeping content clear of the keyboard and system bars.

## Stateless vs stateful

**Stateless** = shows something, but does not manage changing data. Give it the same inputs and it
draws the same thing every time.

**Stateful** = holds data that can change. When that data changes you call `setState()`, and Flutter
redraws the widget.

Right now nothing on screen changes, so every widget here is stateless. `HomeScreen` becomes
stateful once tasks can actually be added — the list of tasks is data that changes.

## `build` and `BuildContext`

`build` is the method that says what to show. Flutter calls it whenever the widget needs drawing,
which can be many times a second — so keep it quick, and never do real work in it (no saving files,
no network calls).

`BuildContext` is the widget's "you are here" marker in the tree. Because a widget knows where it
sits, it can look *upwards* to find things its parents provide:

```dart
Theme.of(context)      // finds the theme set by MaterialApp above
Navigator.of(context)  // finds the navigator, to move between screens
```

## `const` means "this never changes"

Marking a widget `const` tells Flutter the widget can be built once and reused, instead of being
rebuilt every time the screen redraws. It is free performance, which is why `flutter_lints` keeps
suggesting it.

`super.key` passes along an optional `key`. A key is a name tag: when a list gets reordered, keys let
Flutter keep each widget's data with the right item. It matters for lists, not for a fixed screen.

## One colour becomes a whole palette

```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent)
```

From that one colour, Flutter works out a full matching set — the main colour, background colours,
error colours, and the right text colour to put on top of each one so it stays readable.

Notice that `AppBar` never mentions orange. It reads the colour from the theme. So changing the seed
colour re-tints the entire app at once.

## Layout by wrapping

In Flutter you do not set position or alignment on a widget. You **wrap** it in another widget whose
whole job is that one thing:

| To do this | Wrap in |
| --- | --- |
| put it in the middle | `Center` |
| add space around it | `Padding` |
| stack things vertically | `Column` |
| stack things side by side | `Row` |

Nesting these small widgets is how a layout gets built.

> `style: TextStyle(fontSize: 24)` works fine, but taking the size from
> `Theme.of(context).textTheme` is the better habit — text stays consistent across screens, and it
> respects the larger-text setting for users who need it.

## A disabled button is `onPressed: null`

Flutter has no `enabled: false`. You disable a button by giving it nothing to do:

```dart
FloatingActionButton(
  onPressed: null,        // disabled: greyed out, taps do nothing
  child: Icon(Icons.add),
)
```

Give `onPressed` a function and the button becomes active automatically.

## The three test tiers

| Tier | Scope | Speed |
| --- | --- | --- |
| Unit test | plain Dart, no widgets | fastest |
| Widget test | one widget tree, headless — no device needed | fast |
| Integration test | the whole app on a real device or browser | slow |

## `testWidgets` and "pumping"

Widget tests use `testWidgets`, not `test`, and get a `WidgetTester` to work with.

`await tester.pumpWidget(...)` builds the screen and draws **one frame**. Tests draw frames by hand
rather than waiting on a real clock, which is why they finish in milliseconds. Later, when the app
has animations or loading, `tester.pump()` draws the next frame and `tester.pumpAndSettle()` keeps
drawing until nothing is moving.

## Finders and matchers

A test asks two things: *which widget?* (a **finder**) and *how many did you expect?* (a **matcher**).

| Finder | Looks for |
| --- | --- |
| `find.text('No tasks yet')` | text shown on screen |
| `find.byType(Center)` | a kind of widget |
| `find.byIcon(Icons.add)` | an icon |
| `find.descendant(of:, matching:)` | a widget *inside* another widget |

| Matcher | Means |
| --- | --- |
| `findsOneWidget` | exactly one, and it must be there |
| `findsNothing` | must not be there at all |
| `findsNWidgets(3)` | exactly three |

## Looking inside a widget from a test

Sometimes checking what is on screen is not enough — you need a widget's actual settings:

```dart
final fab = tester.widget(find.byType(FloatingActionButton));
expect(fab.onPressed, isNull);          // is the button disabled?
```

- `tester.widget(finder)` hands back the real widget, so you can read its properties.
- `tester.element(finder)` hands back its `BuildContext`, which is what `Theme.of(context)` needs.
  It is the same upward lookup the app does, performed from a test.

## Testing a generated palette

Because `fromSeed` *works out* the palette, `colorScheme.primary` is **not** literally
`Colors.orangeAccent` — so comparing against orange would fail.

The test compares against a scheme built from the same seed instead. That proves the seed was
applied, without hard-coding a colour value that Flutter is free to adjust in a future version.

## Failing tests are the tests working

When the screen text changed and a button was added, two tests failed. Nothing was broken by the
failure — the tests were describing the old screen, and they said so loudly.

The habit to build: after changing the UI, run `flutter test` and update whatever fails to describe
the *new* intended behaviour. A test that needs no updating when behaviour changes was not checking
anything useful.

## Package-relative imports

Test files reach the app as `package:task_manager/main.dart` — `task_manager` being the `name:` in
`pubspec.yaml` — rather than a relative path like `../lib/main.dart`.

## Imports are not passed along

Importing a file does **not** give you what *that* file imported. Every file has to import each name
it uses, itself.

This is exactly what broke the test when `HomeScreen` moved out of `main.dart`. The test imported
`main.dart`, and `main.dart` uses `HomeScreen` — but it *imports* that name rather than defining it,
so the test still could not see it:

```text
widget_test.dart ──imports──▶ main.dart ──imports──▶ home_screen.dart
                 ✗ HomeScreen not visible here ────────────┘
```

The fix is one line in the test:

```dart
import 'package:task_manager/screens/home_screen.dart';
```

The error message names the *symbol* (`Undefined name 'HomeScreen'`), never the missing import — so
the fix is always "which file defines this, and have I imported it?"

(Dart can forward names along, using `export 'screens/home_screen.dart';` in a single "barrel" file.
Worth doing once there are many screens; one plain import per file is clearer while there are few.)

## One widget per file

Moving `HomeScreen` out leaves `main.dart` with just the starting point and the app-wide settings.
That is the usual Flutter layout:

```text
lib/
├── main.dart              starts the app, sets the theme
└── screens/
    └── home_screen.dart   one screen per file
```

The `screens/`, `widgets/`, `models/` split is a convention people follow, not a rule the tools
enforce — but following it means anyone can guess where a file lives.

---

# Current state

- The screen shows an orange app bar, an empty-state message (`No tasks yet`), and a disabled "+"
  button waiting to be wired up.
- No task-manager functionality yet — there is no task model, no list, no saving.
- `pubspec.yaml` carries the placeholder description `"A new Flutter project."` and no
  dependencies beyond `cupertino_icons` and `flutter_lints`.
- The Android application ID is still the placeholder `com.example.task_manager`.

# Next steps

1. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
2. Update `pubspec.yaml` (description, and dependencies for state management + persistence).
3. Replace the Android placeholder application ID.
4. Build the task-manager feature itself: a `Task` model, a state layer, and list/add/edit UI,
   extending the widget tests as each piece lands.
