//
//  DialTicksLayer.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI

/// 繪製圓形刻度線圖層
///
/// 這個元件會依照指定的刻度總數，在圓周上平均繪製刻度線，並支援以固定間隔標示主要刻度與次要刻度的不同樣式
public struct DialTicksLayer: View {
    
    let center: CGPoint
    let radius: CGFloat
    let totalTickCount: Int
    let majorTickStride: Int
    let majorStyle: DialTickStyle
    let minorStyle: DialTickStyle

    /// 建立一個圓形刻度線圖層
    ///
    /// - Parameters:
    ///   - center: 圓心位置
    ///   - radius: 圓周半徑
    ///   - totalTickCount: 總刻度數量，預設為 `60`
    ///   - majorTickStride: 主要刻度的間隔，預設為 `5`
    ///   - majorStyle: 主要刻度樣式
    ///   - minorStyle: 次要刻度樣式
    public init(center: CGPoint, radius: CGFloat, totalTickCount: Int = 60, majorTickStride: Int = 5, majorStyle: DialTickStyle = .init(inset: 8.0, outset: 0.0, lineWidth: 2.0, lineColor: .primary.opacity(0.55)), minorStyle: DialTickStyle = .init(inset: 4.0, outset: 2.0, lineWidth: 1.0, lineColor: .primary.opacity(0.22))) {
        self.center = center
        self.radius = radius
        self.totalTickCount = totalTickCount
        self.majorTickStride = majorTickStride
        self.majorStyle = majorStyle
        self.minorStyle = minorStyle
    }
    
    public var body: some View {
        
        ZStack {
            ForEach(0..<totalTickCount, id: \.self) { index in
                tickView(at: index, totalTickCount: totalTickCount, majorTickStride: majorTickStride)
            }
        }
    }
}

// MARK: - 私有API
private extension DialTicksLayer {
    
    /// 建立指定索引的刻度線視圖
    ///
    /// 這個方法會依索引判斷目前刻度是否為主要刻度，並根據對應樣式計算刻度線的起點、終點與外觀
    ///
    /// - Parameters:
    ///   - index: 目前刻度索引
    ///   - totalTickCount: 總刻度數量
    ///   - majorTickStride: 主要刻度的間隔
    /// - Returns: 對應索引的刻度線視圖
    func tickView(at index: Int, totalTickCount: Int, majorTickStride: Int) -> some View {
        
        let isMajor = index % majorTickStride == 0
        let angle = Double(index) / Double(totalTickCount) * 360
        
        let r1 = radius - (isMajor ? majorStyle.inset : minorStyle.inset)
        let p1 = Angle.degrees(angle).point(center: center, radius: r1)
        
        let r2 = radius + (isMajor ? majorStyle.outset : minorStyle.outset)
        let p2 = Angle.degrees(angle).point(center: center, radius: r2)
        
        return Path { path in
            path.move(to: p1)
            path.addLine(to: p2)
        }
        .stroke(
            isMajor ? majorStyle.lineColor : minorStyle.lineColor,
            lineWidth: isMajor ? majorStyle.lineWidth : minorStyle.lineWidth
        )
    }
}

#Preview {
    DialTicksLayer(center: .init(x: 180, y: 180), radius: 156)
        .padding()
}
