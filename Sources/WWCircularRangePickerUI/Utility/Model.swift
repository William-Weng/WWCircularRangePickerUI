//
//  Model.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI

/// 定義圓形刻度線的樣式
///
/// 這個型別用來描述單一刻度線的幾何與視覺屬性，包含刻度線相對圓周的內縮與外凸距離、線寬，以及顏色
public struct DialTickStyle {
    
    let inset: CGFloat
    let outset: CGFloat
    let lineWidth: CGFloat
    let lineColor: Color
    
    /// 建立一組刻度線樣式
    ///
    /// - Parameters:
    ///   - inset: 刻度線往內縮的距離
    ///   - outset: 刻度線往外延伸的距離
    ///   - lineWidth: 刻度線的粗細
    ///   - lineColor: 刻度線的顏色
    public init(inset: CGFloat, outset: CGFloat, lineWidth: CGFloat, lineColor: Color) {
        self.inset = inset
        self.outset = outset
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
}

public struct Configure {
    
    let lineWidth: CGFloat
    let innerColor: Color
    let outerColor: Color
    let tickCount: Int
    let tickStride: Int
    
    public init(lineWidth: CGFloat, innerColor: Color, outerColor: Color, tickCount: Int, tickStride: Int) {
        self.lineWidth = lineWidth
        self.innerColor = innerColor
        self.outerColor = outerColor
        self.tickCount = tickCount
        self.tickStride = tickStride
    }
}

extension Configure {
    
    var stepAngle: Double {
        360.0 / Double(tickCount)
    }
}
