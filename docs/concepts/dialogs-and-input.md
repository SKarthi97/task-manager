« [back to index](../Steps.md)

# Dialogs and text input

Explains `_showAddTaskDialog` in
[`lib/screens/home_screen.dart`](../../task_manager/lib/screens/home_screen.dart).

The "+" button used to invent a title (`Task 4`). Now it asks.

## A controller is your handle on a text field

A `TextField` shows what the user types, but it does not hand it over. A **controller** is the
connection between the field and your code:

```dart
final TextEditingController _taskController = TextEditingController();

TextField(controller: _taskController)      // wire them together

_taskController.text                        // read what was typed
_taskController.clear()                     // empty the field
```

Without the `controller:` line, the buttons would have no way to see what was entered.

## `dispose` — clean up what you create

```dart
@override
void dispose() {
  _taskController.dispose();
  super.dispose();
}
```

`dispose` runs when the screen is removed for good. A controller holds resources Flutter cannot
clean up by itself, so it has to be released here or it leaks.

The rule to remember: **anything you create in a `State` and keep — controllers, animations,
subscriptions, timers — needs disposing.** Call `super.dispose()` last.

| Method | Runs | Used for |
| --- | --- | --- |
| `initState` | once, when the State is created | setting things up |
| `build` | every redraw | describing the UI |
| `dispose` | once, when the State is destroyed | cleaning up |

## `showDialog` puts a screen on top

```dart
showDialog(
  context: context,
  builder: (context) => AlertDialog(...),
);
```

You get the dimmed background, the tap-outside-to-close behaviour and the open animation for free.
`AlertDialog` is the standard shape:

| Slot | Holds | Here |
| --- | --- | --- |
| `title` | the heading | `'Add New Task'` |
| `content` | the middle | the `TextField` |
| `actions` | the button row at the bottom | Cancel and Add Task |

`hintText` is the grey placeholder inside the field, and `autofocus: true` puts the cursor there
immediately so the user can type without tapping first.

## `Navigator.pop` closes it

```dart
Navigator.pop(context);
```

The same call that goes back a screen also closes a dialog — because in Flutter a dialog *is* just
another route stacked on top. One idea, not two.

## Refusing bad input by doing nothing

```dart
if (_taskController.text.trim().isEmpty) {
  return;            // leave the dialog open
}
```

`trim()` removes surrounding spaces, so `"   "` counts as empty. Returning early skips both the add
and the `Navigator.pop`, so the dialog simply stays open — the user sees nothing happened and can
type something real.

It works, and it is silent. Telling the user *why* (an error message under the field, usually via a
`TextFormField` and a `Form`) is the natural next improvement.

## Testing typing and dialogs

```dart
await tester.tap(find.byType(FloatingActionButton));
await tester.pumpAndSettle();                          // let it animate open

await tester.enterText(find.byType(TextField), 'Write documentation');
await tester.tap(find.text('Add Task'));
await tester.pumpAndSettle();

expect(find.byType(AlertDialog), findsNothing);        // it closed
expect(find.text('Write documentation'), findsOneWidget);
```

Two things to note:

- **`pumpAndSettle`, not `pump`.** A dialog animates open. A single `pump` draws one frame and
  catches it mid-animation; `pumpAndSettle` keeps drawing until everything has stopped moving.
- **`enterText`** types into the field the way a user would, so the controller ends up holding it.

Checking `findsNothing` on the `AlertDialog` is how you assert a dialog closed.

---

**Related:** [state](state.md) · [testing](testing.md) · [widgets](widgets.md)
