//
//  WWCircularRangePicker.swift
//  WWCircularRangePicker
//
//  Created by William.Weng on 2026/7/7.
//
/// https://www.youtube.com/watch?v=Uaa9sgDhbxc

import SwiftUI

public struct WWCircularRangePickerUI<StartView: View, EndView: View>: View {
        
    @Binding private var startAngle: Angle
    @Binding private var endAngle: Angle
    
    @State private var displayStartAngle: Angle
    @State private var displayEndAngle: Angle
    @State private var activeHandle: ActiveHandle?
    
    private let startView: StartView
    private let endView: EndView
    private let selectIndexClosure: (SelectIndex) -> Void
    
    private let configure: Configure
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            let rect = CGRect(origin: .zero, size: proxy.size)
            let center = rect.center
            let radius = rect.inscribedCircleRadius
            
            let startPoint = displayStartAngle.point(center: center, radius: radius)
            let endPoint = displayEndAngle.point(center: center, radius: radius)
            
            ZStack {
                
                DialTicksLayer(center: center, radius: radius, totalTickCount: configure.tickCount, majorTickStride: configure.tickStride)
                
                Circle()
                    .stroke(configure.innerColor, lineWidth: configure.lineWidth)
                
                RangeArcShape(startAngle: displayStartAngle, endAngle: displayEndAngle)
                    .stroke(
                        configure.outerColor,
                        style: .init(lineWidth: configure.lineWidth, lineCap: .round, lineJoin: .round)
                    )
                
                startView
                    .position(startPoint)
                
                endView
                    .position(endPoint)
            }
            .contentShape(Rectangle())
            .gesture(dragGesture(center: center, startPoint: startPoint, endPoint: endPoint))
            .onAppear {
                selectIndexClosure(calculateSelectIndex())
            }
        }
        .onChange(of: startAngle) { _, newValue in
            displayStartAngle = newValue.unwrapped(closestTo: displayStartAngle)
            selectIndexClosure(calculateSelectIndex())
        }
        .onChange(of: endAngle) { _, newValue in
            displayEndAngle = newValue.unwrapped(closestTo: displayEndAngle)
            selectIndexClosure(calculateSelectIndex())
        }
        .aspectRatio(1, contentMode: .fit)
    }
    
    /// 初始化 `WWCircularRangePicker`
    ///
    /// 將入參的 `startAngle` 和 `endAngle` 正規化到 0..<360°，並設定內部使用的 binding 與顯示狀態
    /// 初始選區會在 View 出現在畫面上時，透過 `.onAppear` 回傳給 `selectIndexClosure`。
    ///
    /// - Parameters:
    ///   - configure: 配置（包含 `stepAngle`、`tickCount` 等）
    ///   - startAngle: 起點角度的 `Binding<Angle>`
    ///   - endAngle: 終點角度的 `Binding<Angle>`
    ///   - startView: 起點View（例如用於標記或標籤）
    ///   - endView: 終點View
    ///   - selectIndexClosure: 當選區更新時被呼叫的 closure，回傳 `(startIndex, endIndex)`
    public init(configure: Configure, startAngle: Binding<Angle>, endAngle: Binding<Angle>, startView: StartView, endView: EndView, selectIndexClosure: @escaping (SelectIndex) -> Void) {
        
        let start = startAngle.wrappedValue.normalized
        let end = endAngle.wrappedValue.normalized
        
        _startAngle = startAngle
        _endAngle = endAngle
        _displayStartAngle = State(initialValue: start)
        _displayEndAngle = State(initialValue: end)
        
        self.configure = configure
        self.startView = startView
        self.endView = endView
        self.selectIndexClosure = selectIndexClosure
    }
}

// MARK: - 公開API
extension WWCircularRangePickerUI where StartView == DialHandleIcon, EndView == DialHandleIcon {
    
    /// 快速初始化 `SelectingView`
    ///
    /// 將入參的 `startAngle` 和 `endAngle` 正規化到 0..<360°，並設定內部 state 與計算初始選區，立即呼叫 `selectIndexClosure` 回傳第一組 index
    ///
    /// - Parameters:
    ///   - startAngle: 起點角度的 `Binding<Angle>`
    ///   - endAngle: 終點角度的 `Binding<Angle>`
    ///   - selectIndexClosure: 當選區更新時被呼叫的 closure，回傳 `(startIndex, endIndex)`
    public init(startAngle: Binding<Angle>, endAngle: Binding<Angle>, selectIndexClosure: @escaping (SelectIndex) -> Void) {
        
        let configure: Configure = .init(lineWidth: 44, innerColor: .gray.opacity(0.2), outerColor: .yellow.opacity(0.5), tickCount: 72, tickStride: 6)
        
        self.init(configure: configure, startAngle: startAngle, endAngle: endAngle, startView: DialHandleIcon(kind: .moon), endView: DialHandleIcon(kind: .alarm), selectIndexClosure: selectIndexClosure)
    }
}

// MARK: - 私有API
private extension WWCircularRangePickerUI {
    
