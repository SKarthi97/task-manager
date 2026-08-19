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

  // Storage can hold text and numbers, not Task objects — so a task turns
  // itself into a Map on the way out, and back into a Task on the way in.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
      'isCompleted': isCompleted,
    };
  }

  // factory means this constructor does not just assign fields — it works out
  // what to build and returns it.
  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      // `as` asserts the type, because a decoded Map holds dynamic values.
      title: map['title'] as String,
      description: map['description'] as String?,
      // ?? supplies a fallback if the value is missing — data saved by an older
      // version of the app will not have every field this version expects.
      isCompleted: map['isCompleted'] as bool? ?? false,
    );
  }
}
