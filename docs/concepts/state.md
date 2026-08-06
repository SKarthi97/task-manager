« [back to index](../Steps.md)

# State: data that changes

Explains [`lib/screens/home_screen.dart`](../../task_manager/lib/screens/home_screen.dart).

This is the step where the app stops being a picture and starts being an app.

## Why a `StatefulWidget` was needed

The screen has to remember something that changes: how many tasks there are. A `StatelessWidget`
cannot — it draws once from fixed values. So `HomeScreen` was split in two.

## Two classes, one screen

```dart
class HomeScreen extends StatefulWidget {          // 1. the widget
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> { // 2. the data + the build
  final List<Task> tasks = [ ... ];
  @override
  Widget build(BuildContext context) { ... }
}
```

| Class | Holds | Lifetime |
| --- | --- | --- |
| `HomeScreen` | nothing that changes; still `const` | thrown away and rebuilt constantly |
| `_HomeScreenState` | the task list, and `build` | **kept alive** across rebuilds |

That split is the whole trick. Flutter rebuilds widgets very often, so anything that has to be
remembered cannot live in the widget — it lives in the `State` object beside it, which Flutter holds
on to.

Note `build` moved into the `State` class. And the leading `_` in `_HomeScreenState` makes the class
private to its file, which is the convention: nothing outside needs to see it.

## `setState` — change the data, then redraw

```dart
onPressed: () {
  setState(() {
    tasks.add(Task(title: "Task ${tasks.length + 1}"));
  });
}
```

`setState` does two things: it runs the code you give it, then tells Flutter "this widget's data
changed, run `build` again".

**Adding to the list without `setState` is the classic beginner bug.** The list really does grow —
but nothing tells Flutter to redraw, so the screen keeps showing the old rows and the app looks
broken. Change data *inside* `setState`, always.

Do not put slow work inside it either. Fetch or save first, then call `setState` with just the
result.

## `final` on a list you add to

This looks contradictory but is not:

```dart
final List<Task> tasks = [ ... ];
tasks.add(...);        // fine
tasks = [ ... ];       // not allowed
```

`final` locks the *variable*, not the contents. `tasks` will always point at that same list object;
what is inside it can change. (For a fixed collection you would use `const`, which does freeze the
contents.)

Compare with [`Task`](dart-basics.md), where every field is `final` — a task never changes, and the
list of tasks does.

## Testing a tap

```dart
await tester.tap(find.byType(FloatingActionButton));
await tester.pump();                 // draw the frame the tap caused

expect(find.byType(TaskTile), findsNWidgets(4));
```

`tap` sends the press; `pump` draws the next frame. Forget the `pump` and the test still sees the
pre-tap screen and fails — which is the same lesson as forgetting `setState`, from the other side.

## What the tests can no longer see

The task list used to be `static const` on `HomeScreen`, so the tests read it directly. It is now
private to `_HomeScreenState`, and that is correct — but it means the tests had to change:

```dart
const List<String> initialTitles = ['Learn Flutter widgets', ...];
```

The starting titles are repeated in the test file. That is the honest trade: the tests now check the
screen the way a user sees it — by what is on it — rather than by peeking at the screen's internals.

---

**Related:** [widgets](widgets.md) · [lists](lists.md) · [testing](testing.md)
