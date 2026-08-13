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
| [concepts/lists.md](concepts/lists.md) | `ListView.builder`, `ListTile`, empty states, passing data down |
| [concepts/state.md](concepts/state.md) | `StatefulWidget`, `setState`, and testing a tap |
| [concepts/dialogs-and-input.md](concepts/dialogs-and-input.md) | Controllers, `dispose`, `showDialog`, validation, `Key`s for tests |
| [concepts/callbacks.md](concepts/callbacks.md) | Data down / events up, `VoidCallback`, `? :`, mutable vs `copyWith` |
| [concepts/testing.md](concepts/testing.md) | Widget tests, finders and matchers, why failing tests are good |
| [concepts/project-layout.md](concepts/project-layout.md) | Where files live, imports, stale branches, line endings |

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

- With no tasks, the screen shows an icon, *"No tasks yet"* and *"Add a task using the + button."*
- Otherwise it shows a scrolling list of tasks. The "+" button opens a dialog asking
  for a title; typing one and pressing **Add Task** adds it, **Cancel** discards it, and an empty
  title is refused with the message *"Task title is required"*. A second, optional field captures a
  description, which appears as a second line on the row.
- Tapping a task's checkbox ticks it off and crosses out the title; tapping again undoes it.
- Each row has a delete button that removes that task.
- Still to do: tasks cannot be edited, deletion is instant with no undo, and nothing is saved —
  closing the app resets the list.
- An empty description is stored as `''` rather than `null`, so there are two ways to say "none" —
  see [an empty box and a missing value](concepts/dialogs-and-input.md#an-empty-box-and-a-missing-value-are-not-the-same-thing).
- `flutter analyze` is clean and all 35 widget tests pass.
- `pubspec.yaml` carries the placeholder description `"A new Flutter project."` and no
  dependencies beyond `cupertino_icons` and `flutter_lints`.
- The Android application ID is still the placeholder `com.example.task_manager`.

## Next steps

**The app itself**

1. Offer an undo after deleting, with a `SnackBar` and its `action:`. Deletion is currently instant
   and permanent.
2. Store an empty description as `null` rather than `''`, so "no description" has one meaning.
3. Let a task be edited — the add dialog is most of an edit dialog already, given both fields exist.
4. Add a unit test for `Task` (no widgets needed) alongside the widget tests.
5. Save the list so it survives a restart. At that point tasks need an `id` — see
   [remove() matches by equality](concepts/callbacks.md#remove-matches-by-equality-not-position).

**Housekeeping, still outstanding from setup**

6. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
7. Update `pubspec.yaml` (description, and dependencies for state management + saving).
8. Replace the Android placeholder application ID `com.example.task_manager`.
