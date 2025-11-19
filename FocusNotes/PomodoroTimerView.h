//
//  PomodoroTimerView.h
//  FocusNotes
//
//  Created by Copilot on 2025/11/19.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PomodoroTimerView : UIView

// 配置总时长（秒）
- (void)configureWithTotalTime:(NSTimeInterval)totalTime;

// 每次 tick 调用，更新剩余时间（秒）
- (void)updateTimeRemaining:(NSTimeInterval)timeRemaining;

// 可选：设置起止颜色（0%/100%）
- (void)setStartColor:(UIColor *)startColor endColor:(UIColor *)endColor;

@end

NS_ASSUME_NONNULL_END
