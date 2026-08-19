« [back to index](../Steps.md)

# Saving tasks to the device

Explains [`lib/services/task_storage.dart`](../../task_manager/lib/services/task_storage.dart),
`toMap`/`fromMap` in [`lib/models/task.dart`](../../task_manager/lib/models/task.dart), and the
loading code in [`lib/screens/home_screen.dart`](../../task_manager/lib/screens/home_screen.dart).

Until now the task list lived only in memory: closing the app lost everything.

## The first package dependency

```yaml
dependencies:
  shared_preferences: ^2.5.3
```

`shared_preferences` is a small key–value store on the device — the right size for settings and a
short list, not for thousands of rows (that is a database's job). Adding a line to `pubspec.yaml` and
running `flutter pub get` is all it takes.

The `^` means "this version or any compatible newer one" — `^2.5.3` accepts `2.6.0` but never `3.0.0`,
because a major-version bump is where breaking changes are allowed.

## Storage holds text, not objects

A `Task` cannot be written to disk directly. It has to become something simple and come back:

```text
Task  ──toMap()──▶  Map  ──jsonEncode──▶  String  ──▶ device
Task  ◀fromMap()──  Map  ◀─jsonDecode──  String  ◀── device
```

Two methods on the model do the ends of that trip:

```dart
Map<String, dynamic> toMap() => {
  'title': title,
  'description': description,
  'isCompleted': isCompleted,
};

factory Task.fromMap(Map<String, dynamic> map) => Task(
  title: map['title'] as String,
  description: map['description'] as String?,
  isCompleted: map['isCompleted'] as bool? ?? false,
);
```

**`factory`** marks a constructor that does more than assign fields — it works out what to build and
returns it.

**`as`** asserts a type, needed because a decoded map holds `dynamic` values — JSON carries no type
information, so `map['title']` could be anything as far as Dart knows.

**`?? false`** supplies a fallback when the key is missing. That is not defensive noise: data written
by an *older version of your own app* will not have fields you added later, and it is still on the
user's device. Every `fromMap` should assume something might be absent.

## A service class

`TaskStorage` knows how to store tasks and nothing about the screen:

```dart
class TaskStorage {
  static const String _tasksKey = 'tasks';

  Future<void> saveTasks(List<Task> tasks) async { ... }
  Future<List<Task>> loadTasks() async { ... }
}
```

Same reasoning as a [model](dart-basics.md): one job per class. The screen does not know it is JSON in
`shared_preferences`, so swapping in a database later touches this file only.

The key lives in a `static const` because a mistyped key is a silent bug — you save under `'tasks'`
and read from `'task'`, get nothing back, and nothing errors.

## `Future` and `async`/`await`

Reading from a device takes time, so the answer is not available immediately:

| | Means |
| --- | --- |
| `Future<List<Task>>` | "a list of tasks, later" |
| `Future<void>` | "finished, later, with nothing to hand back" |
| `async` | this function contains waiting |
| `await` | wait here for that `Future`, then carry on |

Only an `async` function can `await`, which is why marking a callback `async` is the first step in
saving from a button press.

## Loading in `initState`, not `build`

```dart
@override
void initState() {
  super.initState();
  _loadTasks();       // not awaited — initState cannot be async
}
```

`initState` runs once, before the first build, and is where work like this belongs. `build` cannot do
it: `build` runs many times a second and must stay free of side effects.

Note `_loadTasks()` is called without `await`. `initState` is not allowed to be `async`, so the load
runs in the background and calls `setState` when it finishes.

## The loading flag

Because the tasks arrive *later*, there is a moment with no data and nothing to show yet:

```dart
bool _isLoading = true;

body: _isLoading
    ? const Center(child: CircularProgressIndicator())
    : tasks.isEmpty
        ? /* empty state */
        : /* the list */
```

Three states, not two. Without the flag, the empty state would flash up on every launch before the
saved tasks appeared — a small thing that makes an app feel broken.

## `mounted` — the screen may be gone

```dart
final savedTasks = await _taskStorage.loadTasks();

if (!mounted) return;      // the screen was closed while we waited

setState(() { ... });
```

Anything can happen during an `await`, including the user leaving the screen. Calling `setState` after
that throws. **After every `await` in a `State`, check `mounted` before touching state.**

## Failing to load is not failing to run

```dart
try {
  ...
} catch (error) {
  setState(() => _isLoading = false);
  debugPrint('Failed to load tasks: $error');
}
```

Stored data can be corrupt or half-written. Without the `catch`, the app crashes on launch — the worst
possible moment, and unrecoverable for the user. With it, the spinner stops, the empty state appears,
and the app still works.

## Redraw first, save second

```dart
onToggle: () async {
  setState(() { task.isCompleted = !task.isCompleted; });   // instant
  await _saveTasks();                                        // takes a moment
}
```

`setState` is immediate; writing is not. Doing the redraw first means the tick appears the moment it is
tapped, and the save happens quietly afterwards. Awaiting first would make the UI wait on the disk.

This version rewrites the whole list on every change, which is fine for a short list. An app with
thousands of rows would save only what changed.

## Identity does not survive a round trip

A loaded task is a **new object** with equal values:

```dart
final restored = Task.fromMap(original.toMap());

expect(restored.title, original.title);   // same values
expect(restored == original, isFalse);     // different object
```

That matters here. `tasks.remove(task)` works by identity — see
[remove() matches by equality](callbacks.md#remove-matches-by-equality-not-position) — which still
works, because the screen deletes an object it is holding, not a copy. But once tasks are compared
across a save (syncing, editing, deduplicating), identity is no longer meaningful, and each task needs
its own `id`.

## Testing storage without a device

`shared_preferences` normally talks to the platform, which does not exist in a widget test. One line
replaces it with an in-memory store:

```dart
SharedPreferences.setMockInitialValues(<String, Object>{'tasks': jsonEncode(...)});
```

So the tests seed storage, then start the app and let it load:

```dart
Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(const TaskManagerApp());
  await tester.pumpAndSettle();          // let the load finish
}
```

`setUp` reseeds before every test, so no test can be affected by what another one saved.

### Testing a restart

Pumping the app a second time in the same test *is* a relaunch — a fresh widget tree reading the same
stored data:

```dart
await tester.tap(find.byIcon(Icons.delete).first);
await tester.pumpAndSettle();

await pumpApp(tester);                   // relaunch

expect(find.text(initialTitles.first), findsNothing);
```

That is the test that proves saving works. Checking the row disappeared before the relaunch only proves
`setState` works.

### The spinner is one frame wide

```dart
await tester.pumpWidget(const TaskManagerApp());   // exactly one frame
expect(find.byType(CircularProgressIndicator), findsOneWidget);
```

With mock storage the load finishes almost instantly, so a single extra `pump()` misses the spinner
entirely — which is exactly what happened on the first attempt at this test.

---

**Related:** [state](state.md) · [dart-basics](dart-basics.md) · [testing](testing.md) ·
[project-layout](project-layout.md)
