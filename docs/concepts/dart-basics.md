« [back to index](../Steps.md)

# Dart basics

Explains [`lib/models/task.dart`](../../task_manager/lib/models/task.dart).

## A model is just data

A **model** is a plain class describing one thing in the app — here, one task. It holds data and
nothing else: no widgets, no `build`, not even an `import` of Flutter.

That separation is the point. Because `Task` knows nothing about the screen, you can change the
screen without touching it, and you can test it with a plain unit test — no widget tree needed.

```text
models/task.dart      what a task IS          (data)
screens/home_screen   how tasks LOOK          (UI)
```

## `?` means "this can be null"

In Dart, a normal type can never hold null. Adding `?` is you saying "this one is allowed to be
missing":

```dart
String  title;        // must always have a value
String? description;  // may be null
```

The payoff is that Dart then refuses to let you use `description` as a string until you have checked
it, so the classic "null crash" is caught while you type rather than at runtime.

## Named parameters, `required`, and defaults

The braces in a constructor make the parameters **named** — callers pass them by name:

```dart
Task(title: 'Buy milk')                        // clear at the call site
Task('Buy milk', null, false)                  // what positional would look like
```

Three things control each one:

| Written as | Means |
| --- | --- |
| `required this.title` | must be provided |
| `this.description` | optional, starts as null |
| `this.isCompleted = false` | optional, starts as `false` |

And `this.title` is shorthand: it takes the passed value and assigns it to the property of the same
name, so there is no assignment line to write.

---

**Related:** [project-layout](project-layout.md) · [glossary](glossary.md)
