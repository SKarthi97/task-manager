# Glossary

Every term in one place, one plain sentence each. Follow a link for the longer explanation.

| Term | In plain words | More |
| --- | --- | --- |
| Widget | One piece of the screen. Everything you see is a widget. | [widgets](widgets.md) |
| Widget tree | Widgets nested inside widgets, making up the whole screen. | [widgets](widgets.md) |
| `StatelessWidget` | Shows something, but does not manage changing data. | [widgets](widgets.md) |
| `StatefulWidget` | Can hold data that changes, and redraws when it does. | [state](state.md) |
| `State` | The object beside a widget that keeps the changing data alive. | [state](state.md) |
| `setState` | "The data changed — redraw." Change data inside it. | [state](state.md) |
| `build` | The method that says what to show. | [widgets](widgets.md) |
| `BuildContext` | A widget's "you are here" marker in the tree. | [widgets](widgets.md) |
| `const` | This never changes, so Flutter can reuse it. | [widgets](widgets.md) |
| `Scaffold` | The standard screen frame, with slots to fill. | [widgets](widgets.md) |
| Theme | The app's colours and fonts, set in one place. | [theming-layout](theming-layout.md) |
| Seed colour | One colour Flutter builds a whole palette from. | [theming-layout](theming-layout.md) |
| `onPressed: null` | How you disable a button — there is no `enabled: false`. | [theming-layout](theming-layout.md) |
| `ListView.builder` | A scrolling list that builds only the rows on screen. | [lists](lists.md) |
| `ListTile` | A ready-made row, with slots for an icon, title and more. | [lists](lists.md) |
| `itemBuilder` | The function Flutter calls to build row number *n*. | [lists](lists.md) |
| `final` | Set once when the object is created, never reassigned. | [lists](lists.md) |
| `static` | Belongs to the class itself, not to each instance. | [lists](lists.md) |
| Callback | A function passed to a child so it can report an event upwards. | [callbacks](callbacks.md) |
| `VoidCallback` | "A function taking nothing, returning nothing." | [callbacks](callbacks.md) |
| `? :` | Dart's inline if, where a value is needed rather than statements. | [callbacks](callbacks.md) |
| `copyWith` | Make a changed copy instead of editing an object in place. | [callbacks](callbacks.md) |
| Model | A plain class that holds data, with no screen code in it. | [dart-basics](dart-basics.md) |
| `String?` | A string that is allowed to be null (missing). | [dart-basics](dart-basics.md) |
| `required` | The caller *must* pass this value. | [dart-basics](dart-basics.md) |
| Named parameter | An argument passed by name, like `title: 'Buy milk'`. | [dart-basics](dart-basics.md) |
| `TextField` | A box the user types into. | [dialogs-and-input](dialogs-and-input.md) |
| Controller | Your handle on a text field — reads and clears what was typed. | [dialogs-and-input](dialogs-and-input.md) |
| `dispose` | Cleanup that runs when a screen is removed for good. | [dialogs-and-input](dialogs-and-input.md) |
| `showDialog` | Puts a small screen on top of the current one. | [dialogs-and-input](dialogs-and-input.md) |
| `Navigator.pop` | Closes a dialog, or goes back a screen — the same thing. | [dialogs-and-input](dialogs-and-input.md) |
| `pumpAndSettle` | In a test, keep drawing until animations stop. | [dialogs-and-input](dialogs-and-input.md) |
| Widget test | A test that builds the screen in memory and checks what it shows. | [testing](testing.md) |
| Finder | The part of a test that says *which* widget to look for. | [testing](testing.md) |
| Matcher | The part of a test that says *how many* you expected. | [testing](testing.md) |
| Pump | Draw one frame in a test. | [testing](testing.md) |
| `package:` import | How a file reaches another file in the same project. | [project-layout](project-layout.md) |
