//
//  ViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "TimeVC.h"

@interface TimeVC ()
@property (nonatomic, assign) NSInteger totalSeconds;      // 总秒数（25 * 60）
@property (nonatomic, assign) NSInteger remainingSeconds;  // 剩余秒数
@property (nonatomic, strong) NSTimer *timer;


@end

@implementation TimeVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.totalSeconds = 1 * 5;     // 25分钟
    self.remainingSeconds = self.totalSeconds;
    [self updateTimerDisplay];
}

// 更新倒计时显示（MM:SS）
- (void)updateTimerDisplay {
    NSInteger mins = self.remainingSeconds / 60;
    NSInteger secs = self.remainingSeconds % 60;
    self.timeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", (long)mins, (long)secs];
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
            // 跳转到笔记页面
            UITabBarController *tabBarController = (UITabBarController *)self.tabBarController;
            if (tabBarController) {
                // NotesTableViewController 是第二个 Tab，索引为 1
                tabBarController.selectedIndex = 1;
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
