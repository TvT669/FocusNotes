//
//  FocusTimerWidgetLiveActivity.swift
//  FocusTimerWidget
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/27.
//

import ActivityKit
import WidgetKit
import SwiftUI

// --- 定义主题颜色 ---
fileprivate let coralPink = Color(red: 255/255, green: 140/255, blue: 148/255)
fileprivate let offWhite = Color(red: 249/255, green: 243/255, blue: 234/255)

struct FocusTimerWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FocusTimerAttributes.self) { context in
            // --- 1. 锁屏界面 UI ---
            HStack(alignment: .center, spacing: 16) {
                // 左侧：倒计时
                VStack(alignment: .leading, spacing: 4) {
                    Text(context.state.endTime, style: .timer)
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(coralPink)
                        .monospacedDigit()
                }
                
                Spacer()
                
                // 右侧：暖心语录
                VStack(alignment: .trailing, spacing: 4) {
                    Text("保持专注")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(Color(red: 74/255, green: 64/255, blue: 58/255))
                    
                    Text("种下希望")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                // 装饰图标
                Image(systemName: "sun.horizon.fill")
                    .foregroundColor(coralPink.opacity(0.8))
                    .font(.system(size: 20))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 16)
            .activityBackgroundTint(offWhite)
            
        } dynamicIsland: { context in
            // --- 2. 灵动岛 UI ---
            DynamicIsland {
                // A. 展开区域 (长按灵动岛) - 暂时保持原样或后续开发
                DynamicIslandExpandedRegion(.leading) {
                    TomatoIconView()
                        .frame(width: 30, height: 30)
                        .padding(.leading, 8)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text(context.state.endTime, style: .timer)
                        .font(.title)
                        .foregroundColor(coralPink)
                        .monospacedDigit()
                        .padding(.trailing, 8)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    // 这里可以放置设计稿中的插图和文字
                    VStack {
                        // 占位插图，实际需替换为 Image("your_illustration")
                        Image(systemName: "book.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 60)
                            .foregroundColor(coralPink.opacity(0.6))
                            .padding(.vertical, 8)
                        
                        Text("保持专注，种下希望")
                            .font(.caption)
                            .foregroundColor(Color(red: 74/255, green: 64/255, blue: 58/255))
                    }
                    .padding(.bottom, 8)
                }
            } compactLeading: {
                // --- B. 收起状态左侧 (设计稿左图) ---
                // 仅显示番茄图标
                TomatoIconView()
                    .frame(width: 22, height: 22)
            } compactTrailing: {
                // --- C. 收起状态右侧 (设计稿左图) ---
                // 只显示倒计时数字，避免过宽
                Text(context.state.endTime, style: .timer)
                    .font(.system(size: 12, weight: .semibold))
                    .monospacedDigit()
                    .foregroundColor(coralPink)
                    .frame(maxWidth: 36) // 限制宽度
                
            } minimal: {
                // --- D. 最小化状态 (设计稿右图) ---
                TomatoIconView()
                    .frame(width: 20, height: 20)
            }
        }
    }
}

// MARK: - 自定义组件 View

// 1. 番茄图标组件
struct TomatoIconView: View {
    var body: some View {
        // 请确保 Assets.xcassets 中有名为 "tomato_icon_small" 的素材
        // 并将其 "Render As" 设置为 "Template Image" 以便着色
        Image("tomato_icon_small") // 如果没有素材，暂时用 Image(systemName: "timer") 代替调试
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(coralPink)
    }
}




// MARK: - Previews (更新预览数据)

extension FocusTimerAttributes {
    fileprivate static var preview: FocusTimerAttributes {
        FocusTimerAttributes()
    }
}

extension FocusTimerAttributes.ContentState {
    // 创建一个模拟的运行中状态
    fileprivate static var timerRunning: FocusTimerAttributes.ContentState {
        let now = Date()
        let duration: TimeInterval = 25 * 60 // 25分钟
        return FocusTimerAttributes.ContentState(
            endTime: now.addingTimeInterval(duration),
            startTime: now,
            totalDuration: duration
        )
    }
}

#Preview("Lock Screen", as: .content, using: FocusTimerAttributes.preview) {
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
