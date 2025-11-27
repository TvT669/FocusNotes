//
//  TimeVC.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "TimeVC.h"
#import "NotesTableViewController.h"
#import "PomodoroTimerView.h"
#import "TimeSelectionViewController.h"
// 假设你已经导入了 Swift 头文件 (如果需要)
// #import "FocusNotes-Swift.h"

// --- 定义宏：方便使用温馨风格的颜色 ---
#define kWarmBeigeColor [UIColor colorWithRed:253/255.0 green:251/255.0 blue:247/255.0 alpha:1.0]
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
#define kWarmOrangeColor [UIColor colorWithRed:255/255.0 green:170/255.0 blue:133/255.0 alpha:1.0]
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]

@interface TimeVC ()
@property (nonatomic, assign) NSInteger totalSeconds;
@property (nonatomic, assign) NSInteger remainingSeconds;
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) PomodoroTimerView *timerView;
// 新增按钮属性
@property (nonatomic, strong) UIButton *startButton;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, strong) UIButton *resetButton;

// 用于控制按钮区域的 StackView
@property (nonatomic, strong) UIStackView *buttonsStackView;

@end

@implementation TimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 设置背景色
    self.view.backgroundColor = kWarmBeigeColor;
    self.timeLabel.hidden = YES;
    self.totalSeconds = 25 * 60;
    self.remainingSeconds = self.totalSeconds;
    
    // 2. 构建 UI
    [self setupUI];
    
    // 3. 配置初始状态
    [self.timerView configureWithTotalTime:self.totalSeconds];
    [self updateTimerDisplay];
    [self updateButtonStatesFor:TimerStateStopped]; // 初始状态
}

// 定义计时器状态枚举，方便管理按钮显示
typedef NS_ENUM(NSInteger, TimerState) {
    TimerStateStopped,
    TimerStateRunning,
    TimerStatePaused,
    TimerStateFinished
};

#pragma mark - UI Setup

