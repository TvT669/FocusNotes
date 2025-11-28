//
//  LiveActivityManager.swift
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/27.
//

import Foundation
import ActivityKit

@objc @MainActor public class LiveActivityManager: NSObject {
    
    @objc public static let shared = LiveActivityManager()
    
    // 保存当前的 Activity 实例
    private var currentActivity: Activity<FocusTimerAttributes>?
    
    // --- 开启灵动岛 ---
    @objc public func startTimer(endTime: Date) {
        // 检查系统是否支持
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Live Activities not enabled")
            return
        }
        
        // 结束之前的活动（如果有）
        stopTimer()
        
        let attributes = FocusTimerAttributes()
        
        // 计算总时长：结束时间 - 当前时间
        let now = Date()
        let duration = endTime.timeIntervalSince(now)
        
        let contentState = FocusTimerAttributes.ContentState(
            endTime: endTime,
            startTime: now,
            totalDuration: duration
        )
        
        do {
            let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
            )
            self.currentActivity = activity
            print("Live Activity Started ID: \(activity.id)")
        } catch {
            print("Error starting activity: \(error.localizedDescription)")
        }
    }
    
    // --- 结束灵动岛 ---
    @objc public func stopTimer() {
        guard let activity = currentActivity else { return }
        
        let finalState = activity.content.state
        
        Task {
            // dismissalPolicy: .immediate 表示立即消失
            await activity.end(using: finalState, dismissalPolicy: .immediate)
            self.currentActivity = nil
            print("Live Activity Ended")
        }
    }
}
