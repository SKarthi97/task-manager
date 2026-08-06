// What a single task is. Plain data — no Flutter, no screen code.
// Explained in docs/concepts/dart-basics.md

class Task {
  final String title;
  final bool isCompleted;
  final String? description; // ? means this one is allowed to be empty.

  const Task({
    required this.title, // Must be given.
    this.description, // Optional.
    this.isCompleted = false, // New tasks start unfinished.
  });
}
