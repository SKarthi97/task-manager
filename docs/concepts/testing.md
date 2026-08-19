« [back to index](../Steps.md)

# Testing

Explains [`test/widget_test.dart`](../../task_manager/test/widget_test.dart).

## The three test tiers

| Tier | Scope | Speed |
| --- | --- | --- |
| Unit test | plain Dart, no widgets | fastest |
| Widget test | one widget tree, headless — no device needed | fast |
| Integration test | the whole app on a real device or browser | slow |

## Unit tests: `test`, not `testWidgets`

A unit test checks plain Dart. No widget tree, no `tester`, no pumping:

```dart
test('new task is incomplete by default', () {
  final task = Task(title: 'Learn Flutter');

  expect(task.isCompleted, isFalse);
});
```

That is the whole thing — build the object, check it. This is possible only because `Task` is a
[model](dart-basics.md): plain data with no Flutter import. A class that reached for widgets could not
be tested this way.

| | `test` | `testWidgets` |
| --- | --- | --- |
| Gives you | nothing — just a function body | a `WidgetTester` |
| Needs pumping | no | yes |
| Speed | instant | milliseconds |
| Tests | logic and data | what appears on screen |

An `async` unit test is still a unit test. `TaskStorage` returns `Future`s, so its tests `await` — but
there is no screen, so no `testWidgets` and no pumping:

```dart
test('saves and loads a task', () async {
  await storage.saveTasks([Task(title: 'Learn persistence')]);

  expect((await storage.loadTasks()).first.title, 'Learn persistence');
});
```

See [testing the service on its own](persistence.md#testing-the-service-on-its-own).

### The test folder mirrors `lib`

```text
lib/models/task.dart      →   test/models/task_test.dart
lib/services/...          →   test/services/..._test.dart
lib/widgets/...           →   test/widgets/..._test.dart
```

The `_test.dart` suffix is not decoration: `flutter test` finds files by that name. A file called
`task_tests.dart` or `test_task.dart` is silently never run.

### Tests as documentation

Two of the `Task` tests exist to *pin down* behaviour rather than to catch a bug:

```dart
test('two tasks with the same values are not equal', () {
  expect(Task(title: 'A') == Task(title: 'A'), isFalse);
});
```

`Task` defines no `==`, so Dart compares identity. That is exactly what the delete button depends on —
see [remove() matches by equality](callbacks.md#remove-matches-by-equality-not-position). Writing it
down means that if someone adds value equality later, this test fails and points straight at the code
that would break.

```dart
test('an empty description is stored as given, not turned into null', () {
  expect(Task(title: 'A', description: '').description, '');
});
```

This one records a known rough edge — the model does not tidy its input, which is why `''` can end up
stored where `null` was meant. When that gets fixed, the failing test is the reminder to update the
places that work around it.

A test that captures a decision is worth writing even when nothing is broken. It turns "we think it
works this way" into something the toolchain checks.

## `testWidgets` and "pumping"

Widget tests use `testWidgets`, not `test`, and get a `WidgetTester` to work with.

`await tester.pumpWidget(...)` builds the screen and draws **one frame**. Tests draw frames by hand
rather than waiting on a real clock, which is why they finish in milliseconds. Later, when the app
has animations or loading, `tester.pump()` draws the next frame and `tester.pumpAndSettle()` keeps
drawing until nothing is moving.

## Finders and matchers

A test asks two things: *which widget?* (a **finder**) and *how many did you expect?* (a **matcher**).

| Finder | Looks for |
| --- | --- |
| `find.text('No tasks yet')` | text shown on screen |
| `find.byType(Center)` | a kind of widget |
| `find.byIcon(Icons.add)` | an icon |
| `find.descendant(of:, matching:)` | a widget *inside* another widget |

| Matcher | Means |
| --- | --- |
| `findsOneWidget` | exactly one, and it must be there |
| `findsNothing` | must not be there at all |
| `findsNWidgets(3)` | exactly three |

## Looking inside a widget from a test

Sometimes checking what is on screen is not enough — you need a widget's actual settings:

```dart
final fab = tester.widget(find.byType(FloatingActionButton));
expect(fab.onPressed, isNull);          // is the button disabled?
```

- `tester.widget(finder)` hands back the real widget, so you can read its properties.
- `tester.element(finder)` hands back its `BuildContext`, which is what `Theme.of(context)` needs.
  It is the same upward lookup the app does, performed from a test.

## Testing a generated palette

Because `fromSeed` *works out* the palette, `colorScheme.primary` is **not** literally
`Colors.orangeAccent` — so comparing against orange would fail.

The test compares against a scheme built from the same seed instead. That proves the seed was
applied, without hard-coding a colour value that Flutter is free to adjust in a future version.

## Testing something interactive

Once a button does something, a test can press it:

```dart
await tester.tap(find.byType(FloatingActionButton));
await tester.pump();     // draw the frame the tap caused
```

The `pump` is not optional — without it the test is still looking at the screen from before the tap.
See [state](state.md#testing-a-tap).

For anything that animates — a dialog opening, a page changing — use `pumpAndSettle()` instead: it
keeps drawing frames until nothing is moving. Typing is `tester.enterText(finder, 'text')`. See
[dialogs-and-input](dialogs-and-input.md#testing-typing-and-dialogs).

## Failing tests are the tests working

When the screen text changed and a button was added, two tests failed. Nothing was broken by the
failure — the tests were describing the old screen, and they said so loudly.

The habit to build: after changing the UI, run `flutter test` and update whatever fails to describe
the *new* intended behaviour. A test that needs no updating when behaviour changes was not checking
anything useful.

---

**Related:** [widgets](widgets.md) · [theming-layout](theming-layout.md) ·
[project-layout](project-layout.md)
