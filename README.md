[English](./README.en.md) | [繁體中文](./README.md)

# [WWCircularRangePickerUI](https://swiftpackageindex.com/William-Weng)

一個使用 SwiftUI 製作的[圓形區間選擇器](https://www.youtube.com/watch?v=Uaa9sgDhbxc)。你可以在圓盤上選取起始角度與結束角度，並透過 callback 取得對應的 `(start, end)` index 範圍。

[![Swift-5.10+](https://img.shields.io/badge/Swift-5.10+-orange.svg)](https://developer.apple.com/swift/)
[![iOS-17.0+](https://img.shields.io/badge/iOS-17.0+-pink.svg?style=flat)](https://developer.apple.com/swift/)
![TAG](https://img.shields.io/github/v/tag/William-Weng/WWCircularRangePickerUI)
![SwiftUI](https://img.shields.io/badge/SwiftUI-supported-green.svg)
![SPM](https://img.shields.io/badge/SPM-supported-brightgreen.svg)
[![LICENSE](https://img.shields.io/badge/LICENSE-MIT-yellow.svg?style=flat)](https://developer.apple.com/swift/)

https://github.com/user-attachments/assets/735cc004-af99-4fb2-b60b-d21bfe5a4766

## ✨ [功能特色](https://peterpanswift.github.io/iphone-bezels/)

- 支援雙把手的圓形區間選擇。
- 使用純 SwiftUI 實作。
- 支援自訂起點與終點把手視圖。
- 提供預設把手圖示，方便快速整合。
- 透過 closure 回傳選取的 tick index。
- 支援負角度、360 度循環與正規化顯示。
- 選取弧線支援 `Shape` + `AnimatablePair` 動畫。

## 📦 安裝方式

### Swift Package Manager

在 Xcode 中加入套件：

1. 打開你的專案。
2. 選擇 **File > Add Package Dependencies...**。
3. 貼上 repository URL。
4. 將 `WWCircularRangePickerUI` 加入你的 target。

## 🚀 基本用法

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

🔁 回傳值

選擇器會以 tuple 的方式回傳選取範圍：

```swift
public typealias SelectIndex = (start: Int, end: Int)
```

使用方式如下：

```swift
WWCircularRangePickerUI(startAngle: $startAngle, endAngle: $endAngle) { startIndex, endIndex in
    print(startIndex, endIndex)
}
```

🪄 預設初始化

如果你想快速開始，可以直接使用內建的把手視圖：

```swift
WWCircularRangePickerUI(
    startAngle: $startAngle,
    endAngle: $endAngle
) { startIndex, endIndex in
    print(startIndex, endIndex)
}
```

這個初始化器使用的預設配置大致如下：

```swift
Configure(
    lineWidth: 44,
    innerColor: .gray.opacity(0.2),
    outerColor: .yellow.opacity(0.5),
    tickCount: 72,
    tickStride: 6
)
```

🎛️ 客製化把手

你可以自訂起點與終點把手視圖：

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

⚙️ 配置說明

選擇器透過 `Configure` 進行設定。

```swift
let configure = WWCircularRangePickerUI<EmptyView, EmptyView>.Configure(
    lineWidth: 44,
    innerColor: .gray.opacity(0.2),
    outerColor: .yellow.opacity(0.5),
    tickCount: 72,
    tickStride: 6
)
```

### 常用參數

- `lineWidth`：圓弧線寬度。
- `innerColor`：底層圓環顏色。
- `outerColor`：選取區間顏色。
- `tickCount`：圓盤總刻度數。
- `tickStride`：主要刻度間距。
- `stepAngle`：每個刻度對應的角度，通常由 `tickCount` 推導。

🧭 角度行為

這個元件是以圓形互動為核心，所以角度處理很重要。

- 角度會被正規化到 `0..<360`。
- 支援負角度。
- 超過 `360` 的值會自動循環回圓盤內。
- 選取 index 可以透過四捨五入對應到最近的刻度。
- 初始 callback 建議在 `.onAppear` 中觸發，而不是在 `init` 中執行。

⚠️ 注意事項

- `onAppear` 比 `init` 更適合處理第一次 callback，因為 SwiftUI 的 View initializer 應盡量避免 side effect。
- `onChange` 可以用來監聽 `startAngle` 和 `endAngle` 的後續變動。
- 如果你要把每個 tick 對應成時間，建議把轉換邏輯放在元件外部，讓 picker 保持可重用性。

⏱️ 時間範例

如果每個 tick 代表 10 分鐘，你可以把 index 轉成可讀時間字串：

```swift
func calculateTime(at index: Int) -> String {
    let totalMinutes = 10 * index
    let hour = totalMinutes / 60
    let minute = totalMinutes % 60
    return String(format: "%02d:%02d", hour, minute)
}
```

再搭配 callback 組合成區間文字：

```swift
func updateText(from startIndex: Int, to endIndex: Int) {
    let startTime = calculateTime(at: startIndex)
    let endTime = calculateTime(at: endIndex)
    timeRangeText = "\(startTime) ~ \(endTime)"
}
```

👀 預覽

```swift
#Preview {
    ContentView()
}
```
