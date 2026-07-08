//
//  DialHandleIcon.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI

/// `CircularRangePicker` 預設使用的圓形控制把手
///
/// `DialHandleIcon` 會將 SF Symbol 包在圓形底座中，讓把手在圓弧上更容易辨識，同時也保有適合拖曳的視覺大小與對比
public struct DialHandleIcon: View {
    
    let kind: Kind
    
    public var body: some View {
        
        Image(systemName: kind.iconName)
            .foregroundStyle(kind.iconColor)
            .padding(10)
            .background {
                Circle()
                    .fill(.white)
                    .shadow(color: .black.opacity(0.12), radius: 4, x: 0, y: 2)
            }
            .overlay {
                Circle()
                    .stroke(.gray.opacity(0.15), lineWidth: 1)
            }
    }
}

// MARK: - enum
extension DialHandleIcon {
    
    /// 把手的視覺樣式
    ///
    /// 不同樣式會對應不同的圖示與顏色，可用來區分區間的起點與終點
    enum Kind {
        
        case moon   // 通常用於表示區間起點的樣式
        case alarm  // 通常用於表示區間終點的樣式
    }
}

// MARK: - 私有屬性
private extension DialHandleIcon.Kind {
    
    /// 各種把手樣式對應的 SF Symbol 名稱
    var iconName: String {
        switch self {
        case .moon: return "moon.fill"
        case .alarm: return "alarm.fill"
        }
    }
    
    /// 各種把手樣式對應的主色
    var iconColor: Color {
        switch self {
        case .moon: return .blue
        case .alarm: return .red
        }
    }
}
