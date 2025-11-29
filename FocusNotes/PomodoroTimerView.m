//
//  PomodoroTimerView.m
//  FocusNotes
//
//  Created by Copilot on 2025/11/19.
//

#import "PomodoroTimerView.h"
#import <QuartzCore/QuartzCore.h>

// 定义宏以便在 View 内部使用
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
#define kWarmOrangeColor [UIColor colorWithRed:255/255.0 green:170/255.0 blue:133/255.0 alpha:1.0]
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]
#define kWarmOffWhiteColor [UIColor colorWithRed:249/255.0 green:243/255.0 blue:234/255.0 alpha:1.0]

@interface PomodoroTimerView ()

@property (nonatomic, strong) CAShapeLayer *backgroundCircleLayer;
// 使用 CAGradientLayer 来实现渐变进度条
@property (nonatomic, strong) CAGradientLayer *gradientLayer;
@property (nonatomic, strong) CAShapeLayer *progressMaskLayer; // 用于遮罩渐变层

@property (nonatomic, strong) UILabel *timeLabel;
@property (nonatomic, strong) UILabel *subtitleLabel; // 新增：励志语标签

@property (nonatomic, assign) NSTimeInterval totalTime;

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

// 辅助方法：获取圆体字
- (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *systemFont = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [systemFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    if (descriptor) {
        return [UIFont fontWithDescriptor:descriptor size:size];
    }
    return systemFont;
}

- (void)commonInit {
    self.backgroundColor = [UIColor clearColor];
    // 设置更大的线宽
    CGFloat lineWidth = 18.0;
    
    // --- 1. 背景圆环 ---
    _backgroundCircleLayer = [CAShapeLayer layer];
    _backgroundCircleLayer.fillColor = [UIColor clearColor].CGColor;
    // 使用极淡的暖色作为背景轨道的颜色
    _backgroundCircleLayer.strokeColor = [[kWarmOrangeColor colorWithAlphaComponent:0.15] CGColor];
    _backgroundCircleLayer.lineWidth = lineWidth;
    _backgroundCircleLayer.lineCap = kCALineCapRound;
    [self.layer addSublayer:_backgroundCircleLayer];
    
    // --- 2. 渐变进度圆环 ---
    // 创建一个渐变层
    _gradientLayer = [CAGradientLayer layer];
    // 设置渐变色：从暖橙色到珊瑚粉
    _gradientLayer.colors = @[(__bridge id)kWarmOrangeColor.CGColor,
                              (__bridge id)kWarmCoralColor.CGColor];
    _gradientLayer.startPoint = CGPointMake(0.5, 0.0); // 顶部开始
    _gradientLayer.endPoint = CGPointMake(0.5, 1.0);   // 底部结束
    [self.layer addSublayer:_gradientLayer];
    
    // 创建一个用于遮罩的 ShapeLayer
    _progressMaskLayer = [CAShapeLayer layer];
    _progressMaskLayer.fillColor = [UIColor clearColor].CGColor;
    _progressMaskLayer.strokeColor = [UIColor blackColor].CGColor; // 遮罩层颜色不重要，只需不透明即可
    _progressMaskLayer.lineWidth = lineWidth;
    _progressMaskLayer.lineCap = kCALineCapRound;
    _progressMaskLayer.strokeStart = 0.0;
    _progressMaskLayer.strokeEnd = 1.0;
    // 将遮罩应用到渐变层
    _gradientLayer.mask = _progressMaskLayer;
    
    // --- 3. 添加柔和的投影 ---
    // 给整个 Layer 添加投影，营造浮起感
    self.layer.shadowColor = kWarmCoralColor.CGColor;
    self.layer.shadowOffset = CGSizeMake(0, 8);
    self.layer.shadowRadius = 16;
    self.layer.shadowOpacity = 0.2;
    
    // --- 4. 时间标签 ---
    _timeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _timeLabel.textAlignment = NSTextAlignmentCenter;
    // 使用特大号圆体字
    _timeLabel.font = [self roundedFontOfSize:64 weight:UIFontWeightBold];
    _timeLabel.textColor = kWarmCoffeeColor;
    _timeLabel.text = @"00:00";
    _timeLabel.adjustsFontSizeToFitWidth = YES;
    _timeLabel.minimumScaleFactor = 0.5;
    [self addSubview:_timeLabel];
    
    // --- 5. 励志语标签 ---
    _subtitleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    _subtitleLabel.textAlignment = NSTextAlignmentCenter;
    _subtitleLabel.font = [self roundedFontOfSize:16 weight:UIFontWeightMedium];
    _subtitleLabel.textColor = [kWarmCoffeeColor colorWithAlphaComponent:0.7];
    _subtitleLabel.text = @"保持专注，种下希望";
    [self addSubview:_subtitleLabel];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateCirclePath];
    
    // 更新渐变层的 frame
    self.gradientLayer.frame = self.bounds;

    // 布局 Labels
    CGFloat midY = CGRectGetMidY(self.bounds);
    
    // 时间标签居中略偏上
    self.timeLabel.frame = CGRectMake(20, midY - 50, self.bounds.size.width - 40, 80);
    // 副标题在时间标签下方
    self.subtitleLabel.frame = CGRectMake(20, midY + 30, self.bounds.size.width - 40, 30);
}

- (void)updateCirclePath {
    CGRect bounds = self.bounds;
    CGFloat minSide = MIN(bounds.size.width, bounds.size.height);
    // 使用新的线宽
    CGFloat lineWidth = self.backgroundCircleLayer.lineWidth;
    CGFloat radius = (minSide - lineWidth) / 2.0;
    CGPoint center = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));

    // 修改起始角度为顶部 (-M_PI_2)
    UIBezierPath *circlePath = [UIBezierPath bezierPathWithArcCenter:center
                                                              radius:radius
                                                          startAngle:-M_PI_2
                                                            endAngle:(-M_PI_2 + 1.95 * M_PI) // 顺时针转一圈
                                                           clockwise:YES];
    self.backgroundCircleLayer.path = circlePath.CGPath;
    // 更新遮罩的路径
    self.progressMaskLayer.path = circlePath.CGPath;
}

#pragma mark - Public API

- (void)configureWithTotalTime:(NSTimeInterval)totalTime {
    self.totalTime = MAX(totalTime, 1.0);
    self.progressMaskLayer.strokeEnd = 1.0;
}

- (void)updateTimeRemaining:(NSTimeInterval)timeRemaining {
    NSTimeInterval clamped = MAX(0, MIN(timeRemaining, self.totalTime));

    self.timeLabel.text = [self.class stringFromTimeInterval:clamped];

    CGFloat progress = (CGFloat)(clamped / self.totalTime);

    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    // 更新遮罩的 strokeEnd 来实现进度变化
    self.progressMaskLayer.strokeEnd = progress;
    [CATransaction commit];
}


#pragma mark - Helpers

+ (NSString *)stringFromTimeInterval:(NSTimeInterval)interval {
    NSInteger total = (NSInteger)round(interval);
    NSInteger minutes = total / 60;
    NSInteger seconds = total % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

@end
