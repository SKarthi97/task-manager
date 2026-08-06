« [back to index](../Steps.md)

# Widgets

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

---

**Related:** [theming-layout](theming-layout.md) · [testing](testing.md) ·
[glossary](glossary.md)
