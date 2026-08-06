// Widget tests for the Task Manager app shell.
// Explained in docs/concepts/testing.md
//
// Run with:  flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The app is imported as a package, using the `name:` from pubspec.yaml.
// HomeScreen needs its own import: main.dart imports it rather than declaring
// it, and Dart imports are not transitive.
import 'package:task_manager/main.dart';
import 'package:task_manager/models/task.dart';
import 'package:task_manager/screens/home_screen.dart';
import 'package:task_manager/widgets/task_tile.dart';

void main() {
  group('TaskManagerApp', () {
    // testWidgets (not test) builds a real widget tree, headlessly.
    testWidgets('renders the app bar title', (WidgetTester tester) async {
      // pumpWidget mounts the tree and renders one frame.
      await tester.pumpWidget(const TaskManagerApp());

      // MaterialApp's title is OS metadata, so only the AppBar's Text matches.
      expect(find.text('Task Manager'), findsOneWidget);
    });

    testWidgets('renders one row per task', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      // findsNWidgets checks an exact count — one tile for each sample task.
      expect(find.byType(TaskTile), findsNWidgets(HomeScreen.tasks.length));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows each task title', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      for (final Task task in HomeScreen.tasks) {
        expect(find.text(task.title), findsOneWidget);
      }
    });

    testWidgets('every task starts unchecked and not tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      final Iterable<Checkbox> boxes = tester.widgetList<Checkbox>(
        find.byType(Checkbox),
      );

      expect(boxes.length, HomeScreen.tasks.length);
      for (final Checkbox box in boxes) {
        expect(box.value, isFalse); // isCompleted defaults to false
        expect(box.onChanged, isNull); // disabled, like the "+" button
      }
    });

    testWidgets('builds the expected Material scaffolding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // The add button exists, showing a "+" icon.
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('the add button is still disabled', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      final FloatingActionButton fab = tester.widget(
        find.byType(FloatingActionButton),
      );

      // onPressed: null is what makes a button disabled in Flutter. When adding
      // a task is wired up, this test changes to check the tap does something.
      expect(fab.onPressed, isNull);
    });

    testWidgets('applies the orange seed colour scheme', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      // tester.element gives a BuildContext, which Theme.of needs.
      final ThemeData theme = Theme.of(tester.element(find.byType(Scaffold)));

      // fromSeed derives the palette, so primary is not orangeAccent itself —
      // compare against a scheme built from the same seed.
      expect(theme.colorScheme.brightness, Brightness.light);
      expect(
        theme.colorScheme.primary,
        ColorScheme.fromSeed(seedColor: Colors.orangeAccent).primary,
      );
    });

    testWidgets('hides the debug banner', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      // tester.widget returns the actual instance, so properties can be read.
      final MaterialApp app = tester.widget(find.byType(MaterialApp));

      expect(app.debugShowCheckedModeBanner, isFalse);
      expect(app.title, 'Task Manager');
    });
  });
}