- (void)setupUI {
    // --- 1. 添加番茄钟视图 ---
    self.timerView = [[PomodoroTimerView alloc] initWithFrame:CGRectZero];
    self.timerView.translatesAutoresizingMaskIntoConstraints = NO;
    // 开启交互并添加点击手势
    self.timerView.userInteractionEnabled = YES;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(timerViewTapped)];
    [self.timerView addGestureRecognizer:tapGesture];
    
    [self.view addSubview:self.timerView];
    
    // --- 2. 创建按钮 ---
    self.startButton = [self createMainButtonWithIcon:@"icon_play" action:@selector(startTimerTapped:)];
    self.pauseButton = [self createSecondaryButtonWithIcon:@"icon_pause" action:@selector(pauseTimerTapped:)];
    self.resetButton = [self createSecondaryButtonWithIcon:@"icon_reset" action:@selector(resetTimerTapped:)];
    
    // --- 3. 创建按钮布局 StackView ---
    // 布局逻辑：[重置] - [开始] - [暂停]
    // 按照用户要求，三个按钮并排显示
    
    // 设置按钮尺寸约束
    [NSLayoutConstraint activateConstraints:@[
        [self.startButton.widthAnchor constraintEqualToConstant:100],
        [self.startButton.heightAnchor constraintEqualToConstant:100],
        
        [self.pauseButton.widthAnchor constraintEqualToConstant:60],
        [self.pauseButton.heightAnchor constraintEqualToConstant:60],
        
        [self.resetButton.widthAnchor constraintEqualToConstant:60],
        [self.resetButton.heightAnchor constraintEqualToConstant:60]
    ]];
    
    // 整体按钮 StackView
    self.buttonsStackView = [[UIStackView alloc] initWithArrangedSubviews:@[self.resetButton, self.startButton, self.pauseButton]];
    self.buttonsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.buttonsStackView.alignment = UIStackViewAlignmentCenter;
    self.buttonsStackView.spacing = 30; // 按钮之间的间距
    self.buttonsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.buttonsStackView];
    
    // --- 4. 设置 Auto Layout 约束 ---
    NSLayoutConstraint *timerWidth = [self.timerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.7];
    
    [NSLayoutConstraint activateConstraints:@[
        // TimerView 约束
        [self.timerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        // 将 TimerView 放在偏上的位置 (屏幕高度的 35% 处)
        [self.timerView.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-self.view.bounds.size.height * 0.10],
        timerWidth,
        [self.timerView.heightAnchor constraintEqualToAnchor:self.timerView.widthAnchor],
        
        // ButtonsStackView 约束
        [self.buttonsStackView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        // 放在 TimerView 下方
       // [self.buttonsStackView.topAnchor constraintEqualToAnchor:self.timerView.bottomAnchor constant:60],
        [self.buttonsStackView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-150],
              
        
        // 重置按钮尺寸
        [self.resetButton.widthAnchor constraintEqualToConstant:60],
        [self.resetButton.heightAnchor constraintEqualToConstant:60]
    ]];
}


// 辅助方法：创建主按钮 (开始)
- (UIButton *)createMainButtonWithIcon:(NSString *)iconName action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage *icon = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
    // 创建渐变层
    CAGradientLayer *gradientLayer = [CAGradientLayer layer];
    // 设置渐变尺寸为按钮目标尺寸 (80x80)
    gradientLayer.frame = CGRectMake(0, 0, 100, 100);
    // 设置渐变色：从暖橙到珊瑚粉
    gradientLayer.colors = @[(__bridge id)kWarmOrangeColor.CGColor,
                             (__bridge id)kWarmCoralColor.CGColor];
    // 从左上到右下的对角线渐变，更有动感
    gradientLayer.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer.endPoint = CGPointMake(1.0, 1.0);
    // 设置为圆形
    gradientLayer.cornerRadius = 50;
    
    // 将渐变层插入到按钮图层的最底层，这样图标就会显示在它上面
    [btn.layer insertSublayer:gradientLayer atIndex:0];
    // 强制将 imageView 提到最前，防止被遮挡
    if (btn.imageView) {
        [btn bringSubviewToFront:btn.imageView];
        btn.imageEdgeInsets = UIEdgeInsetsMake(20, 20, 20, 20);
    }
    
    // 添加柔和投影 (保持不变或微调)
    btn.layer.shadowColor = kWarmCoralColor.CGColor;
    btn.layer.shadowOffset = CGSizeMake(0, 8);
    btn.layer.shadowRadius = 16; // 增大模糊半径
    btn.layer.shadowOpacity = 0.3;
    btn.layer.masksToBounds = NO;
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

// 辅助方法：创建次要按钮 (重置/暂停)
- (UIButton *)createSecondaryButtonWithIcon:(NSString *)iconName action:(SEL)action {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.translatesAutoresizingMaskIntoConstraints = NO;
    
    UIImage *icon = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [btn setImage:icon forState:UIControlStateNormal];
    btn.tintColor = [UIColor whiteColor];
  
    btn.backgroundColor = kWarmCoralColor;
    btn.layer.cornerRadius = 30; // 半径 (60/2)
    
    [btn addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

#pragma mark - Timer Logic & State Management

// 根据状态更新按钮显示
- (void)updateButtonStatesFor:(TimerState)state {
    // 始终显示所有按钮，通过 enabled 和 alpha 来控制状态
    self.startButton.hidden = NO;
    self.pauseButton.hidden = NO;
    self.resetButton.hidden = NO;
    
    switch (state) {
        case TimerStateStopped:
            // 停止状态：可以开始，不能暂停，不能重置(或者可以重置)
            //开始状态
            self.startButton.enabled = YES;
            self.startButton.alpha = 1.0;
            
            self.pauseButton.enabled = NO;
            self.pauseButton.alpha = 0.5;
            
            self.resetButton.enabled = NO;
            self.resetButton.alpha = 0.5;
            break;
            
        case TimerStateRunning:
            // 运行状态：不能开始，可以暂停，可以重置
            self.startButton.enabled = NO;
            self.startButton.alpha = 0.5;
            
            self.pauseButton.enabled = YES;
            self.pauseButton.alpha = 1.0;
            
            self.resetButton.enabled = YES;
            self.resetButton.alpha = 1.0;
            break;
            
        case TimerStatePaused:
            // 暂停状态：可以继续(开始)，不能暂停，可以重置
            self.startButton.enabled = YES;
            self.startButton.alpha = 1.0;
            
            self.pauseButton.enabled = NO;
            self.pauseButton.alpha = 0.5;
            
            self.resetButton.enabled = YES;
            self.resetButton.alpha = 1.0;
            break;
            //完成状态:可以重置 不可暂停 不可开始
        case TimerStateFinished:
               // 完成状态: 可以重置，不可暂停，不可开始
               self.startButton.enabled = NO;
               self.startButton.alpha = 0.5;
               
               self.pauseButton.enabled = NO;
               self.pauseButton.alpha = 0.5;
               
               self.resetButton.enabled = YES;
               self.resetButton.alpha = 1.0;
               break;
    }
}


- (void)updateTimerDisplay {
    [self.timerView updateTimeRemaining:self.remainingSeconds];
}

// 处理 TimerView 点击事件
- (void)timerViewTapped {
    // 如果计时器正在运行，不允许修改时间（或者你可以选择暂停并修改）
    if (self.timer) {
        return;
    }
    
    TimeSelectionViewController *selectionVC = [[TimeSelectionViewController alloc] init];
    
    // 设置 sheet 样式 (iOS 15+)
    if (@available(iOS 15.0, *)) {
        if (selectionVC.sheetPresentationController) {
            selectionVC.sheetPresentationController.detents = @[UISheetPresentationControllerDetent.mediumDetent];
            selectionVC.sheetPresentationController.prefersGrabberVisible = YES;
        }
    }
    
    __weak typeof(self) weakSelf = self;
    selectionVC.timeSelectedBlock = ^(NSInteger seconds) {
        [weakSelf updateTimerWithSeconds:seconds];
    };
    
    [self presentViewController:selectionVC animated:YES completion:nil];
}

// 更新计时器时间
- (void)updateTimerWithSeconds:(NSInteger)seconds {
    self.totalSeconds = seconds;
    self.remainingSeconds = seconds;
    [self.timerView configureWithTotalTime:self.totalSeconds];
    [self updateTimerDisplay];
    // 重置按钮状态
    [self updateButtonStatesFor:TimerStateStopped];
}

// 新的 Action 方法
- (void)startTimerTapped:(id)sender {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(timerTick)
                                                    userInfo:nil
                                                     repeats:YES];
        [self updateButtonStatesFor:TimerStateRunning];
    }
}

- (void)pauseTimerTapped:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    [self updateButtonStatesFor:TimerStatePaused];
}

