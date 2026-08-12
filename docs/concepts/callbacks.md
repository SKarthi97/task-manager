« [back to index](../Steps.md)

# Callbacks: telling the parent something happened

Explains [`lib/widgets/task_tile.dart`](../../task_manager/lib/widgets/task_tile.dart) and the
`onToggle` wiring in
[`lib/screens/home_screen.dart`](../../task_manager/lib/screens/home_screen.dart).

## The problem

Tapping a checkbox has to change a task. But the tile does not own the tasks — `HomeScreen` does. So
the tile cannot make the change itself.

The rule that follows from that is worth remembering:

> **Data flows down. Events flow up.**
> The parent passes data to the child; the child tells the parent what happened.

## Passing a function as a parameter

In Dart a function is a value, so it can be passed in like any other:

```dart
class TaskTile extends StatelessWidget {
  final Task task;             // data coming down
  final VoidCallback onToggle; // an event going up
```

`VoidCallback` is Flutter's shorthand for "a function that takes nothing and returns nothing" — the
same as writing `void Function()`.

The child calls it without knowing or caring what it does:

```dart
onChanged: (_) {
  onToggle();     // "something happened" — that is all the tile says
}
```

And the parent decides what it means, next to the data it owns:

```dart
TaskTile(
  task: task,
  onToggle: () {
    setState(() {
      task.isCompleted = !task.isCompleted;
    });
  },
)
```

That is why `setState` is in the screen and not in the tile: `setState` belongs wherever the data
lives.

```text
HomeScreen                        owns tasks, owns setState
   │  task: task                     (data down)
   │  onToggle: () { ... }           (function down…)
   ▼
TaskTile                          displays it, calls onToggle()
   └──── "the box was tapped" ────┘  (…event up)
```

## More than one callback

Deleting works the same way, for the same reason — the tile cannot remove a task from a list it does
not own:

```dart
final VoidCallback onToggle;   // "the box was tapped"
final VoidCallback onDelete;   // "the bin was tapped"
```

Each is a separate, named event. The tile does not know that one ticks a task and the other destroys
it; it only reports which button was pressed. Everything that *decides* stays in the screen.

`onDelete` can be handed to `IconButton` directly:

```dart
IconButton(
  icon: const Icon(Icons.delete),
  onPressed: onDelete,        // no wrapper needed
  tooltip: 'Delete task',
)
```

No `() { onDelete(); }` wrapper, because `onDelete` already has exactly the shape `onPressed` wants —
takes nothing, returns nothing. (The checkbox needs the wrapper only because it insists on passing
the new value.)

> **`tooltip` is not decoration.** An icon has no words in it, so screen readers have nothing to
> announce without one. It also appears on hover and long-press. Any icon-only button should have it.

## `remove()` matches by equality, not position

```dart
tasks.remove(task);
```

`remove()` deletes the first element that is `==` to what you give it. `Task` does not define `==`,
so Dart falls back to **identity** — is this the same object? Since every `Task` is a separate
object, the right one is removed even when two tasks share a title.

That is correct today, and it is worth knowing *why* it is correct, because it stops being true the
moment someone gives `Task` value equality:

```dart
// If Task ever defines == based on title...
bool operator ==(Object other) => other is Task && other.title == title;
// ...then remove() deletes the FIRST task with that title, not the one tapped.
```

Two ways to be immune to that:

| Approach | Why it is safe |
| --- | --- |
| `tasks.removeAt(index)` | position is unambiguous — no equality involved |
| give each `Task` a unique `id` | identity is explicit rather than accidental |

An `id` is the usual answer once tasks are saved and reloaded, because a reloaded task is a
different object from the one that was saved.

## `_` for an argument you do not need

`Checkbox` hands its callback the new value, but the tile does not use it — the parent flips the
current value instead. Naming that parameter `_` is the convention for "I must accept this, I am not
going to use it":

```dart
onChanged: (_) { onToggle(); }
```

## `? :` — Dart's inline if

```dart
decoration: task.isCompleted
    ? TextDecoration.lineThrough
    : TextDecoration.none,
```

Read it as *if isCompleted then lineThrough otherwise none*. It fits where a full `if` statement
cannot, because this position needs a **value**, not statements.

## Why `isCompleted` is not `final`

`Task` is now mixed:

```dart
final String title;   // never changes
bool isCompleted;     // gets ticked on and off
String? description;
```

Flipping the field in place is the simplest thing that works, and it is what the toggle does.

The alternative is to keep every field `final` and *replace* the task with a modified copy — usually
via a `copyWith` method:

```dart
tasks[index] = task.copyWith(isCompleted: !task.isCompleted);
```

| | In-place (`bool isCompleted`) | Immutable + `copyWith` |
| --- | --- | --- |
| Code needed | one line | a `copyWith` method |
| Risk | anything holding the task sees it change | nothing changes underneath you |
| Fits | small apps, local state | shared state, undo, state-management packages |

In-place is fine here. It is worth knowing the other option exists, because most state-management
packages expect immutable models.

## Testing a toggle

```dart
await tester.tap(find.byType(Checkbox).first);
await tester.pump();

final boxes = tester.widgetList<Checkbox>(find.byType(Checkbox)).toList();
expect(boxes.first.value, isTrue);
expect(boxes.skip(1).every((box) => box.value == false), isTrue);  // others untouched
```

`.first` and `.last` pick one widget when a finder matches several. Checking that the *other* boxes
did not change is the assertion that catches a toggle wired to the wrong index — a real and easy
mistake in list code.

The strikethrough is checked by reading the style off the `Text` widget:

```dart
final Text title = tester.widget(find.text('Learn Flutter widgets'));
expect(title.style?.decoration, TextDecoration.lineThrough);
```

## Picking one widget out of several

When a finder matches many widgets — three delete buttons, say — `tap` needs to know which one:

| Written as | Taps |
| --- | --- |
| `find.byIcon(Icons.delete).first` | the first row |
| `find.byIcon(Icons.delete).last` | the last row |
| `find.byIcon(Icons.delete).at(1)` | the second row (counting from 0) |

Without one of these, `tap` throws — "found 3 widgets, expected 1" — which is a useful error rather
than a silent guess.

The delete tests lean on this to check the *right* task was removed: delete the middle one, then
assert the outer two are still there. Deleting by the wrong index passes a naive count-only test and
fails this one.

---

**Related:** [state](state.md) · [lists](lists.md) · [testing](testing.md)
