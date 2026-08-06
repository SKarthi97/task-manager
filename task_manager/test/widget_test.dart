// Widget tests for the Task Manager app shell.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".
//
// Run with:  flutter test

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// The app is imported as a package, using the `name:` from pubspec.yaml.
// HomeScreen needs its own import: main.dart imports it rather than declaring
// it, and Dart imports are not transitive.
import 'package:task_manager/main.dart';
import 'package:task_manager/screens/home_screen.dart';

void main() {
  group('TaskManagerApp', () {
    // testWidgets (not test) builds a real widget tree, headlessly.
    testWidgets('renders the app bar title', (WidgetTester tester) async {
      // pumpWidget mounts the tree and renders one frame.
      await tester.pumpWidget(const TaskManagerApp());

      // MaterialApp's title is OS metadata, so only the AppBar's Text matches.
      expect(find.text('Task Manager'), findsOneWidget);
    });

    testWidgets('renders the centred welcome message', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      expect(find.text('Welcome to Flutter!'), findsOneWidget);

      // find.descendant also checks where the widget sits in the tree.
      expect(
        find.descendant(
          of: find.byType(Center),
          matching: find.text('Welcome to Flutter!'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('builds the expected Material scaffolding', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const TaskManagerApp());

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);

      // Guards against the counter demo's button reappearing.
      expect(find.byType(FloatingActionButton), findsNothing);
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
