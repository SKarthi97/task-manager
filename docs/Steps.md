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
| [concepts/dialogs-and-input.md](concepts/dialogs-and-input.md) | Controllers, `dispose`, dialogs that return an answer, validation, `Key`s |
| [concepts/callbacks.md](concepts/callbacks.md) | Data down / events up, `VoidCallback`, `? :`, mutable vs `copyWith` |
| [concepts/persistence.md](concepts/persistence.md) | Saving to the device, `Future`/`async`, `initState`, `mounted` |
| [concepts/testing.md](concepts/testing.md) | Unit vs widget tests, finders and matchers, tests as documentation |
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

- On launch a spinner shows while the saved tasks load.
- With no tasks, the screen shows an icon, *"No tasks yet"* and *"Add a task using the + button."*
- Otherwise it shows a scrolling list of tasks. The "+" button opens a dialog asking
  for a title; typing one and pressing **Add Task** adds it, **Cancel** discards it, and an empty
  title is refused with the message *"Task title is required"*. A second, optional field captures a
  description, which appears as a second line on the row.
- Tapping a task's checkbox ticks it off and crosses out the title; tapping again undoes it.
- Each row has a delete button, which asks for confirmation first — naming the task — and removes
  it only on a clear yes.
- Tasks are saved to the device on every change and reloaded on launch, so the list survives a
  restart. Unreadable stored data falls back to the empty state rather than crashing.
- Still to do: tasks cannot be edited, and there is no undo after a confirmed delete.
- An empty description is stored as `''` rather than `null`, so there are two ways to say "none" —
  see [an empty box and a missing value](concepts/dialogs-and-input.md#an-empty-box-and-a-missing-value-are-not-the-same-thing).
- `flutter analyze` is clean and all 69 tests pass: 46 widget tests, and 23 unit tests covering
  `Task` and `TaskStorage`.
- `pubspec.yaml` still carries the placeholder description `"A new Flutter project."`; its only
  runtime dependencies are `cupertino_icons` and `shared_preferences`.
- The Android application ID is still the placeholder `com.example.task_manager`.

## Next steps

**The app itself**

1. Offer an undo after a confirmed delete, with a `SnackBar` and its `action:`. Confirming is a
   safety net for accidents; undo is the one for changing your mind.
2. Store an empty description as `null` rather than `''`, so "no description" has one meaning.
3. Let a task be edited — the add dialog is most of an edit dialog already, given both fields exist.
4. Give each task an `id`. Saving and reloading makes a new object every time, so identity-based
   comparison stops being meaningful — see
   [identity does not survive a round trip](concepts/persistence.md#identity-does-not-survive-a-round-trip).
5. Save only what changed rather than rewriting the whole list, once the list is long enough to care.

**Housekeeping, still outstanding from setup**

6. Install the Android SDK and register it with `flutter config --android-sdk <path>`.
7. Update the `pubspec.yaml` description, which is still `"A new Flutter project."`.
8. Replace the Android placeholder application ID `com.example.task_manager`.
