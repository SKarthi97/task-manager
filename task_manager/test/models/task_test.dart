// Unit tests for the Task model — no widgets, no screen.
// Explained in docs/concepts/testing.md
//
// Run with:  flutter test

// No flutter_test widget imports needed beyond this: plain `test`, not
// `testWidgets`, because there is nothing to draw.
import 'package:flutter_test/flutter_test.dart';
import 'package:task_manager/models/task.dart';

void main() {
  group('Task', () {
    test('creates a task with a title', () {
      final task = Task(title: 'Learn Flutter');

      expect(task.title, 'Learn Flutter');
    });

    test('description is optional', () {
      final task = Task(title: 'Learn Flutter');

      expect(task.description, isNull);
    });

    test('accepts a description', () {
      final task = Task(
        title: 'Learn Flutter',
        description: 'Study widgets and state',
      );

      expect(task.description, 'Study widgets and state');
    });

    test('new task is incomplete by default', () {
      final task = Task(title: 'Learn Flutter');

      expect(task.isCompleted, isFalse);
    });

    test('task can be created as completed', () {
      final task = Task(title: 'Learn Flutter', isCompleted: true);

      expect(task.isCompleted, isTrue);
    });

    test('task completion can be changed', () {
      final task = Task(title: 'Learn Flutter');

      expect(task.isCompleted, isFalse);

      task.isCompleted = true;

      expect(task.isCompleted, isTrue);
    });

    test('the title cannot be changed', () {
      final task = Task(title: 'Learn Flutter');

      // title is final, so there is no setter to call. Uncommenting the line
      // below is a compile error, which is the point of final:
      //   task.title = 'Something else';
      expect(task.title, 'Learn Flutter');
    });

    test('two tasks with the same values are not equal', () {
      final a = Task(title: 'Learn Flutter');
      final b = Task(title: 'Learn Flutter');

      // Task does not define ==, so Dart compares identity: same object or not.
      // The delete button relies on this — tasks.remove(task) takes the exact
      // object tapped, not the first one that looks like it.
      expect(a == b, isFalse);
      expect(a == a, isTrue);
    });

    test('an empty description is stored as given, not turned into null', () {
      final task = Task(title: 'Learn Flutter', description: '');

      // The model does not tidy input. This is why the dialog can end up
      // storing '' and the tile has to check isEmpty as well as null.
      expect(task.description, '');
      expect(task.description, isNotNull);
    });

    // Saving means turning a Task into a Map and back. These are unit tests
    // because toMap/fromMap are plain Dart — no storage involved yet.
    test('converts a task to a map', () {
      final task = Task(
        title: 'Learn Flutter',
        description: 'Study persistence',
        isCompleted: true,
      );

      final map = task.toMap();

      expect(map['title'], 'Learn Flutter');
      expect(map['description'], 'Study persistence');
      expect(map['isCompleted'], true);
    });

    test('creates a task from a map', () {
      final task = Task.fromMap({
        'title': 'Learn Flutter',
        'description': 'Study persistence',
        'isCompleted': true,
      });

      expect(task.title, 'Learn Flutter');
      expect(task.description, 'Study persistence');
      expect(task.isCompleted, true);
    });

    test('round trips a task through a map', () {
      final original = Task(
        title: 'Learn Flutter',
        description: 'Study persistence',
        isCompleted: true,
      );

      final restored = Task.fromMap(original.toMap());

      expect(restored.title, original.title);
      expect(restored.description, original.description);
      expect(restored.isCompleted, original.isCompleted);
    });

    test('a round trip produces a different object', () {
      final original = Task(title: 'Learn Flutter');

      final restored = Task.fromMap(original.toMap());

      // Equal values, but not the same object — which is exactly why saving and
      // reloading breaks identity-based delete, and why tasks will need an id.
      expect(restored.title, original.title);
      expect(restored == original, isFalse);
    });

    test('a missing isCompleted falls back to false', () {
      // Data written by an older version of the app will not have every field.
      final task = Task.fromMap({'title': 'Learn Flutter'});

      expect(task.isCompleted, isFalse);
      expect(task.description, isNull);
    });

    test('a task with no description survives the round trip', () {
      final restored = Task.fromMap(Task(title: 'Learn Flutter').toMap());

      // null goes in, null comes out — jsonEncode keeps it as JSON null.
      expect(restored.description, isNull);
    });
  });
}
