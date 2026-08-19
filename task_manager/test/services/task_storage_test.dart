// Unit tests for TaskStorage — the save/load round trip, no widgets.
// Explained in docs/concepts/persistence.md
//
// Run with:  flutter test test/services/task_storage_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/services/task_storage.dart';

void main() {
  group('TaskStorage', () {
    // late means "this gets a value before anything reads it" — assigned in
    // setUp rather than here, so each test gets a fresh instance.
    late TaskStorage storage;

    setUp(() {
      // An empty fake store, so no test sees what another one saved.
      SharedPreferences.setMockInitialValues({});
      storage = TaskStorage();
    });

    // These tests are async because saving and loading return Futures — but they
    // are still plain `test`, not `testWidgets`: there is no screen involved.
    test('return an empty list when nothing is saved', () async {
      final tasks = await storage.loadTasks();

      expect(tasks, isEmpty);
    });

    test('saves and loads a task', () async {
      final original = Task(title: 'Learn persistence');

      await storage.saveTasks([original]);

      final loaded = await storage.loadTasks();

      expect(loaded, hasLength(1));
      expect(loaded.first.title, 'Learn persistence');
    });

    test('preserves the task description', () async {
      final original = Task(
        title: 'Learn persistence',
        description: 'Study SharedPreferences',
      );

      await storage.saveTasks([original]);

      final loaded = await storage.loadTasks();

      expect(loaded.first.description, 'Study SharedPreferences');
    });

    test('preserves completion state', () async {
      final original = Task(title: 'Learn persistence', isCompleted: true);

      await storage.saveTasks([original]);

      final loaded = await storage.loadTasks();

      expect(loaded.first.isCompleted, isTrue);
    });

    test('saves and loads multiple tasks', () async {
      final original = [
        Task(title: 'Learn Flutter', description: 'Widgets'),
        Task(title: 'Practice Dart', isCompleted: true),
      ];

      await storage.saveTasks(original);

      final loaded = await storage.loadTasks();

      expect(loaded, hasLength(2));

      // Order matters: a list that came back shuffled would still pass a
      // length check.
      expect(loaded[0].title, 'Learn Flutter');
      expect(loaded[0].description, 'Widgets');
      expect(loaded[0].isCompleted, isFalse);

      expect(loaded[1].title, 'Practice Dart');
      expect(loaded[1].description, isNull);
      expect(loaded[1].isCompleted, isTrue);
    });

    test('saving an empty list removes previously saved tasks', () async {
      await storage.saveTasks([Task(title: 'Temporary task')]);

      await storage.saveTasks([]);

      final loaded = await storage.loadTasks();

      expect(loaded, isEmpty);
    });

    test(
      'saving replaces the previous list rather than adding to it',
      () async {
        await storage.saveTasks([Task(title: 'First')]);
        await storage.saveTasks([Task(title: 'Second')]);

        final loaded = await storage.loadTasks();

        // One key, one value: the second save overwrites the first. Deleting a
        // task works only because of this.
        expect(loaded, hasLength(1));
        expect(loaded.first.title, 'Second');
      },
    );

    test(
      'loading unreadable data throws, leaving the caller to handle it',
      () async {
        SharedPreferences.setMockInitialValues({'tasks': 'this is not json'});

        // The service does not swallow the error — HomeScreen catches it and shows
        // the empty state. Writing that down keeps the split deliberate: storage
        // reports the problem, the screen decides what the user sees.
        expect(storage.loadTasks(), throwsA(isA<Exception>()));
      },
    );
  });
}
