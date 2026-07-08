//
//  Extension.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI

// MARK: - Int
extension Int {
    
    /// 將整數值正規化到 `0 ..< modulus` 的環狀範圍內
    ///
    /// 這個方法可用來避免數值「轉過頭」或落到負數範圍，常見於角度、時間區間、循環索引等需要環狀計算的情境
    ///
    /// 例如：
    /// - `725.normalized(in: 720) == 5`
    /// - `(-10).normalized(in: 720) == 710`
    ///
    /// - Parameter modulus: 環狀範圍的總長度，必須大於 0
    /// - Returns: 正規化後的整數值
    func normalized(in modulus: Int) -> Int {
        precondition(modulus > 0, "modulus must be greater than 0")
        return ((self % modulus) + modulus) % modulus
    }
    
    /// 以 `self` 作為環狀週期，計算從起點前進到終點的距離
    ///
    /// 這個方法可用來處理跨邊界的區間差值，避免結果在超過邊界時變成負數或超出範圍
    ///
    /// 例如當 `self == 720` 時：
    /// - 從 `600` 到 `60` 的距離為 `180`
    /// - 而不是直接相減得到的 `-540`
    ///
    /// - Parameters:
    ///   - start: 起點值
    ///   - end: 終點值
    /// - Returns: 在 `0 ..< self` 範圍內的環狀距離
    func circularDistance(from start: Int, to end: Int) -> Int {
        let delta = end - start
        return delta.normalized(in: self)
    }
    
    /// 將分鐘值格式化為 12 小時制時間字串
    ///
    /// 例如：
    /// - `85.formatted12Hour()` 會得到 `"1:25 AM"`
    /// - `755.formatted12Hour()` 會得到 `"12:35 PM"`
    ///
    /// - Parameter totalMinutes: 環狀時間範圍的總分鐘數，預設為 12 小時
    /// - Returns: 12 小時制格式的時間字串
    func formatted12Hour(totalMinutes: Int = 12 * 60) -> String {
        
        let normalized = normalized(in: totalMinutes)
        let hour24 = normalized / 60
        let minute = normalized % 60
        let ampm = hour24 < 12 ? "AM" : "PM"
        let hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12
        
        return String(format: "%d:%02d %@", hour12, minute, ampm)
    }
}

// MARK: - CGRect
extension CGRect {
    
    /// 矩形的中心點
    var center: CGPoint {
        CGPoint(x: midX, y: midY)
    }
    
    /// 可完整內切於此矩形的圓形半徑
    ///
    /// 這個值以矩形較短邊的一半為準，可用來建立剛好能放入此矩形的最大圓
    var inscribedCircleRadius: CGFloat {
        min(width, height) * 0.5
    }
}

// MARK: - CGPoint
extension CGPoint {
    
    /// 以 `self` 為圓心，計算指向指定座標的「時鐘角度」
    ///
    /// 這個角度系統是為了圓形時間選擇器設計的：
    /// - 12 點鐘方向為 0°
    /// - 角度範圍固定為 0°...360°
    ///
    /// 內部做法是先用 `atan2` 計算向量角度，再把數學座標系的基準軸轉成 UI 較直覺的時鐘方向
    ///
    /// - Parameter location: 使用者目前拖曳到的位置，通常是手指或 handle 的座標
    /// - Returns: 以 12 點鐘方向為起點的角度值
    func clockAngle(to location: CGPoint) -> Angle {
        
        let dx = location.x - x
        let dy = location.y - y
        
        var degrees = atan2(dy, dx) * 180 / .pi
        degrees += 90

        if degrees < 0 { degrees += 360 }
        
        return .degrees(degrees)
    }
    
    /// 計算「當前點」到「另一個點」的直線距離（歐式距離）
    ///
    /// hypot(dx, dy) = √(dx² + dy²)
    func distance(to otherPoint: CGPoint) -> CGFloat {
        hypot(x - otherPoint.x, y - otherPoint.y)
    }
}

// MARK: - Angle
extension Angle {
    
