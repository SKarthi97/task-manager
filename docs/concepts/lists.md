« [back to index](../Steps.md)

# Showing a list

Explains [`lib/screens/home_screen.dart`](../../task_manager/lib/screens/home_screen.dart) and
[`lib/widgets/task_tile.dart`](../../task_manager/lib/widgets/task_tile.dart).

## `ListView.builder` builds rows on demand

You could put every row in a `Column` and be done with it. `ListView.builder` is better because it
only builds the rows that are actually on screen — with a thousand tasks, it builds the dozen you can
see, not a thousand.

It needs two things:

```dart
ListView.builder(
  itemCount: tasks.length,              // how many rows in total
  itemBuilder: (context, index) {       // called for each row, given its position
    final task = tasks[index];
    return TaskTile(task: task);
  },
)
```

`itemBuilder` is a function Flutter calls back — you do not call it yourself. It asks "what goes at
position 3?" and your job is to return that one row.

## `ListTile` is a ready-made row

Rather than assembling a row out of `Row`, `Padding` and `Text`, `ListTile` gives you the standard
shape with named slots — and the standard height, spacing and tap behaviour that go with it:

| Slot | Holds | Here |
| --- | --- | --- |
| `leading` | something at the start | the `Checkbox` |
| `title` | the main text | the task title |
| `subtitle` | smaller text below | the description, when there is one |
| `trailing` | something at the end | the delete `IconButton` |

Passing `null` to a slot leaves it out entirely, which is how the row shows no second line when a task
has no description:

```dart
subtitle: task.description == null || task.description!.isEmpty
    ? null                     // no subtitle at all, not an empty one
    : Text(task.description!),
```

An empty `Text('')` would still reserve space and leave a visible gap. `null` means the slot does not
exist.

## An empty list is a different screen

A list with nothing in it should not be a blank rectangle. The body picks between two whole widgets:

```dart
body: tasks.isEmpty
    ? const Center(child: Column(...))    // the empty state
    : ListView.builder(...),              // the list
```

This is [`? :`](callbacks.md) again, but choosing a *widget* rather than a value — and it is the normal
way to switch layouts in Flutter, because `build` has to return one widget either way.

A good empty state answers two questions:

| | Here |
| --- | --- |
| What is missing? | *"No tasks yet"* |
| What do I do about it? | *"Add a task using the + button."* |

The icon carries neither, but it stops the screen looking broken. Note the "+" button lives on the
`Scaffold`, not inside the body — so it stays put through the swap, which is what makes that second
line true.

### Testing a screen that swaps

Every assertion has a mirror image, and the pairs are what make the test meaningful:

```dart
// with tasks
expect(find.text('No tasks yet'), findsNothing);
expect(find.byType(ListView), findsOneWidget);

// after deleting them all
expect(find.text('No tasks yet'), findsOneWidget);
expect(find.byType(ListView), findsNothing);
```

Checking only that the message appears would pass even if the empty state were showing *all the time*,
underneath the list.

## Data goes down; the child does not fetch it

`TaskTile` holds one field:

```dart
final Task task;   // received, not created
```

The tile is *given* its task by whoever builds it. It never reaches out for data, never knows about
the list, and never knows which position it is in. That is what makes it reusable — the same tile
works in a search screen or a "completed" screen without a change.

When the tile needs to *change* something, it does not reach up either — it is handed a function to
call. See [callbacks](callbacks.md).

```text
HomeScreen   owns the list of tasks
    │  passes one task down
    ▼
TaskTile     displays whatever it is given
```

## A widget's own fixed data goes in `static const`

The sample tasks are not passed in from anywhere; they belong to the screen:

```dart
static const List<Task> tasks = [ ... ];
```

`static` means the list belongs to the *class*, not to each instance — there is one copy, not a fresh
one per rebuild. `const` means it is built once when the app is compiled.

This is a placeholder. Once the "+" button works, the list has to be able to change, so it moves out
of `static const` and into state — which is what turns `HomeScreen` into a `StatefulWidget`.

## Immutable models: `final` fields, `const` constructor

`Task` now uses `final` fields and a `const` constructor:

```dart
class Task {
  final String title;      // cannot be reassigned after creation
  const Task({required this.title, ...});
}
```

**`final`** = set once, when the object is created. To "change" a task you build a new one rather than
editing the old one, so no other part of the app can be surprised by a value changing underneath it.

**`const` constructor** = the object can be created at compile time. That is what allows
`static const List<Task> tasks = [...]` — a `const` list can only hold `const` values.

---

**Related:** [widgets](widgets.md) · [dart-basics](dart-basics.md) · [testing](testing.md)
