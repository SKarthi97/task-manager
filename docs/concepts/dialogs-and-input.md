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

## Validation: telling the user what is wrong

The first version refused empty titles by doing nothing:

```dart
if (_taskController.text.trim().isEmpty) {
  return;            // dialog stays open, no explanation
}
```

That works but is silent — the user presses the button and nothing visibly happens. Flutter's form
validation shows a message instead. Three pieces work together:

**1. `TextFormField` instead of `TextField`.** Same field, but it knows how to validate itself and
show an error under itself.

**2. A `validator` function.** It returns the message to display when the input is bad, and `null`
when it is fine:

```dart
validator: (value) {
  if (value == null || value.trim().isEmpty) {
    return 'Task title is required';   // complain
  }
  return null;                          // no complaint
},
```

Returning `null` meaning "all good" reads backwards at first. Think of the return value as *the
problem*, and no problem means `null`.

**3. A `Form` plus a `GlobalKey`.** `Form` wraps the fields; the key is how code *outside* the form
reaches in to trigger the check:

```dart
final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

Form(key: _formKey, child: TextFormField(...))

// later, in the button:
if (!_formKey.currentState!.validate()) {
  return;
}
```

`validate()` runs every validator in the form, shows any messages, and returns `false` if any of them
complained. With one field this looks like overhead; with four, one call checks them all.

> **A key is a handle on another widget's state.** Normally data flows down through constructors —
> see [callbacks](callbacks.md). A `GlobalKey` is the exception, for exactly this case: reaching a
> widget's state from outside it.

The `!` in `_formKey.currentState!` is Dart's "this is definitely not null". It is safe here because
the form is on screen whenever the button can be pressed — but `!` is a promise *you* are making, and
it crashes if you are wrong.

## A second field, and why `Form` paid off

The description field is where the `Form` stops looking like overhead. `AlertDialog.content` takes one
widget, so the two fields go in a `Column`:

```dart
content: Form(
  key: _formKey,
  child: Column(
    mainAxisSize: MainAxisSize.min,     // only as tall as its children
    children: [
      TextFormField(key: const Key('titleField'), validator: ...),
      const SizedBox(height: 16),       // the gap between them
      TextFormField(key: const Key('descriptionField'), maxLines: 3),
    ],
  ),
),
```

Three small things doing real work:

| | Why |
| --- | --- |
| `mainAxisSize: MainAxisSize.min` | a `Column` tries to fill all vertical space by default; inside a dialog that is wrong |
| `SizedBox(height: 16)` | spacing in Flutter is a widget, not a margin property |
| `maxLines: 3` | the field grows to three lines, then scrolls |

The description has **no validator**, because it is optional — nothing to complain about. The single
`validate()` call still covers both fields; it just finds nothing to say about the second one.

## `Key` — a label a test can search for

With two fields on screen, `find.byType(TextFormField)` matches both, and `enterText` fails with
"found 2 widgets, expected 1". Ten tests broke on exactly that.

The fix is a `Key` on each field:

```dart
TextFormField(key: const Key('titleField'), ...)
```

and finders in the test:

```dart
final Finder titleField = find.byKey(const Key('titleField'));
final Finder descriptionField = find.byKey(const Key('descriptionField'));
```

The test now says *which* field it means, and stays correct if the fields are reordered — where
`.first` and `.last` would silently start testing the wrong one.

> **Two kinds of key, doing different jobs.** A plain `Key` is an identity label — for finding a
> widget, and for keeping state with the right item when a list reorders. A `GlobalKey` additionally
> gives access to a widget's *state*, which is why `_formKey` is one and these are not. Reach for a
> plain `Key` unless you actually need to call into the state.

## An empty box and a missing value are not the same thing

`Task.description` is `String?`, so "no description" should be `null`. But the dialog stores this:

```dart
description: _descriptionController.text.trim()   // "" when the field is empty
```

An untouched field gives `""`, not `null` — so there are now two different ways to say "no
description", and only the UI hides the difference:

```dart
subtitle: task.description == null || task.description!.isEmpty
    ? null
    : Text(task.description!),
```

That guard is why the screen looks right. It is worth knowing the values underneath are inconsistent,
because the next thing that reads `description` may only check one of the two:

```dart
if (task.description != null) { ... }     // true for an empty string — probably not intended
```

Storing the absence properly removes the trap at the source:

```dart
final text = _descriptionController.text.trim();
description: text.isEmpty ? null : text,
```

### When the message appears, and when it goes

Validation only runs when `validate()` is called, which is what makes the behaviour feel right:

| Moment | Message shown? |
| --- | --- |
| dialog just opened, field empty | no — the user has not tried yet |
| Add Task pressed while empty | **yes** |
| valid title typed, Add Task pressed again | no — the task is added, dialog closes |
| dialog cancelled and reopened | no — a fresh `Form` each time |

That first row matters: complaining before the user has attempted anything is the classic validation
annoyance, and it comes for free here because nothing validates until the button is pressed.

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

### Testing validation

An error message is just text on screen, so it is tested like any other text:

```dart
await tester.tap(find.text('Add Task'));      // with the field empty
await tester.pumpAndSettle();
expect(find.text('Task title is required'), findsOneWidget);
```

The useful tests are the ones about when the message is *absent*, because those are the behaviours
that break quietly:

- nothing shown before the first attempt
- gone after a valid title is typed, and the retry still works
- gone when the dialog is reopened

A test suite that only checks the message *appears* would still pass if the error got stuck on screen
forever.

---

**Related:** [state](state.md) · [testing](testing.md) · [widgets](widgets.md)
