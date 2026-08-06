// What a single task is: its data, and nothing else.
// Concepts used here are explained in docs/Steps.md — "Concepts I learned".
//
// Note there is no Flutter import. A model is plain Dart — it holds data and
// knows nothing about the screen, so it can be tested on its own.

// Class declaration — Task as a datatype.
class Task {
  // Properties: the pieces of data every task carries.
  String title;
  bool isCompleted;

  // The ? means "this may be null" — a task does not have to have a
  // description. Dart will not let you use it without checking for null first,
  // which is how it prevents null crashes.
  String? description;

  // Constructor: how a Task gets created.
  //
  // The braces { } make these named parameters, so callers pass them by name:
  //   Task(title: 'Buy milk')
  // rather than by position. Longer to type, much harder to get wrong.
  Task({
    // required means "the caller must provide a title", and `this.title`
    // assigns it straight to the property above.
    required this.title,
    // No `required` and no default, so description is optional and starts null.
    this.description,
    // A default value: leave it out and a new task starts as not completed.
    this.isCompleted = false,
  });
}
