# Task Manager — Learning Notes

Start here. The notes are split into small files so each one stays short.

## Commands I ran

[**commands.md**](commands.md) — the chronological log: every command, its output, and anything that
needed following up.

## Concepts I learned

| File | Covers |
| --- | --- |
| [concepts/glossary.md](concepts/glossary.md) | Every term in one table, one plain sentence each |
| [concepts/widgets.md](concepts/widgets.md) | Widgets, the widget tree, stateless vs stateful, `build`, `const` |
| [concepts/theming-layout.md](concepts/theming-layout.md) | Colours from one seed, layout by wrapping, disabled buttons |
| [concepts/dart-basics.md](concepts/dart-basics.md) | Models, `?` for null, named parameters and `required` |
| [concepts/lists.md](concepts/lists.md) | `ListView.builder`, `ListTile`, passing data down, `final`/`const` |
| [concepts/testing.md](concepts/testing.md) | Widget tests, finders and matchers, why failing tests are good |
| [concepts/project-layout.md](concepts/project-layout.md) | Where files live, imports, line endings |

Source files carry only brief comments and point at the file that explains them.

---

## Environment

- **Date:** 2026-08-06
- **Host:** `LKCOL-WN-ENG-KarthickS` — WSL2, Ubuntu 24.04.1 LTS (kernel 5.15.167.4-microsoft-standard-WSL2)
- **Repository path:** `/mnt/d/Projects/task-manager` (`d:\Projects\task-manager` on Windows)
- **Flutter:** 3.44.8 (stable channel)
- **Dart SDK constraint:** `^3.12.2`
- **Locale:** `C.UTF-8`

> Flutter lives in WSL (`/home/karthick/flutter/bin`), so `flutter` commands run from the Ubuntu
> distro. The default WSL distro is `docker-desktop`, which has no shell of its own — hence
> `wsl -d Ubuntu` when running from Windows.

## Current state

- The screen shows a scrolling list of three hard-coded tasks, each as a row with an unchecked
  checkbox, plus a disabled "+" button.
- Nothing is interactive yet: the checkboxes and the "+" button are both disabled, and there is no
  saving. The task list is `static const` sample data.
- `flutter analyze` is clean and all 8 widget tests pass.
- `pubspec.yaml` carries the placeholder description `"A new Flutter project."` and no
  dependencies beyond `cupertino_icons` and `flutter_lints`.
- The Android application ID is still the placeholder `com.example.task_manager`.

## Next steps

1. Make the "+" button add a task, and the checkboxes tick — both need `HomeScreen` to become a
   `StatefulWidget` holding the list in state instead of `static const`.
2. Bring back an empty-state message, shown only when the list is empty.
3. Add a unit test for `Task` (no widgets needed) alongside the widget tests.
4. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
5. Update `pubspec.yaml` (description, and dependencies for state management + saving).
6. Replace the Android placeholder application ID.
