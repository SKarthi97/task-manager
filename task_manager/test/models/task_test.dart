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
  });
}
