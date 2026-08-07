// What a single task is. Plain data — no Flutter, no screen code.
// Explained in docs/concepts/dart-basics.md

class Task {
  final String title; // final: set once, never reassigned.
  bool isCompleted; // Not final — a task gets ticked off and on.
  String? description; // ? means this one is allowed to be empty.

  Task({
    required this.title, // Must be given.
    this.description, // Optional.
    this.isCompleted = false, // New tasks start unfinished.
  });
}