    /// 將分鐘值映射為圓形控制項上的角度
    ///
    /// 例如：當整圈代表 720 分鐘時，180 分鐘會對應到 90°，也就是四分之一圈
    ///
    /// - Parameters:
    ///   - minutes: 目前的分鐘值
    ///   - totalMinutes: 整個圓周代表的總分鐘數
    /// - Returns: 對應的時鐘角度
    static func clockAngle(for minutes: Int, totalMinutes: Int) -> Angle {
        .degrees((Double(minutes) / Double(totalMinutes)) * 360.0)
    }
}

// MARK: - Angle
extension Angle {
    
    /// 0° ..< 360°
    var normalized: Angle {
        let value = (degrees.truncatingRemainder(dividingBy: 360) + 360).truncatingRemainder(dividingBy: 360)
        return .degrees(value)
    }
    
    /// -180° ..< 180°
    var signedNormalized: Angle {
        let value = normalized.degrees
        return value >= 180 ? .degrees(value - 360) : .degrees(value)
    }
}

// MARK: - Angle
extension Angle {
    
    /// 將目前角度轉換為圓周上的座標點
    ///
    /// 這個方法會把時鐘角度系統 (12 點方向 = 0°)，轉換成三角函數使用的標準座標系 (3 點方向作為 0°)，再計算對應的圓周位置
    ///
    /// - Parameters:
    ///   - center: 圓心位置
    ///   - radius: 圓的半徑
    /// - Returns: 對應於此角度的圓周座標
    func point(center: CGPoint, radius: CGFloat) -> CGPoint {
        
        let radians = (degrees - 90) * .pi / 180
        
        return .init(
            x: center.x + CGFloat(Darwin.cos(radians)) * radius,
            y: center.y + CGFloat(Darwin.sin(radians)) * radius
        )
    }
    
    /// 將目前角度轉換為吸附後的分鐘值
    ///
    /// 這個方法會先依整圈對應的總分鐘數，將角度換算成分鐘，再依指定的步進值進行吸附，例如每 5 分鐘或每 15 分鐘一格
    /// 最後會把結果正規化到合法的環狀範圍內，避免分鐘值超出一圈或落入負值區間
    ///
    /// - Parameters:
    ///   - stepMinutes: 吸附的步進單位，必須大於 0
    ///   - totalMinutes: 整個圓周代表的總分鐘數，必須大於 0
    /// - Returns: 吸附並正規化後的分鐘值
    func snappedMinutes(stepMinutes: Int, totalMinutes: Int) -> Int {
        
        precondition(stepMinutes > 0, "stepMinutes must be greater than 0")
        precondition(totalMinutes > 0, "totalMinutes must be greater than 0")
        
        let rawMinutes = Int(round((degrees / 360.0) * Double(totalMinutes)))
        let snapped = Int(round(Double(rawMinutes) / Double(stepMinutes))) * stepMinutes
        
        return snapped.normalized(in: totalMinutes)
    }
    
    /// 先正規化再吸附，適合 UI 顯示值
    func normalizedAndSnapped(step: Double) -> Angle {
        normalized.snapped(step: step)
    }
    
    /// 為了動畫連續性，回傳最接近 current 的等價角度
    /// 例如 current = 350, target = 10，會回傳 370 而不是 10
    func unwrapped(closestTo current: Angle) -> Angle {
        current + current.shortestDelta(to: self)
    }
}

// MARK: - Angle
private extension Angle {
    
    /// 吸附到最近刻度，例如 10°, 5°
    func snapped(step: Double) -> Angle {
        guard step != 0 else { return self }
        let snapped = (degrees / step).rounded() * step
        return .degrees(snapped)
    }
    
    /// 沿最短路徑前進後的新角度
    func advancedToward(_ target: Angle) -> Angle {
        self + shortestDelta(to: target)
    }
    
    /// self 到 target 的最短角度差，結果落在 -180° ..< 180°
    func shortestDelta(to target: Angle) -> Angle {
        (target - self).signedNormalized
    }
}
