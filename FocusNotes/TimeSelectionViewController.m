//
//  TimeSelectionViewController.m
//  FocusNotes
//
//  Created by GitHub Copilot on 2025/11/27.
//

#import "TimeSelectionViewController.h"

#define kWarmBeigeColor [UIColor colorWithRed:253/255.0 green:251/255.0 blue:247/255.0 alpha:1.0]
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]

@interface TimeSelectionViewController ()
@property (nonatomic, strong) UIDatePicker *datePicker;
@end

@implementation TimeSelectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = kWarmBeigeColor;
    [self setupUI];
}

- (void)setupUI {
    // 标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"选择专注时长";
    titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
    titleLabel.textColor = kWarmCoffeeColor;
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:titleLabel];

    // 时间选择器
    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.datePickerMode = UIDatePickerModeCountDownTimer;
    self.datePicker.minuteInterval = 1;
    self.datePicker.countDownDuration = 25 * 60; // 默认 25 分钟
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.datePicker];

    // 确认按钮
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [confirmButton setTitle:@"开始专注" forState:UIControlStateNormal];
    confirmButton.backgroundColor = kWarmCoralColor;
    confirmButton.layer.cornerRadius = 25;
    [confirmButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    confirmButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightMedium];
    
    // 添加阴影
    confirmButton.layer.shadowColor = kWarmCoralColor.CGColor;
    confirmButton.layer.shadowOffset = CGSizeMake(0, 4);
    confirmButton.layer.shadowRadius = 8;
    confirmButton.layer.shadowOpacity = 0.3;
    
    [confirmButton addTarget:self action:@selector(confirmTapped) forControlEvents:UIControlEventTouchUpInside];
    confirmButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:confirmButton];

    [NSLayoutConstraint activateConstraints:@[
        [titleLabel.topAnchor constraintEqualToAnchor:self.view.topAnchor constant:30],
        [titleLabel.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],

        [self.datePicker.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [self.datePicker.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor constant:-20],

        [confirmButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
        [confirmButton.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor constant:40],
        [confirmButton.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor constant:-40],
        [confirmButton.heightAnchor constraintEqualToConstant:50]
    ]];
}

- (void)confirmTapped {
    if (self.timeSelectedBlock) {
        self.timeSelectedBlock((NSInteger)self.datePicker.countDownDuration);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
