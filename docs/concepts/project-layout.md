« [back to index](../Steps.md)

# Project layout, imports and line endings

## One widget per file

Moving `HomeScreen` out leaves `main.dart` with just the starting point and the app-wide settings.
That is the usual Flutter layout:

```text
lib/
├── main.dart              starts the app, sets the theme
├── models/
│   └── task.dart          what a task is
├── screens/
│   └── home_screen.dart   one screen per file
└── widgets/
    └── task_tile.dart     one reusable piece of UI
```

The `screens/`, `widgets/`, `models/` split is a convention people follow, not a rule the tools
enforce — but following it means anyone can guess where a file lives.

## Package-relative imports

Files reach each other as `package:task_manager/main.dart` — `task_manager` being the `name:` in
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

## Line endings, and why files "changed" without changing

Windows ends lines with two characters (CRLF); Linux and macOS use one (LF). Flutter, running in
WSL, wrote the generated files with LF; the Windows side kept turning them back into CRLF. Git saw
different bytes and reported the files as modified — even though not one character of content
differed.

[`.gitattributes`](../../.gitattributes) settles it for everyone who clones the repo:

```gitattributes
* text=auto eol=lf     # store and check out text files with LF
*.bat text eol=crlf    # except Windows scripts, which need CRLF
*.png binary           # and never touch binary files
```

It belongs in the repository (unlike a personal `core.autocrlf` setting) so every machine behaves
the same way.

---

**Related:** [dart-basics](dart-basics.md) · [testing](testing.md) · [glossary](glossary.md)
