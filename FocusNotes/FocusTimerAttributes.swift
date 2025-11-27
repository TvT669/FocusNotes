//
//  FocusTimerAttributes.swift
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/27.
//

import ActivityKit
import Foundation

public struct FocusTimerAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // 动态数据：倒计时结束的时间点
        public var endTime: Date
    }

    // 静态数据：任务名称
    public var timerName: String
}
