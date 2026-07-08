//
//  RangeArcShape.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI

/// 用來繪製選取區間弧線的 Shape
///
/// 透過 `startAngle` 和 `endAngle` 定義弧線的起點與終點，並使用 `animatableData` 讓這兩個角度在變化時可以平滑動畫
struct RangeArcShape: Shape {
    
    var startAngle: Angle   // 弧線起始角度
    var endAngle: Angle     // 弧線結束角度
    
    /// 提供 SwiftUI 動畫系統使用的可動畫資料 (for Animatable)
    var animatableData: AnimatablePair<Double, Double> {
        get { AnimatablePair(startAngle.degrees, endAngle.degrees) }
        set {
            startAngle = .degrees(newValue.first)
            endAngle = .degrees(newValue.second)
        }
    }

    /// 產生圓弧路徑
    ///
    /// 這個方法會根據起始角度與結束角度，在指定的矩形範圍內繪製一段圓弧
    ///
    /// 角度系統以 12 點鐘方向作為 0°，因此在轉成 `addArc` 所使用的座標系時，需要先減去 90° 進行方向校正
    ///
    /// - Parameter rect: 圖形繪製所使用的矩形範圍
    /// - Returns: 對應起始角度與結束角度的圓弧路徑
    func path(in rect: CGRect) -> Path {
        
        let center = rect.center
        let radius = rect.inscribedCircleRadius
        
        let start = startAngle.degrees - 90
        var end = endAngle.degrees - 90

        if end < start { end += 360 }
        
        var path = Path()
        path.addArc(center: center, radius: radius, startAngle: .degrees(start), endAngle: .degrees(end), clockwise: false)
        
        return path
    }
}
