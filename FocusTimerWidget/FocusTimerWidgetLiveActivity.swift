//
//  FocusTimerWidgetLiveActivity.swift
//  FocusTimerWidget
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/27.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FocusTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            // --- 1. 锁屏界面 UI ---
            VStack {
                Text("专注中: \(context.attributes.timerName)")
                    .font(.headline)
                    .foregroundColor(.white)
                
                // style: .timer 是系统自动倒计时的关键，不需要每秒刷新
                Text(context.state.endTime, style: .timer)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255)) // 珊瑚粉
            }
            .padding()
            .activityBackgroundTint(Color(red: 74/255, green: 64/255, blue: 58/255)) // 咖啡色背景
            
        } dynamicIsland: { context in
            // --- 2. 灵动岛 UI ---
            DynamicIsland {
                // A. 展开区域 (长按灵动岛)
                DynamicIslandExpandedRegion(.leading) {
                    Image(systemName: "timer")
                        .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255))
                        .font(.title)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endTime, style: .timer)
                        .font(.title)
                        .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255))
                        .monospacedDigit()
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text(context.attributes.timerName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.bottom, 8)
                }
            } compactLeading: {
                // B. 收起状态左侧
                Image(systemName: "timer")
                    .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255))
            } compactTrailing: {
                // C. 收起状态右侧 (倒计时)
                Text(context.state.endTime, style: .timer)
                    .monospacedDigit()
                    .frame(width: 45)
                    .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255))
            } minimal: {
                // D. 最小化状态
                Image(systemName: "timer")
                    .foregroundColor(Color(red: 255/255, green: 140/255, blue: 148/255))
            }
        }
    }
}

// MARK: - Previews

extension FocusTimerAttributes {
    fileprivate static var preview: FocusTimerAttributes {
        FocusTimerAttributes(timerName: "番茄专注")
    }
}

extension FocusTimerAttributes.ContentState {
    fileprivate static var timerRunning: FocusTimerAttributes.ContentState {
        FocusTimerAttributes.ContentState(endTime: Date().addingTimeInterval(25 * 60))
    }
}

#Preview("Lock Screen", as: .content, using: FocusTimerAttributes.preview) {
   FocusTimerWidgetLiveActivity()
} contentStates: {
    FocusTimerAttributes.ContentState.timerRunning
}

#Preview("Dynamic Island Expanded", as: .dynamicIsland(.expanded), using: FocusTimerAttributes.preview) {
   FocusTimerWidgetLiveActivity()
} contentStates: {
    FocusTimerAttributes.ContentState.timerRunning
}

#Preview("Dynamic Island Compact", as: .dynamicIsland(.compact), using: FocusTimerAttributes.preview) {
   FocusTimerWidgetLiveActivity()
} contentStates: {
    FocusTimerAttributes.ContentState.timerRunning
}

#Preview("Dynamic Island Minimal", as: .dynamicIsland(.minimal), using: FocusTimerAttributes.preview) {
   FocusTimerWidgetLiveActivity()
} contentStates: {
    FocusTimerAttributes.ContentState.timerRunning
}