- (void)resetTimerTapped:(id)sender {
    [self.timer invalidate];
    self.timer = nil;
    self.remainingSeconds = self.totalSeconds;
    [self updateTimerDisplay];
    [self updateButtonStatesFor:TimerStateStopped];
}

// timerTick 方法保持不变
- (void)timerTick {
    self.remainingSeconds--;
    if (self.remainingSeconds < 0) {
        self.remainingSeconds = 0;
    }
    [self updateTimerDisplay];

    if (self.remainingSeconds == 0) {
        [self.timer invalidate];
        self.timer = nil;
        [self updateButtonStatesFor:TimerStateFinished]; // 计时结束回到停止状态

        // 弹出提示框的代码保持不变...
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"🍅 专注完成！" message:@"恭喜你完成了一个番茄钟！要不要记录一下学习内容？" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *noteAction = [UIAlertAction
                                            actionWithTitle:@"记录笔记"
                                            style:UIAlertActionStyleDefault
                                            handler:^(UIAlertAction * _Nonnull action) {
                   // 切换到“笔记”Tab 并立即打开新建笔记页
                   UITabBarController *tabBarController = (UITabBarController *)self.tabBarController;
                   if (tabBarController && tabBarController.viewControllers.count > 1) {
                       tabBarController.selectedIndex = 1; // 切到“笔记”

                       // 等一帧确保切换完成后再取目标控制器
                       dispatch_async(dispatch_get_main_queue(), ^{
                           UIViewController *selectedVC = tabBarController.selectedViewController;
                           UINavigationController *notesNav = nil;
                           if ([selectedVC isKindOfClass:[UINavigationController class]]) {
                               notesNav = (UINavigationController *)selectedVC;
                           }
                           if (notesNav) {
                               UIViewController *root = notesNav.viewControllers.firstObject;
                               if ([root isKindOfClass:[NotesTableViewController class]]) {
                                   NotesTableViewController *notesVC = (NotesTableViewController *)root;
                                   [notesVC openCreateNote];
                               }
                           }
                       });
                   }
               }];

               UIAlertAction *cancelAction = [UIAlertAction
                                              actionWithTitle:@"稍后再说"
                                              style:UIAlertActionStyleCancel
                                              handler:nil];

               [alert addAction:noteAction];
               [alert addAction:cancelAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}


@end
