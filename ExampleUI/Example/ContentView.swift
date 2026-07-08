//
//  ContentView.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import SwiftUI
import WWCircularRangePickerUI

struct ContentView: View {
    
    @State private var startAngle: Angle = .degrees(0)
    @State private var endAngle: Angle = .degrees(90)
    @State private var timeRangeText: String = "00:00 ~ 03:00"
    
    var body: some View {
        
        ZStack {
            
            Text(timeRangeText)
                .font(.title)
            
            WWCircularRangePickerUI(startAngle: $startAngle, endAngle: $endAngle) {
                updateText(from: $0, to: $1)
            }.padding()
        }
        .padding()
    }
}

// MARK: - 私有API
private extension ContentView {
    
    /// 將 index 換算成 HH:mm 格式的時間字串
    ///
    /// 每個 index 代表 10 分鐘，例如：
    /// - 0   -> 00:00
    /// - 1   -> 00:10
    /// - 55  -> 09:10
    ///
    /// - Parameter index: 刻度索引
    /// - Returns: HH:mm 格式字串
    func calculateTime(at index: Int) -> String {
        
        let totalMinutes = 10 * index
        let hour = totalMinutes / 60
        let minute = totalMinutes % 60
        
        return String(format: "%02d:%02d", hour, minute)
    }
    
    /// 根據起終點 index 更新畫面上的時間區間文字
    ///
    /// - Parameters:
    ///   - startIndex: 起點刻度索引
    ///   - endIndex: 終點刻度索引
    func updateText(from startIndex: Int, to endIndex: Int) {
        
        let startTime = calculateTime(at: startIndex)
        let endTime = calculateTime(at: endIndex)
        
        timeRangeText = "\(startTime) ~ \(endTime)"
    }
}

#Preview {
    ContentView()
}

