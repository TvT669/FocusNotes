//
//  ViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "TimeVC.h"
#import "NotesTableViewController.h"
#import "PomodoroTimerView.h"
#import "FocusNotes-Swift.h"


@interface TimeVC ()
@property (nonatomic, assign) NSInteger totalSeconds;      // 总秒数（25 * 60）
@property (nonatomic, assign) NSInteger remainingSeconds;  // 剩余秒数
@property (nonatomic, strong) NSTimer *timer;

@property (nonatomic, strong) PomodoroTimerView *timerView; // 自定义番茄钟视图
@property (nonatomic, strong) NSLayoutConstraint *timerTopConstraint; // 控制 Y 位置（1/3 处）


@end

@implementation TimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Do any additional setup after loading the view.
    self.totalSeconds = 25 * 60;     // 25分钟
    self.remainingSeconds = self.totalSeconds;
    
    // 构建并添加番茄钟视图
    self.timerView = [[PomodoroTimerView alloc] initWithFrame:CGRectZero];
    self.timerView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.timerView];

    // 约束：居中，宽高为视图较短边的 70%（简易自适应，避免不同设备比例问题）
    NSLayoutConstraint *centerX = [self.timerView.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor];
    NSLayoutConstraint *width = [self.timerView.widthAnchor constraintEqualToAnchor:self.view.widthAnchor multiplier:0.6];
    NSLayoutConstraint *height = [self.timerView.heightAnchor constraintEqualToAnchor:self.timerView.widthAnchor];
    self.timerTopConstraint = [self.timerView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:0];

    [NSLayoutConstraint activateConstraints:@[centerX, width, height, self.timerTopConstraint]];

    // 隐藏原有纯文本倒计时标签，改由圆环内置标签显示
    self.timeLabel.hidden = YES;

    // 配置总时长并显示初始剩余时间
    [self.timerView configureWithTotalTime:self.totalSeconds];
    [self updateTimerDisplay];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    // 将圆环中心移动到安全区域高度的 1/3 处
    UIEdgeInsets insets = self.view.safeAreaInsets;
    CGFloat safeHeight = self.view.bounds.size.height - insets.top - insets.bottom;
    CGFloat viewWidth = self.view.bounds.size.width;
    CGFloat timerSize = viewWidth * 0.6; // 与 width 约束保持一致
    CGFloat targetCenterYFromSafeTop = safeHeight / 3.0; // 1/3 处
    CGFloat topConstant = targetCenterYFromSafeTop - (timerSize / 2.0);
    // 不小于 0，避免超出顶部
    self.timerTopConstraint.constant = MAX(0.0, topConstant);
}

// 更新倒计时显示（MM:SS）
- (void)updateTimerDisplay {
    NSInteger mins = self.remainingSeconds / 60;
    NSInteger secs = self.remainingSeconds % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)mins, (long)secs];
    // 同步自定义视图的显示
    [self.timerView updateTimeRemaining:self.remainingSeconds];
}

- (IBAction)startTimer:(id)sender {
    if (!self.timer) {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0
                                                      target:self
                                                    selector:@selector(timerTick)
                                                    userInfo:nil
                                                     repeats:YES];
    }
}

- (IBAction)pauseTimer:(id)sender {
    [self.timer invalidate];
     self.timer = nil;
}


- (IBAction)resetTimer:(id)sender {
    [self.timer invalidate];
       self.timer = nil;
       self.remainingSeconds = self.totalSeconds;
       [self updateTimerDisplay];
}
// 每秒执行一次
- (void)timerTick {
    self.remainingSeconds--;
    
    // 确保不会变成负数
    if (self.remainingSeconds < 0) {
        self.remainingSeconds = 0;
    }
    
    [self updateTimerDisplay];

    if (self.remainingSeconds == 0) {
        [self.timer invalidate];
        self.timer = nil;

        // 时间到，弹出提示
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:@"🍅 专注完成！"
                                    message:@"恭喜你完成了一个番茄钟！要不要记录一下学习内容？"
                                    preferredStyle:UIAlertControllerStyleAlert];

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
// 1. 添加 viewDidAppear 来检查是否需要显示欢迎页
-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 检查 UserDefaults 标记
    BOOL hasCompletedOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"];
    
    if (!hasCompletedOnboarding) {
        [self showOnboarding];
    }
}

// 2. 显示欢迎页的方法
-(void)showOnboarding {
    // 调用 Swift 的静态方法
    UIViewController *onboardingVC = [OnboardingManager createOnboardingViewControllerWithDelegate:self];
    onboardingVC.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:onboardingVC animated:YES completion:nil];
}
// 3. 实现代理方法：点击“开启专注之旅”后调用
// 注意：由于 UIOnboardingViewControllerDelegate 是 Swift 协议，OC 无法直接声明实现，
// 但运行时只要方法签名匹配即可被调用。
- (void)didFinishOnboarding:(UIViewController *)onboardingViewController {
    // 标记为已完成，下次不再显示
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedOnboarding"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // 关闭页面
    [onboardingViewController dismissViewControllerAnimated:YES completion:nil];
}

@end
