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

// The dialog has two text fields now, so "find the text field" is ambiguous.
// Each one carries a Key in home_screen.dart, and these find them by it.
final Finder titleField = find.byKey(const Key('titleField'));
final Finder descriptionField = find.byKey(const Key('descriptionField'));

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

    testWidgets('every task starts unchecked and tappable', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      final Iterable<Checkbox> boxes = tester.widgetList<Checkbox>(
        find.byType(Checkbox),
      );

      expect(boxes.length, initialTitles.length);
      for (final Checkbox box in boxes) {
        expect(box.value, isFalse); // isCompleted defaults to false
        expect(box.onChanged, isNotNull); // enabled now
      }
    });

    testWidgets('tapping a checkbox marks that task complete', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      final List<Checkbox> boxes = tester
          .widgetList<Checkbox>(find.byType(Checkbox))
          .toList();

      expect(boxes.first.value, isTrue);
      // Only the tapped one changed — the others are untouched.
      expect(boxes.skip(1).every((Checkbox box) => box.value == false), isTrue);
    });

    testWidgets('tapping a checked box unchecks it again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();
      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      final Checkbox box = tester.widget(find.byType(Checkbox).first);
      expect(box.value, isFalse);
    });

    testWidgets('a completed task title is struck through', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      // Before: no strikethrough.
      Text title = tester.widget(find.text(initialTitles.first));
      expect(title.style?.decoration, TextDecoration.none);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pump();

      // After: crossed out.
      title = tester.widget(find.text(initialTitles.first));
      expect(title.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('a newly added task can be completed too', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Tick me');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(Checkbox).last);
      await tester.pump();

      final Checkbox box = tester.widget(find.byType(Checkbox).last);
      expect(box.value, isTrue);
    });

    testWidgets('every row has a delete button', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      expect(find.byIcon(Icons.delete), findsNWidgets(initialTitles.length));
    });

    testWidgets('tapping delete removes that task', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pump();

      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length - 1));
      expect(find.text(initialTitles.first), findsNothing);
    });

    testWidgets('deleting the middle task leaves the others in order', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byIcon(Icons.delete).at(1));
      await tester.pump();

      expect(find.text(initialTitles[1]), findsNothing); // the one tapped
      expect(find.text(initialTitles[0]), findsOneWidget); // untouched
      expect(find.text(initialTitles[2]), findsOneWidget); // untouched
    });

    testWidgets('a newly added task can be deleted again', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Delete me');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      expect(find.text('Delete me'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pump();

      expect(find.text('Delete me'), findsNothing);
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
    });

    testWidgets('two tasks with the same title delete one at a time', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      // Add the same title twice. They are separate objects, so removing one
      // must leave the other — this is what identity-based remove() guarantees.
      for (int i = 0; i < 2; i++) {
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        await tester.enterText(titleField, 'Duplicate');
        await tester.tap(find.text('Add Task'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Duplicate'), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.delete).last);
      await tester.pump();

      expect(find.text('Duplicate'), findsOneWidget);
    });

    testWidgets('deleting every task leaves an empty list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      for (int i = 0; i < initialTitles.length; i++) {
        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pump();
      }

      expect(find.byType(TaskTile), findsNothing);

      // The list is replaced by the empty state, not left as a blank ListView.
      expect(find.byType(ListView), findsNothing);
      expect(find.text('No tasks yet'), findsOneWidget);
      expect(find.text('Add a task using the + button.'), findsOneWidget);
      expect(find.byIcon(Icons.task_alt), findsOneWidget);
    });

    testWidgets('the empty state is hidden while tasks exist', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      expect(find.text('No tasks yet'), findsNothing);
      expect(find.byIcon(Icons.task_alt), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('adding a task replaces the empty state with the list', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      // Empty the list first.
      for (int i = 0; i < initialTitles.length; i++) {
        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pump();
      }
      expect(find.text('No tasks yet'), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Back from empty');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      // The swap goes both ways.
      expect(find.text('No tasks yet'), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.text('Back from empty'), findsOneWidget);
    });

    testWidgets('the add button stays available on the empty state', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      for (int i = 0; i < initialTitles.length; i++) {
        await tester.tap(find.byIcon(Icons.delete).first);
        await tester.pump();
      }

      // The empty state tells the user to press "+", so it had better be there.
      expect(find.byType(FloatingActionButton), findsOneWidget);
      final FloatingActionButton fab = tester.widget(
        find.byType(FloatingActionButton),
      );
      expect(fab.onPressed, isNotNull);
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

      // Two fields now: a required title and an optional description.
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(titleField, findsOneWidget);
      expect(descriptionField, findsOneWidget);
      expect(find.text('Enter task title'), findsOneWidget); // the hints
      expect(find.text('Enter description (optional)'), findsOneWidget);

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
      await tester.enterText(titleField, 'Write documentation');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing); // dialog closed
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length + 1));
      expect(find.text('Write documentation'), findsOneWidget);
    });

    testWidgets('a description is shown under the title', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Read the docs');
      await tester.enterText(descriptionField, 'Start with widgets');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Read the docs'), findsOneWidget);
      expect(find.text('Start with widgets'), findsOneWidget);

      // The subtitle really is the ListTile's, not a stray Text elsewhere.
      expect(
        find.descendant(
          of: find.byType(TaskTile),
          matching: find.text('Start with widgets'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('the description is optional', (WidgetTester tester) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'No description');
      // Description left untouched — the form must still accept it.
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('No description'), findsOneWidget);

      // Row shows the title and nothing else — no blank second line.
      final ListTile tile = tester.widget(
        find
            .descendant(
              of: find.byType(TaskTile),
              matching: find.byType(ListTile),
            )
            .last,
      );
      expect(tile.subtitle, isNull);
    });

    testWidgets('a whitespace-only description shows no subtitle', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Spaces only');
      await tester.enterText(descriptionField, '     ');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      final ListTile tile = tester.widget(
        find
            .descendant(
              of: find.byType(TaskTile),
              matching: find.byType(ListTile),
            )
            .last,
      );
      expect(tile.subtitle, isNull);
    });

    testWidgets('the description is cleared on reopening', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(descriptionField, 'Left behind');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Cancel only clears the title controller, but _showAddTaskDialog clears
      // both before showing — which is what actually keeps this true.
      expect(find.text('Left behind'), findsNothing);
    });

    testWidgets('the title is trimmed before it is used', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, '   Buy milk   ');
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
      await tester.enterText(titleField, 'Discard me');
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
      await tester.enterText(titleField, '    ');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Task title is required'), findsOneWidget);
      expect(find.byType(AlertDialog), findsOneWidget); // still open
      expect(find.byType(TaskTile), findsNWidgets(initialTitles.length));
    });

    testWidgets('no error is shown before the first attempt', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // The field is empty, but the user has not tried yet — nagging before an
      // attempt is the classic validation annoyance.
      expect(find.text('Task title is required'), findsNothing);
    });

    testWidgets('typing a valid title after an error clears it and adds', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Fail once.
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();
      expect(find.text('Task title is required'), findsOneWidget);

      // Then get it right — the error must not block the retry.
      await tester.enterText(titleField, 'Second attempt');
      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Task title is required'), findsNothing);
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Second attempt'), findsOneWidget);
    });

    testWidgets('the error does not survive reopening the dialog', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Add Task')); // fails
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // A fresh Form each time, so the old complaint is gone.
      expect(find.text('Task title is required'), findsNothing);
    });

    testWidgets('the field is empty again on reopening', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      await tester.enterText(titleField, 'Abandoned text');
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

    testWidgets('adding a task with a description displays both', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      final fields = find.byType(TextFormField);

      expect(fields, findsNWidgets(2));

      await tester.enterText(fields.at(0), 'Learn Flutter');

      await tester.enterText(fields.at(1), 'Understand widgets and state');

      await tester.tap(find.text('Add Task'));
      await tester.pumpAndSettle();

      expect(find.text('Learn Flutter'), findsOneWidget);
      expect(find.text('Understand widgets and state'), findsOneWidget);
    });
  });
}
