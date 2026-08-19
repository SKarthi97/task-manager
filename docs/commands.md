# Commands I ran

The chronological log. Environment details are in [Steps.md](Steps.md).

---

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
[imports are not passed along](concepts/project-layout.md#imports-are-not-passed-along). After that:

```bash
flutter analyze     # No issues found!
flutter test        # 5 tests passed
```

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

This is the tests doing their job — see
[failing tests are the tests working](concepts/testing.md#failing-tests-are-the-tests-working).

| Test | Change |
| --- | --- |
| renders the centred welcome message | renamed to *empty-state message*, now looks for `'No tasks yet'` |
| builds the expected Material scaffolding | now expects the button to be **present**, not absent |
| *(new)* the add button is still disabled | checks `onPressed` is `null` |

```bash
flutter analyze     # No issues found!
flutter test        # 6 tests passed
```

## 11 — Add the `Task` model

[`lib/models/task.dart`](../task_manager/lib/models/task.dart) describes what a single task *is*:

```dart
Task({required this.title, this.description, this.isCompleted = false});
```

| Property | Type | Required? |
| --- | --- | --- |
| `title` | `String` | yes |
| `description` | `String?` — may be null | no |
| `isCompleted` | `bool` | no, defaults to `false` |

Nothing uses the model yet, so `flutter analyze` and the six tests stay green. It is the piece the
task list will be built on next.

## 12 — Stop the line-ending churn

Every `pub get` left seven generated files under `linux/`, `macos/` and `windows/` showing as
modified with **no content change at all**. Flutter writes them with LF endings; the Windows
checkout rewrote them with CRLF.

A repository-root [`.gitattributes`](../.gitattributes) fixes it:

```gitattributes
* text=auto eol=lf
```

```bash
git add --renormalize .     # re-store existing files under the new rule
git status                  # the phantom modifications are gone
```

## 13 — Split these notes into separate files

One growing file became an index plus one file per topic, so each stays short enough to read in one
sitting:

```text
docs/
├── Steps.md            index, environment, current state, next steps
├── commands.md         this file
└── concepts/
    ├── glossary.md
    ├── widgets.md
    ├── theming-layout.md
    ├── dart-basics.md
    ├── lists.md
    ├── testing.md
    └── project-layout.md
```

## 14 — Show the tasks in a list

Three pieces landed together:

| File | Change |
| --- | --- |
| [`models/task.dart`](../task_manager/lib/models/task.dart) | fields became `final`, constructor became `const` |
| [`widgets/task_tile.dart`](../task_manager/lib/widgets/task_tile.dart) | **new** — one row: a disabled `Checkbox` and the task title |
| [`screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart) | `static const` sample tasks, and `ListView.builder` in place of the empty-state text |

`flutter analyze` stayed clean, and one test failed — the empty-state message is gone:

```text
Expected: exactly one matching candidate
  Actual: _TextWidgetFinder:<Found 0 widgets with text "No tasks yet": []>
   Which: means none were found but one was expected
```

It was replaced by three tests covering the list, taking the suite from 6 to 8:

| Test | Asserts |
| --- | --- |
| renders one row per task | one `TaskTile` per sample task, inside one `ListView` |
| shows each task title | every title in `HomeScreen.tasks` appears on screen |
| every task starts unchecked and not tappable | each `Checkbox` has `value: false` and `onChanged: null` |

```bash
dart format lib test    # 2 files reformatted to 2-space indent
flutter analyze         # No issues found!
flutter test            # 8 tests passed
```

The tests read the sample list from `HomeScreen.tasks` rather than repeating the titles, so adding a
fourth sample task does not break them. New concepts are in
[concepts/lists.md](concepts/lists.md).

## 15 — Make the "+" button add a task

`HomeScreen` became a `StatefulWidget`, and the button got a function to run:

| Before | After |
| --- | --- |
| `class HomeScreen extends StatelessWidget` | `StatefulWidget` + `_HomeScreenState` |
| `static const List<Task> tasks` | a `final List<Task>` living in the `State` |
| `onPressed: null` | `onPressed: () { setState(() { tasks.add(...) }); }` |

This time `flutter analyze` failed, three times over — the tests were reading `HomeScreen.tasks`,
which no longer exists now the list is private to `_HomeScreenState`:

```text
error • The getter 'tasks' isn't defined for the type 'HomeScreen'
        • test/widget_test.dart:32:62 • undefined_getter
                                        (and lines 39 and 53)
```

The tests were rewritten to check the screen the way a user sees it, and two tap tests were added,
taking the suite from 8 to 10:

| Test | Change |
| --- | --- |
| renders one row per task | counts against a local `initialTitles` list, not `HomeScreen.tasks` |
| shows each task title | same |
| every task starts unchecked and not tappable | same |
| the add button is **still disabled** | became **is enabled** — `onPressed` is now `isNotNull` |
| *(new)* tapping add appends a task | tap, `pump`, expect 4 tiles and `Task 4` |
| *(new)* tapping add twice appends two tasks | expect 5 tiles and `Task 5` |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 10 tests passed
```

New concepts are in [concepts/state.md](concepts/state.md).

## 16 — Ask for the task title in a dialog

The "+" button stopped inventing titles (`Task 4`) and started asking for one:

| Before | After |
| --- | --- |
| `onPressed` added a task directly | `onPressed` calls `_showAddTaskDialog()` |
| — | a `TextEditingController`, disposed in `dispose()` |
| — | `showDialog` → `AlertDialog` with a `TextField` and Cancel / Add Task |
| — | empty or whitespace-only titles refused |

`flutter analyze` stayed clean; the two tap tests failed, because the button now opens a dialog
instead of adding a task:

```text
Expected: exactly 4 matching candidates
  Actual: _TypeWidgetFinder:<Found 3 widgets with type "TaskTile">
   Which: is not enough
```

They were replaced by six dialog tests, taking the suite from 10 to 14:

| Test | Asserts |
| --- | --- |
| tapping add opens the dialog | `AlertDialog`, `TextField` and hint appear; no task added yet |
| typing a title and confirming adds the task | dialog closes, a fourth tile appears with that title |
| the title is trimmed before it is used | `'   Buy milk   '` is stored as `'Buy milk'` |
| cancel closes the dialog without adding | list unchanged, typed text discarded |
| an empty title is refused and the dialog stays open | whitespace only → still open, nothing added |
| the field is empty again on reopening | the controller is cleared before showing |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 14 tests passed
```

New concepts are in [concepts/dialogs-and-input.md](concepts/dialogs-and-input.md).

## 17 — Let a task be ticked off

The checkbox became live. Three files changed together:

| File | Change |
| --- | --- |
| [`models/task.dart`](../task_manager/lib/models/task.dart) | `isCompleted` dropped `final`, so it can be flipped in place |
| [`widgets/task_tile.dart`](../task_manager/lib/widgets/task_tile.dart) | takes an `onToggle` callback; strikes the title through when complete |
| [`screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart) | passes `onToggle`, flipping `isCompleted` inside `setState` |

`flutter analyze` failed with five errors, all in `itemBuilder`:

```text
error • The named parameter 'onToggle' is required, but there's no corresponding argument
error • Function expressions can't be named
error • Too many positional arguments: 0 expected, but 1 found
error • Undefined name 'task'  (twice)
```

Two mistakes behind all five:

1. **A missing colon.** `onToggle() { ... }` is a *named function declaration*, which Dart does not
   allow in an argument list. It needed `onToggle: () { ... }` — with the colon it is a named
   argument whose value happens to be a function.
2. **`task` did not exist there.** Inside `itemBuilder` the task is `tasks[index]`, so a
   `final task = tasks[index];` line was needed before using it.

The suite went from 14 to 18:

| Test | Change |
| --- | --- |
| every task starts unchecked and **not tappable** | became **tappable** — `onChanged` is now `isNotNull` |
| *(new)* tapping a checkbox marks that task complete | the tapped box turns true, **the others stay false** |
| *(new)* tapping a checked box unchecks it again | the toggle goes both ways |
| *(new)* a completed task title is struck through | reads `decoration` off the `Text` widget |
| *(new)* a newly added task can be completed too | add via the dialog, then tick the last box |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 18 tests passed
```

New concepts are in [concepts/callbacks.md](concepts/callbacks.md).

## 18 — Let a task be deleted

A delete button went into the tile's `trailing` slot — the slot noted as unused back in
[concepts/lists.md](concepts/lists.md):

| File | Change |
| --- | --- |
| [`widgets/task_tile.dart`](../task_manager/lib/widgets/task_tile.dart) | a second callback, `onDelete`, on an `IconButton` with a tooltip |
| [`screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart) | passes `onDelete`, calling `tasks.remove(task)` inside `setState` |

This time `flutter analyze` was clean and all 18 existing tests passed on the first run — the
feature worked, but **nothing tested it**. Six tests were added, taking the suite to 24:

| Test | Asserts |
| --- | --- |
| every row has a delete button | one delete icon per task |
| tapping delete removes that task | one fewer tile, and that title is gone |
| deleting the middle task leaves the others in order | the outer two survive — catches a wrong-index delete |
| a newly added task can be deleted again | add through the dialog, then delete it |
| two tasks with the same title delete one at a time | duplicates are separate objects, so only one goes |
| deleting every task leaves an empty list | zero tiles, and no empty-state message yet |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 24 tests passed
```

The "middle task" and "same title" tests are the ones worth keeping in mind: a count-only test
passes even when the wrong row is deleted. See
[remove() matches by equality](concepts/callbacks.md#remove-matches-by-equality-not-position).

## 19 — Explain *why* an empty title is refused

The silent refusal became a real error message:

| Before | After |
| --- | --- |
| `TextField` | `TextFormField` wrapped in a `Form` with a `GlobalKey` |
| `if (_taskController.text.trim().isEmpty) return;` | `if (!_formKey.currentState!.validate()) return;` |
| nothing happened, no explanation | **"Task title is required"** under the field |

`flutter analyze` was clean and the suite passed on the first run — the two tests that touched the
dialog had already been updated to `TextFormField` and to expect the message.

Three tests were added for the cases where the message must be *absent*, taking the suite to 27:

| Test | Asserts |
| --- | --- |
| no error is shown before the first attempt | an empty field alone does not trigger a complaint |
| typing a valid title after an error clears it and adds | the error does not block the retry |
| the error does not survive reopening the dialog | a fresh `Form` each time |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 27 tests passed
```

A suite that only checked the message *appears* would still pass if the error got stuck on screen
forever. See
[when the message appears, and when it goes](concepts/dialogs-and-input.md#when-the-message-appears-and-when-it-goes).

## 20 — Capture the optional description

The dialog grew a second field, and the row grew a second line:

| File | Change |
| --- | --- |
| [`screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart) | a second controller and `TextFormField` (no validator — it is optional), both fields in a `Column` inside the existing `Form` |
| [`widgets/task_tile.dart`](../task_manager/lib/widgets/task_tile.dart) | `subtitle` shows the description, or is `null` when there is none |

`flutter analyze` was clean, but **ten tests failed** — with two fields on screen,
"find the text field" no longer identifies one:

```text
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 2 widgets with type "TextFormField">
   Which: is too many
```

The fix was a `Key` on each field, and a named `Finder` per field in the test file:

```dart
final Finder titleField = find.byKey(const Key('titleField'));
final Finder descriptionField = find.byKey(const Key('descriptionField'));
```

Every `enterText` then says which field it means. Four tests were added, taking the suite to 32:

| Test | Asserts |
| --- | --- |
| a description is shown under the title | both strings appear, and the description is inside the `TaskTile` |
| the description is optional | leaving it blank still adds the task, and `subtitle` is `null` |
| a whitespace-only description shows no subtitle | `'     '` produces no second line |
| the description is cleared on reopening | nothing carries over from a cancelled dialog |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 32 tests passed
```

New concepts are in
[a second field, and why Form paid off](concepts/dialogs-and-input.md#a-second-field-and-why-form-paid-off)
and [Key — a label a test can search for](concepts/dialogs-and-input.md#key--a-label-a-test-can-search-for).

## 21 — Bring back the empty state

Deleting every task used to leave a blank screen. The body now picks between two widgets:

```dart
body: tasks.isEmpty
    ? const Center(child: Column(...))   // icon + "No tasks yet" + what to do
    : ListView.builder(...),
```

**A near-miss worth recording.** The local `feature/project-setup` branch was two commits behind
`origin`, so the working copy of `home_screen.dart` was the version from *before* the description
feature. Committing the edit as written would have silently deleted work already merged in pull
request #11. What caught it:

```bash
git branch -vv
#   feature/project-setup  b5d19ec [origin/feature/project-setup: behind 2]
```

The fix was to branch from `origin/feature/project-setup` and re-apply the change on top of the
current file, rather than carrying the stale one forward. **`git branch -vv` before starting work is
the cheap habit that avoids this.**

`flutter analyze` was clean; one test failed, and it was right to:

```text
Expected: exactly one matching candidate
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "ListView": []>
```

That test asserted a `ListView` still existed after deleting everything — true when the list was
always built, wrong now the empty state replaces it. Updated, and three tests added, taking the suite
to 35:

| Test | Asserts |
| --- | --- |
| deleting every task leaves an empty list *(updated)* | no `ListView`; the message, hint and icon are shown |
| the empty state is hidden while tasks exist | the mirror image — message absent, `ListView` present |
| adding a task replaces the empty state with the list | the swap works in both directions |
| the add button stays available on the empty state | the screen says "press +", so it must be there |

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 35 tests passed
```

New concepts are in
[an empty list is a different screen](concepts/lists.md#an-empty-list-is-a-different-screen).

## 22 — Add unit tests for the `Task` model

The first tests that build no widgets at all:
[`test/models/task_test.dart`](../task_manager/test/models/task_test.dart), mirroring
`lib/models/task.dart`.

```bash
flutter test test/models/task_test.dart
```

`flutter analyze` was clean and everything passed first time — a model with no Flutter import is easy
to test, which is the payoff for keeping it plain data.

Six tests covered construction and defaults. Three more were added to write down decisions the code
relies on but nothing checked:

| Test | Records |
| --- | --- |
| the title cannot be changed | `title` is `final`; the assignment is a compile error, kept as a comment |
| two tasks with the same values are not equal | `Task` has no `==`, so comparison is by identity — which is what `tasks.remove(task)` depends on |
| an empty description is stored as given | the model does not tidy input, so `''` can end up where `null` was meant |

The last two will fail if someone adds value equality or input normalising — which is the point. A
failing test then points straight at the code that assumed otherwise.

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 44 tests passed (35 widget + 9 unit)
```

New concepts are in
[unit tests: test, not testWidgets](concepts/testing.md#unit-tests-test-not-testwidgets).

## 23 — Save the tasks to the device

The first package dependency, and the first code that outlives the app running:

```bash
flutter pub add shared_preferences      # or add the line and run flutter pub get
```

| File | Change |
| --- | --- |
| [`pubspec.yaml`](../task_manager/pubspec.yaml) | `shared_preferences: ^2.5.3` |
| [`models/task.dart`](../task_manager/lib/models/task.dart) | `toMap()` and a `Task.fromMap()` factory |
| [`services/task_storage.dart`](../task_manager/lib/services/task_storage.dart) | **new** — `saveTasks` / `loadTasks`, JSON in one key |
| [`screens/home_screen.dart`](../task_manager/lib/screens/home_screen.dart) | loads in `initState`, saves after every change, shows a spinner while loading |

**Another stale-branch near-miss, worse than last time.** Local `feature/project-setup` was **six**
commits behind, so the working copies of `home_screen.dart`, `task_tile.dart` and `widget_test.dart`
predated the description field, the empty state and the unit tests. Committing them would have
reverted three merged pull requests:

```bash
git diff --stat origin/feature/project-setup
#  task_manager/lib/widgets/task_tile.dart   |   3 -      ← the subtitle
#  task_manager/test/widget_test.dart        | 205 +----   ← 205 lines of tests
```

The persistence work was re-applied onto files taken from `origin/feature/project-setup` instead. See
[check the branch is current before editing](concepts/project-layout.md#check-the-branch-is-current-before-editing).

`flutter analyze` was clean, but **the widget tests failed in bulk** — they expected three sample
tasks, and the screen now starts empty and loads from storage:

```text
Expected: exactly 3 matching candidates
  Actual: _TypeWidgetFinder:<Found 0 widgets with type "TaskTile": []>
```

The fix was to give the tests a store to read:

```dart
setUp(() => seedStorage(initialTitles));       // SharedPreferences.setMockInitialValues

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const TaskManagerApp());
  await tester.pumpAndSettle();                // let the load finish
}
```

Every test then starts the app the same way a user would, load included. Six persistence tests were
added on top, taking the suite to 56:

| Test | Asserts |
| --- | --- |
| shows a spinner until the saved tasks arrive | `CircularProgressIndicator` on the first frame, gone after |
| shows the empty state when nothing has been saved | a first run is not an error |
| an added task is still there after a restart | title **and** description survive |
| a completed task is still completed after a restart | the tick is saved, not just drawn |
| a deleted task stays deleted after a restart | the removal is saved |
| unreadable stored data leaves the app usable | garbage in the key → empty state, and adding still works |

Plus six more unit tests for `toMap`/`fromMap`, including a missing `isCompleted` falling back to
`false`, and a round trip producing a *different object* with equal values.

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 56 tests passed (41 widget + 15 unit)
```

One test needed a second attempt: with mock storage the load finishes almost instantly, so an extra
`pump()` after `pumpWidget` missed the spinner completely. New concepts are in
[concepts/persistence.md](concepts/persistence.md).

## 24 — Test the storage service on its own

[`test/services/task_storage_test.dart`](../task_manager/test/services/task_storage_test.dart) tests
`TaskStorage` directly, without building a screen.

```bash
flutter test test/services/task_storage_test.dart
```

`flutter analyze` was clean and all six tests passed first time. Two more were added for behaviour the
rest of the app quietly depends on, taking the suite to 64:

| Test | Records |
| --- | --- |
| saving replaces the previous list rather than adding to it | one key, one value — the reason deleting a task sticks |
| loading unreadable data throws, leaving the caller to handle it | the service reports the problem; `HomeScreen` decides what the user sees |

The second one is the deliberate half of a pair. `loadTasks` does not catch its own errors, and the
`try`/`catch` sits in the screen — because showing the empty state is a UI decision, not a storage one.
Both halves are now pinned: this test says the error escapes, and *unreadable stored data leaves the
app usable* says the screen absorbs it.

```bash
dart format lib test
flutter analyze         # No issues found!
flutter test            # 64 tests passed (41 widget + 23 unit)
```

New concepts are in
[testing the service on its own](concepts/persistence.md#testing-the-service-on-its-own).
