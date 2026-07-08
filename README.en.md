[English](./README.en.md) | [繁體中文](./README.md)

# [WWCircularRangePickerUI](https://swiftpackageindex.com/William-Weng)

A circular range picker built with [SwiftUI](https://www.youtube.com/watch?v=Uaa9sgDhbxc). It lets you select a start angle and an end angle on a dial, then converts that selection into a `(start, end)` index range through a simple callback.

[![Swift-5.10+](https://img.shields.io/badge/Swift-5.10+-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0+](https://img.shields.io/badge/iOS-17.0+-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWCircularRangePickerUI)
![SwiftUI](https://img.shields.io/badge/SwiftUI-supported-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

## ✨ [Features](https://peterpanswift.github.io/iphone-bezels/)

- Circular range selection with two draggable handles.
- Built with pure SwiftUI.
- Supports custom start / end handle views.
- Provides default handle icons for quick integration.
- Emits selected tick indexes using a closure.
- Handles negative angles, 360-degree wrapping, and normalized angle display.
- Supports animated arc updates with `Shape` + `AnimatablePair`.

## 📦 [Installation](https://www.youtube.com/watch?v=Uaa9sgDhbxc)
### Swift Package Manager

Add the package to your project in Xcode:

1. Open your project in Xcode.
2. Select **File > Add Package Dependencies...**
3. Paste the repository URL.
4. Add `WWCircularRangePickerUI` to your target.

## 🚀 Basic Usage

```swift
import SwiftUI
import WWCircularRangePickerUI

struct ContentView: View {
    
    @State private var startAngle: Angle = .degrees(0)
    @State private var endAngle: Angle = .degrees(90)
    @State private var timeRangeText: String = ""
    
    var body: some View {
        
        ZStack {
            
            Text(timeRangeText)
                .font(.title)
            
            WWCircularRangePickerUI(startAngle: $startAngle, endAngle: $endAngle) {
                updateText(from: $0, to: $1)
            }
            .padding()
        }
        .padding()
    }
}

private extension ContentView {
    
    func calculateTime(at index: Int) -> String {
        let totalMinutes = 10 * index
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        return String(format: "%02d:%02d", hour, minute)
    }
    
    func updateText(from startIndex: Int, to endIndex: Int) {
        let startTime = calculateTime(at: startIndex)
        let endTime = calculateTime(at: endIndex)
        timeRangeText = "\(startTime) ~ \(endTime)"
    }
}
```

## 🔁 Callback

The picker returns the selected range as a tuple:

```swift
public typealias SelectIndex = (start: Int, end: Int)
```

Example:

```swift
WWCircularRangePickerUI(startAngle: $startAngle, endAngle: $endAngle) { startIndex, endIndex in
    print(startIndex, endIndex)
}
```

## 🪄 Default Initializer

Use the built-in handle views for a quick start:

```swift
WWCircularRangePickerUI(
    startAngle: $startAngle,
    endAngle: $endAngle
) { startIndex, endIndex in
    print(startIndex, endIndex)
}
```

This initializer uses a default configuration similar to:

```swift
Configure(
    lineWidth: 44,
    innerColor: .gray.opacity(0.2),
    outerColor: .yellow.opacity(0.5),
    tickCount: 72,
    tickStride: 6
)
```

## 🎛️ Custom Handles

You can provide custom views for the start and end handles:

```swift
WWCircularRangePickerUI(
    configure: configure,
    startAngle: $startAngle,
    endAngle: $endAngle,
    startView: Image(systemName: "moon.fill"),
    endView: Image(systemName: "alarm.fill")
) { startIndex, endIndex in
    print(startIndex, endIndex)
}
```

## ⚙️ Configuration

The picker is configured through `Configure`.

```swift
let configure = WWCircularRangePickerUI<EmptyView, EmptyView>.Configure(
    lineWidth: 44,
    innerColor: .gray.opacity(0.2),
    outerColor: .yellow.opacity(0.5),
    tickCount: 72,
    tickStride: 6
)
```

### Common Parameters

- `lineWidth`: Stroke width of the circular track.
- `innerColor`: Base ring color.
- `outerColor`: Selected range color.
- `tickCount`: Total number of ticks on the dial.
- `tickStride`: Interval for major ticks.
- `stepAngle`: Angle per tick, usually derived from `tickCount`.

## 🧭 Angle Behavior

The picker is designed for circular interaction, so angle handling matters.

- Angles are normalized into `0..<360`.
- Negative angles are supported.
- Values larger than `360` are wrapped back into the dial.
- Selected indexes can be calculated by rounding to the nearest tick.
- Initial callback is best triggered from `.onAppear`, not from `init`.

## ⚠️ Notes

- `onAppear` is a better place than `init` for the first callback because SwiftUI view initializers should avoid side effects.
- `onChange` can be used to observe later updates to `startAngle` and `endAngle`.
- If you map each tick to time, keep the conversion logic outside the picker so the component stays reusable.

## ⏱️ Example: Time Range Picker

If one tick equals 10 minutes, you can convert the selected indexes into a readable time range:

```swift
func calculateTime(at index: Int) -> String {
    let totalMinutes = 10 * index
    let hour = totalMinutes / 60
    let minute = totalMinutes % 60
    return String(format: "%02d:%02d", hour, minute)
}
```

Then combine it with the callback:

```swift
func updateText(from startIndex: Int, to endIndex: Int) {
    let startTime = calculateTime(at: startIndex)
    let endTime = calculateTime(at: endIndex)
    timeRangeText = "\(startTime) ~ \(endTime)"
}
```

## 👀 Preview

```swift
#Preview {
    ContentView()
}
```
