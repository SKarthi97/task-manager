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
import 'package:task_manager/screens/home_screen.dart';
import 'package:task_manager/widgets/task_tile.dart';

// The starting tasks are private to _HomeScreenState now, so the tests cannot
// read them. They are listed here instead — if the sample data changes, this
// list changes with it.
const List<String> initialTitles = <String>[
  'Learn Flutter widgets',
  'Build Task Manager app',
  'Practice Dart',
];

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
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('shows each task title', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      for (final String title in initialTitles) {
        expect(find.text(title), findsOneWidget);
      }
    });

    testWidgets('every task starts unchecked and not tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      final Iterable<Checkbox> boxes = tester.widgetList<Checkbox>(
        find.byType(Checkbox),
      );

      expect(boxes.length, initialTitles.length);
      for (final Checkbox box in boxes) {
        expect(box.value, isFalse); // isCompleted defaults to false
        expect(box.onChanged, isNull); // still disabled
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

    testWidgets('the add button is enabled', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      final FloatingActionButton fab = tester.widget(
        find.byType(FloatingActionButton),
      );

      // It has a function to run now, which is what enables a button.
      expect(fab.onPressed, isNotNull);
    });

    testWidgets('tapping add opens the dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      // tap sends the press; pumpAndSettle then keeps drawing frames until the
      // dialog has finished animating open. A single pump would catch it midway.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
      expect(find.text('Add New Task'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('Enter task title'), findsOneWidget); // the hint

      // Nothing added yet — the list is untouched while the dialog is open.
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
    });

    testWidgets('typing a title and confirming adds the task', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // enterText types into the field, as a user would.
      await tester.enterText(find.byType(TextField), 'Write documentation');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing); // dialog closed
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length + 1));
      expect(find.text('Write documentation'), findsOneWidget);
    });

    testWidgets('the title is trimmed before it is used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '   Buy milk   ');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Buy milk'), findsOneWidget);
    });

    testWidgets('cancel closes the dialog without adding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Discard me');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
      expect(find.text('Discard me'), findsNothing);
    });

    testWidgets('an empty title is refused and the dialog stays open', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Whitespace only, which counts as empty once trimmed.
      await tester.enterText(find.byType(TextField), '    ');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget); // still open
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
    });

    testWidgets('the field is empty again on reopening', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'Abandoned text');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The controller is cleared before showing, so nothing carries over.
      expect(find.text('Abandoned text'), findsNothing);
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
