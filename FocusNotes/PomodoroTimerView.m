//
//  PomodoroTimerView.m
//  FocusNotes
//
//  Created by Copilot on 2025/11/19.
//

#import "PomodoroTimerView.h"
#import <QuartzCore/QuartzCore.h>

@interface PomodoroTimerView ()

@property (nonatomic, strong) CAShapeLayer *backgroundCircleLayer;
@property (nonatomic, strong) CAShapeLayer *progressCircleLayer;
@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, assign) NSTimeInterval totalTime;
@property (nonatomic, strong) UIColor *startColor;
@property (nonatomic, strong) UIColor *endColor;

@end

@implementation PomodoroTimerView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    _startColor = [UIColor colorWithRed:0.20 green:0.60 blue:1.0 alpha:1.0]; // system blue-ish
    _endColor   = [UIColor colorWithRed:1.0 green:0.30 blue:0.30 alpha:1.0]; // tomato-ish

    // 背景圆环
    _backgroundCircleLayer = [CAShapeLayer layer];
    _backgroundCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _backgroundCircleLayer.strokeColor = [[UIColor colorWithWhite:0.90 alpha:1.0] CGColor];
    _backgroundCircleLayer.lineWidth = 16.0;
    _backgroundCircleLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_backgroundCircleLayer];

    // 进度圆环
    _progressCircleLayer = [CAShapeLayer layer];
    _progressCircleLayer.fillColor = [UIColor clearColor].CGColor;
    _progressCircleLayer.strokeColor = _startColor.CGColor;
    _progressCircleLayer.lineWidth = 16.0;
    _progressCircleLayer.lineCap = kCALineCapRound;
    _progressCircleLayer.strokeStart = 0.0;
    _progressCircleLayer.strokeEnd = 1.0; // 初始显示满圆（未开始）
    [self.layer addSublayer:_progressCircleLayer];

    // 时间标签
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    _timeLabel.font = [UIFont monospacedDigitSystemFontOfSize:36 weight:UIFontWeightSemibold];
    _timeLabel.textColor = [UIColor labelColor];
    _timeLabel.text = @"00:00";
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _timeLabel.minimumScaleFactor = 0.5;
    [self addSubview:_timeLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateCirclePath];

    // 居中 timeLabel
    CGFloat inset = 24.0;
    self.timeLabel.frame = CGRectInset(self.bounds, inset, inset);
}

- (void)updateCirclePath {
    CGRect bounds = self.bounds;
    CGFloat minSide = MIN(bounds.size.width, bounds.size.height);
    CGFloat lineWidth = self.backgroundCircleLayer.lineWidth;
    CGFloat radius = (minSide - lineWidth) / 2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:radius
                                                          startAngle:-M_PI_2
                                                            endAngle:(3 * M_PI_2)
                                                           clockwise:YES];
    self.backgroundCircleLayer.path = circlePath.CGPath;
    self.progressCircleLayer.path = circlePath.CGPath;
}

#pragma mark - Public API

- (void)configureWithTotalTime:(NSTimeInterval)totalTime {
    self.totalTime = MAX(totalTime, 1.0); // 防止除零
    self.progressCircleLayer.strokeEnd = 1.0; // 初始满圈
}

- (void)updateTimeRemaining:(NSTimeInterval)timeRemaining {
    // 安全范围
    NSTimeInterval clamped = MAX(0, MIN(timeRemaining, self.totalTime));

    // 更新文本
    self.timeLabel.text = [self.class stringFromTimeInterval:clamped];

    // 计算进度（剩余/总时长）
    CGFloat progress = (CGFloat)(clamped / self.totalTime); // 1.0 -> 0.0

    // 颜色插值：剩余越少，越接近 endColor
    UIColor *color = [self interpolatedColorFrom:self.startColor to:self.endColor progress:(1.0 - progress)];

    // 关闭隐式动画，避免跳动
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.progressCircleLayer.strokeEnd = progress;
    self.progressCircleLayer.strokeColor = color.CGColor;
    [CATransaction commit];
}

- (void)setStartColor:(UIColor *)startColor endColor:(UIColor *)endColor {
    _startColor = startColor ?: _startColor;
    _endColor = endColor ?: _endColor;
    // 立即刷新一次颜色
    [self updateTimeRemaining:self.totalTime];
}

#pragma mark - Helpers

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger total = (NSInteger)round(interval);
    NSInteger minutes = total / 60;
    NSInteger seconds = total % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

- (UIColor *)interpolatedColorFrom:(UIColor *)from to:(UIColor *)to progress:(CGFloat)t {
    t = MAX(0, MIN(1, t));
    CGFloat fr, fg, fb, fa;
    CGFloat tr, tg, tb, ta;
    [from getRed:&fr green:&fg blue:&fb alpha:&fa];
    [to getRed:&tr green:&tg blue:&tb alpha:&ta];
    CGFloat r = fr + (tr - fr) * t;
    CGFloat g = fg + (tg - fg) * t;
    CGFloat b = fb + (tb - fb) * t;
    CGFloat a = fa + (ta - fa) * t;
    return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

@end
