//
//  Constant.swift
//  Example
//
//  Created by William.Weng on 2026/7/7.
//

import Foundation

/// 選區索引類型，表示一組起點與終點 tick 索引 => 用於表示圓盤上被選取的區間範圍，例如從第 3 格到第 7 格
public typealias SelectIndex = (start: Int, end: Int)

/// 表示當前正在操作的起終點把手 => 用於區分拖曳時是調整起點還是終點角度
enum ActiveHandle {
    case start  // 正在操作起點角度（startAngle）
    case end    // 正在操作終點角度（endAngle）
}

