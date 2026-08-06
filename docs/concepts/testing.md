« [back to index](../Steps.md)

# Testing

Explains [`test/widget_test.dart`](../../task_manager/test/widget_test.dart).

## The three test tiers

| Tier | Scope | Speed |
| --- | --- | --- |
| Unit test | plain Dart, no widgets | fastest |
| Widget test | one widget tree, headless — no device needed | fast |
| Integration test | the whole app on a real device or browser | slow |

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

## Failing tests are the tests working

When the screen text changed and a button was added, two tests failed. Nothing was broken by the
failure — the tests were describing the old screen, and they said so loudly.

The habit to build: after changing the UI, run `flutter test` and update whatever fails to describe
the *new* intended behaviour. A test that needs no updating when behaviour changes was not checking
anything useful.

---

**Related:** [widgets](widgets.md) · [theming-layout](theming-layout.md) ·
[project-layout](project-layout.md)
