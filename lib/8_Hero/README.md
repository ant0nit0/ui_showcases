# FlipHero Widget

A powerful and flexible Flutter Hero widget that provides smooth 3D flip animations with customizable background color transitions and overlay opacity control.

## Features

- **3D Flip Animation**: Smooth 3D flip effect during hero transitions
- **Background Color Transitions**: Seamless background color handling
- **Overlay Opacity Control**: Customizable overlay opacity with animation curves
- **Child Visibility Control**: Option to hide/show child during transitions
- **Multiple Usage Patterns**: Direct usage, factory constructors, and extension methods
- **Customizable Animation Curves**: Separate curves for flip and opacity animations
- **Perspective Control**: Adjustable 3D perspective depth

## Basic Usage

### Simple FlipHero

```dart
FlipHero(
  tag: 'my_hero_tag',
  baseColor: Colors.blue,
  child: Container(
    width: 200,
    height: 200,
    child: Text('My Content'),
  ),
)
```

### With Overlay Opacity

```dart
FlipHero(
  tag: 'my_hero_tag',
  baseColor: Colors.green,
  finalOpacityFactor: 0.5, // 50% white overlay
  child: Container(
    width: 200,
    height: 200,
    child: Text('My Content'),
  ),
)
```

## Advanced Usage

### Using Factory Constructors

The `FlipHeroWithStates` class provides convenient factory constructors for common use cases:

```dart
// "From" state (no overlay)
FlipHeroWithStates.from(
  tag: 'hero_tag',
  baseColor: Colors.blue,
  child: MyWidget(),
)

// "To" state (with overlay)
FlipHeroWithStates.to(
  tag: 'hero_tag',
  baseColor: Colors.blue,
  finalOpacityFactor: 0.3,
  child: MyWidget(),
)
```

### Using Extension Methods

Extension methods provide the most convenient way to wrap existing widgets:

```dart
// Basic extension
Container(
  width: 200,
  height: 200,
  child: Text('Content'),
).flipHero(
  tag: 'hero_tag',
  baseColor: Colors.blue,
)

// From state extension
Container(
  width: 200,
  height: 200,
  child: Text('Content'),
).flipHeroFrom(
  tag: 'hero_tag',
  baseColor: Colors.blue,
)

// To state extension
Container(
  width: 200,
  height: 200,
  child: Text('Content'),
).flipHeroTo(
  tag: 'hero_tag',
  baseColor: Colors.blue,
  finalOpacityFactor: 0.4,
)
```

## Configuration Options

### FlipHero Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `tag` | `String` | Required | Hero tag for transitions |
| `child` | `Widget` | Required | Child widget to animate |
| `baseColor` | `Color` | Required | Background color |
| `finalOpacityFactor` | `double` | `0.0` | Final overlay opacity (0.0-1.0) |
| `enableFlip` | `bool` | `true` | Enable/disable flip animation |
| `flipDuration` | `Duration` | `300ms` | Animation duration |
| `perspectiveDepth` | `double` | `0.001` | 3D perspective depth |
| `hideChildDuringTransition` | `bool` | `true` | Hide child during transition |
| `opacityCurve` | `Curve` | `Curves.easeInOut` | Overlay opacity animation curve |
| `flipCurve` | `Curve` | `Curves.easeInOut` | Flip animation curve |

### Animation Curves

You can customize both the flip animation and overlay opacity with different curves:

```dart
FlipHero(
  tag: 'hero_tag',
  baseColor: Colors.blue,
  finalOpacityFactor: 0.5,
  opacityCurve: Curves.bounceOut,    // Bouncy overlay
  flipCurve: Curves.elasticOut,      // Elastic flip
  child: MyWidget(),
)
```

## Complete Example

Here's a complete example showing how to use FlipHero in a navigation scenario:

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlipHero(
          tag: 'hero_card',
          baseColor: Colors.blue,
          child: GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailPage()),
            ),
            child: Container(
              width: 200,
              height: 150,
              child: Center(
                child: Text(
                  'Tap to expand',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class DetailPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FlipHero(
          tag: 'hero_card',
          baseColor: Colors.blue,
          finalOpacityFactor: 0.3,
          child: Container(
            width: double.infinity,
            height: 300,
            child: Center(
              child: Text(
                'Expanded view',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
```

## Best Practices

1. **Consistent Tags**: Always use the same tag for corresponding hero widgets
2. **Appropriate Base Colors**: Choose base colors that work well with your content
3. **Overlay Opacity**: Use subtle overlay values (0.1-0.5) for best visual effect
4. **Performance**: Avoid complex child widgets that might impact animation performance
5. **Accessibility**: Ensure sufficient contrast between content and background colors

## Performance Considerations

- The widget uses `AnimatedBuilder` for efficient rebuilds during animations
- Child visibility can be controlled to reduce rendering overhead during transitions
- Custom curves are applied efficiently using `Curve.transform()`
- The 3D transform matrix is optimized for smooth animations

## Migration from Old Version

If you're migrating from the previous version:

1. Add `baseColor` parameter to all FlipHero widgets
2. Replace `whiteOverlayOpacity` with `finalOpacityFactor` if used
3. Update any custom flight shuttle builders to work with the new structure
4. Consider using the new factory constructors or extension methods for cleaner code

## Troubleshooting

### Common Issues

1. **Child not visible**: Check if `hideChildDuringTransition` is set appropriately
2. **Animation not smooth**: Reduce `perspectiveDepth` or simplify child widgets
3. **Overlay too strong**: Lower `finalOpacityFactor` value
4. **Hero not working**: Ensure both hero widgets have the same tag

### Debug Tips

- Use `enableFlip: false` to test without flip animation
- Set `finalOpacityFactor: 0.0` to test without overlay
- Use `hideChildDuringTransition: false` to keep child visible during transition