    /// 建立拖曳手勢
    ///
    /// 手勢本身只負責事件分派：
    /// - 拖曳過程交給 `dragGestureOnChangedValue`
    /// - 手勢結束交給 `dragGestureOnEnded`
    ///
    /// 這樣可以讓 gesture 宣告維持精簡，也比較方便個別測試與調整行為
    ///
    /// - Parameters:
    ///   - center: 圓心位置
    ///   - startPoint: start handle 目前在畫面上的位置
    ///   - endPoint: end handle 目前在畫面上的位置
    /// - Returns: 綁定在元件上的拖曳手勢
    func dragGesture(center: CGPoint, startPoint: CGPoint, endPoint: CGPoint) -> some Gesture {
        
        DragGesture(minimumDistance: 0)
            .onChanged {
                dragGestureOnChangedValue($0, center: center, startPoint: startPoint, endPoint: endPoint)
            }.onEnded { _ in
                dragGestureOnEnded()
            }
    }
    
    /// 處理拖曳中的更新邏輯
    ///
    /// 流程分成三步：
    /// 1. 先把手指位置換算成圓上的角度
    /// 2. 第一次拖曳時決定目前正在操作哪一個 handle
    /// 3. 更新邏輯角度與顯示角度
    ///
    /// `startAngle` / `endAngle` 是邏輯值，會維持在正規化範圍內；`displayStartAngle` / `displayEndAngle` 是給動畫與繪圖用的顯示值，允許出現超過 360 或小於 0 的連續角度，避免跨過 0° / 360° 時走遠路
    ///
    /// - Parameters:
    ///   - value: DragGesture 當前事件值
    ///   - center: 圓心位置
    ///   - startPoint: start handle 目前在畫面上的位置
    ///   - endPoint: end handle 目前在畫面上的位置
    func dragGestureOnChangedValue(_ value: DragGesture.Value, center: CGPoint, startPoint: CGPoint, endPoint: CGPoint) {
        
        let location = value.location
        let angle = center.clockAngle(to: location)
        
        if activeHandle == nil {
            activeHandle = nearestHandle(to: location, startPoint: startPoint, endPoint: endPoint, hitRadius: 44)
        }
        
        guard let activeHandle else { return }
        
        switch activeHandle {
        case .start:
            startAngle = angle.normalized
            displayStartAngle = angle.unwrapped(closestTo: displayStartAngle)
            
        case .end:
            endAngle = angle.normalized
            displayEndAngle = angle.unwrapped(closestTo: displayEndAngle)
        }
    }
    
    /// 處理拖曳結束後的收尾邏輯
    ///
    /// 目前收尾動作包含：
    /// - 將角度吸附到最近的刻度
    /// - 以 spring 動畫更新顯示角度
    /// - 清除目前作用中的 handle
    ///
    /// 這裡同時維持兩套值：
    /// - 邏輯值：吸附後的正規化角度
    /// - 顯示值：以最接近目前顯示狀態的等價角度收尾，避免動畫倒轉一大圈
    func dragGestureOnEnded() {
        
        let handle = activeHandle
        let step = configure.stepAngle
        
        withAnimation(.spring(response: 0.25, dampingFraction: 0.85)) {
            
            switch handle {
            case .start:
                let snapped = startAngle.normalizedAndSnapped(step: step)
                startAngle = snapped
                displayStartAngle = snapped.unwrapped(closestTo: displayStartAngle)
                
            case .end:
                let snapped = endAngle.normalizedAndSnapped(step: step)
                endAngle = snapped
                displayEndAngle = snapped.unwrapped(closestTo: displayEndAngle)
                
            case nil:
                break
            }
            
            activeHandle = nil
        }
    }
    
    /// 依照手指按下的位置，判斷目前要操作哪一個 handle
    /// - Parameters:
    ///   - location: 手指目前按下的位置
    ///   - startPoint: start handle 在畫面上的位置
    ///   - endPoint: end handle 在畫面上的位置
    ///   - hitRadius: handle 的可點擊半徑；若手指落點超出兩者範圍，回傳 nil
    /// - Returns:
    ///   - `.start`：手指有點中，且比較靠近 start handle
    ///   - `.end`：手指有點中，且比較靠近 end handle
    ///   - `nil`：手指沒有點進任何 handle 的可操作範圍
    func nearestHandle(to location: CGPoint, startPoint: CGPoint, endPoint: CGPoint, hitRadius: CGFloat) -> ActiveHandle? {
        
        let startDistance = location.distance(to: startPoint)
        let endDistance = location.distance(to: endPoint)
        
        guard startDistance <= hitRadius || endDistance <= hitRadius else { return nil }
        return startDistance < endDistance ? .start : .end
    }
    
    /// 將起終點角度換算成對應的 index 範圍
    ///
    /// 使用四捨五入 (`rounded()`) 來選「最近的扇形」，並透過 `rounded % tickCount` 確保結果在 0..<tickCount 範圍內
    ///
    /// - Returns: (startIndex, endIndex)，分別為起點與終點角度對應的 tick 索引
    func calculateSelectIndex() -> SelectIndex {
        
        let stepAngle = configure.stepAngle
        
        func index(for angle: Angle) -> Int {
            let raw = angle.normalized.degrees / stepAngle
            let rounded = Int(raw.rounded())
            return rounded % configure.tickCount
        }
        
        return (index(for: startAngle), index(for: endAngle))
    }
}

//#Preview {
//    
//    @Previewable @State var startAngle: Angle = .degrees(0)
//    @Previewable @State var endAngle: Angle = .degrees(90)
//    
//    WWCircularRangePicker(startAngle: $startAngle, endAngle: $endAngle) { startIndex, endIndex in
//        print("\(startIndex), \(endIndex)")
//    }.padding()
//}

