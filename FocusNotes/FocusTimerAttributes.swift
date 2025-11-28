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
        // 【新增】开始时间，用于计算进度
        public var startTime: Date
        // 【新增】总时长（秒），用于计算进度
        public var totalDuration: TimeInterval
    }

    // 静态数据：任务名称 (已删除)
}
