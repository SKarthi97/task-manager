« [back to index](../Steps.md)

# Theming and layout

## One colour becomes a whole palette

```dart
colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent)
```

From that one colour, Flutter works out a full matching set — the main colour, background colours,
error colours, and the right text colour to put on top of each one so it stays readable.

Notice that `AppBar` never mentions orange. It reads the colour from the theme. So changing the seed
colour re-tints the entire app at once.

## Layout by wrapping

In Flutter you do not set position or alignment on a widget. You **wrap** it in another widget whose
whole job is that one thing:

| To do this | Wrap in |
| --- | --- |
| put it in the middle | `Center` |
| add space around it | `Padding` |
| stack things vertically | `Column` |
| stack things side by side | `Row` |

Nesting these small widgets is how a layout gets built.

> `style: TextStyle(fontSize: 24)` works fine, but taking the size from
> `Theme.of(context).textTheme` is the better habit — text stays consistent across screens, and it
> respects the larger-text setting for users who need it.

## A disabled button is `onPressed: null`

Flutter has no `enabled: false`. You disable a button by giving it nothing to do:

```dart
FloatingActionButton(
  onPressed: null,        // disabled: greyed out, taps do nothing
  child: Icon(Icons.add),
)
```

Give `onPressed` a function and the button becomes active automatically.

---

**Related:** [widgets](widgets.md) · [testing a generated palette](testing.md#testing-a-generated-palette)
