//
//  CustomOnboardingViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/26.
//

#import "CustomOnboardingViewController.h"

// --- 定义宏：方便使用温馨风格的颜色 ---
// 暖米色背景 #FDFBF7
#define kWarmBeigeColor [UIColor colorWithRed:253/255.0 green:251/255.0 blue:247/255.0 alpha:1.0]
// 温馨珊瑚色 #FF8C94
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
// 深咖啡色文本 #4A403A
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]

@interface CustomOnboardingViewController ()

// 声明 UI 元素属性，方便后续引用
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIStackView *mainStackView;

@end

@implementation CustomOnboardingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 1. 设置核心背景色
    self.view.backgroundColor = kWarmBeigeColor;
    
    // 2. 开始构建 UI
    [self setupUI];
}

#pragma mark - UI Setup Methods

- (void)setupUI {
    // 创建滚动视图 (防止小屏幕内容显示不全)
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.scrollView];
    
    // 创建内容容器视图
    UIView *contentView = [[UIView alloc] init];
    contentView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:contentView];
    
    // 创建主垂直堆栈视图 (StackView)
    self.mainStackView = [[UIStackView alloc] init];
    self.mainStackView.axis = UILayoutConstraintAxisVertical; // 垂直排列
    self.mainStackView.alignment = UIStackViewAlignmentCenter; // 居中对齐
    self.mainStackView.spacing = 16; // 元素间距
    self.mainStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:self.mainStackView];
    
    // --- 添加子视图到 StackView ---
    
    // 1. 顶部大插画
    UIImageView *headerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"header_illustration"]];
    headerImageView.contentMode = UIViewContentModeScaleAspectFit;
    // 设置一个合理的最大高度约束
    [headerImageView.heightAnchor constraintLessThanOrEqualToConstant:200].active = YES;
    [self.mainStackView addArrangedSubview:headerImageView];
    // 增加一点顶部间距
    [self.mainStackView setCustomSpacing:20 afterView:headerImageView];
    
    // 2. 主标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"FocusNotes";
    titleLabel.font = [self roundedFontOfSize:42 weight:UIFontWeightHeavy];
    titleLabel.textColor = kWarmCoralColor;
    titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainStackView addArrangedSubview:titleLabel];
    // 减小标题和副标题之间的间距
    [self.mainStackView setCustomSpacing:8 afterView:titleLabel];
    
    // 3. 副标题
    UILabel *subtitleLabel = [[UILabel alloc] init];
    subtitleLabel.text = @"开始你的一段静谧时光";
    subtitleLabel.font = [self roundedFontOfSize:20 weight:UIFontWeightMedium];
    subtitleLabel.textColor = kWarmCoffeeColor;
    subtitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.mainStackView addArrangedSubview:subtitleLabel];
    // 增加副标题和功能列表之间的间距
    [self.mainStackView setCustomSpacing:24 afterView:subtitleLabel];
    
    // 4. 功能列表 (使用修改后的辅助方法创建卡片)
    UIView *feature1 = [self createFeatureViewWithIcon:@"icon_tomato"
                                                 title:@"番茄专注"
                                           description:@"基于番茄工作法，帮助你保持专注，提升效率。"];
    UIView *feature2 = [self createFeatureViewWithIcon:@"icon_notebook"
                                                 title:@"快速记录"
                                           description:@"完成专注后自动提示记录笔记，捕捉灵感瞬间。"];
    UIView *feature3 = [self createFeatureViewWithIcon:@"icon_chart"
                                                 title:@"回顾统计"
                                           description:@"清晰的时间统计，让你看见每一分钟的价值。"];
    
    // 创建一个专门放功能列表的 StackView
    UIStackView *featuresStack = [[UIStackView alloc] initWithArrangedSubviews:@[feature1, feature2, feature3]];
    featuresStack.axis = UILayoutConstraintAxisVertical;
    // 【微调】由于卡片有了内边距，卡片之间的间距可以稍微减小一点，让整体更紧凑
    featuresStack.spacing = 12;
    featuresStack.alignment = UIStackViewAlignmentFill; // 让内部元素撑满宽度
    [self.mainStackView addArrangedSubview:featuresStack];
    // 确保功能列表宽度占满 (减去两边边距)
    [featuresStack.widthAnchor constraintEqualToAnchor:self.mainStackView.widthAnchor].active = YES;
    
    // 5. 弹簧占位符 (用于把下面的内容顶到底部，如果屏幕很高的话)
    UIView *spacer = [[UIView alloc] init];
    [spacer setContentHuggingPriority:UILayoutPriorityFittingSizeLevel forAxis:UILayoutConstraintAxisVertical];
    [self.mainStackView addArrangedSubview:spacer];
    
    // 6. 底部隐私提示
    UIView *privacyView = [self createPrivacyView];
    [self.mainStackView addArrangedSubview:privacyView];
    
    // 7. 底部大按钮
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [startButton setTitle:@"开启专注之旅" forState:UIControlStateNormal];
    startButton.titleLabel.font = [self roundedFontOfSize:20 weight:UIFontWeightBold];
    [startButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    startButton.backgroundColor = kWarmCoralColor;
    // 设置大圆角
    startButton.layer.cornerRadius = 28; // 高度56的一半
    startButton.layer.masksToBounds = YES;
    // 添加点击事件
    [startButton addTarget:self action:@selector(startButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    [self.mainStackView addArrangedSubview:startButton];
    
    // 设置按钮的尺寸约束
    startButton.translatesAutoresizingMaskIntoConstraints = NO;
    [NSLayoutConstraint activateConstraints:@[
        [startButton.heightAnchor constraintEqualToConstant:56],
        [startButton.widthAnchor constraintEqualToAnchor:self.mainStackView.widthAnchor] // 宽度占满StackView
    ]];
    
    // --- 设置 Auto Layout 约束 ---
    // 这里的约束比较关键，决定了整体布局结构
    [NSLayoutConstraint activateConstraints:@[
        // 1. ScrollView 占满全屏
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor],
        
        // 2. ContentView 撑满 ScrollView
        [contentView.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor],
        [contentView.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor],
        [contentView.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor],
        [contentView.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor],
        // 关键：让 content view 的宽度等于屏幕宽度，禁止横向滚动
        [contentView.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor],
        
        // 3. MainStackView 在 ContentView 中居中，并设置边距
        [self.mainStackView.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:20],
        [self.mainStackView.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:32], // 左边距
        [self.mainStackView.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-32], // 右边距
        // 底部留出一点空间，并且设置优先级较低，允许被弹簧撑开
        [self.mainStackView.bottomAnchor constraintLessThanOrEqualToAnchor:contentView.bottomAnchor constant:-40]
    ]];
    
    // 设置 StackView 的最小高度应等于视图的安全区域高度，确保在内容少时也能撑开屏幕
    NSLayoutConstraint *minHeightConstraint = [self.mainStackView.heightAnchor constraintGreaterThanOrEqualToAnchor:self.view.safeAreaLayoutGuide.heightAnchor constant:-60];
    // 优先级设置低一点，防止内容过多时冲突
    minHeightConstraint.priority = UILayoutPriorityDefaultLow;
    minHeightConstraint.active = YES;
}

#pragma mark - Helper Methods (辅助方法)

// 辅助方法：获取 iOS 系统圆体字
- (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight {
    UIFont *systemFont = [UIFont systemFontOfSize:size weight:weight];
    UIFontDescriptor *descriptor = [systemFont.fontDescriptor fontDescriptorWithDesign:UIFontDescriptorSystemDesignRounded];
    if (descriptor) {
        return [UIFont fontWithDescriptor:descriptor size:size];
    }
    return systemFont;
}

// 【核心修改】辅助方法：创建单个功能项视图 (包裹在圆角卡片中)
- (UIView *)createFeatureViewWithIcon:(NSString *)iconName title:(NSString *)title description:(NSString *)desc {
    
    // 1. 创建卡片容器视图 (Card View)
    UIView *cardView = [[UIView alloc] init];
    cardView.backgroundColor = [UIColor whiteColor]; // 卡片背景为白色，突出显示
    cardView.layer.cornerRadius = 20; // 设置大圆角
    // 关键：为了显示阴影，masksToBounds 必须为 NO，否则阴影会被裁切掉
    cardView.layer.masksToBounds = NO;
    
    // 2. 设置柔和的阴影
    cardView.layer.shadowColor = [kWarmCoffeeColor CGColor]; // 使用深咖啡色作为阴影色，比纯黑更柔和
    cardView.layer.shadowOpacity = 0.08; // 透明度低一点，淡淡的投影
    cardView.layer.shadowOffset = CGSizeMake(0, 4); // 向下偏移有一定的距离，营造悬浮感
    cardView.layer.shadowRadius = 12; // 模糊半径大一点，更柔和

    
    // --- 原有的内容构建逻辑开始 (保持不变) ---
    // 创建水平 StackView
    UIStackView *contentStack = [[UIStackView alloc] init];
    contentStack.axis = UILayoutConstraintAxisHorizontal;
    contentStack.alignment = UIStackViewAlignmentCenter; // 居中对齐
    contentStack.spacing = 12;
    contentStack.translatesAutoresizingMaskIntoConstraints = NO;
    
    // 左侧图标
    UIImage *iconImage = [[UIImage imageNamed:iconName] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *iconView = [[UIImageView alloc] initWithImage:iconImage];
    iconView.contentMode = UIViewContentModeScaleAspectFit;
    // 固定图标大小
    [NSLayoutConstraint activateConstraints:@[
        [iconView.widthAnchor constraintEqualToConstant:48],
        [iconView.heightAnchor constraintEqualToConstant:48]
    ]];
    [contentStack addArrangedSubview:iconView];
    
    // 右侧文字垂直 StackView
    UIStackView *textStack = [[UIStackView alloc] init];
    textStack.axis = UILayoutConstraintAxisVertical;
    textStack.spacing = 4;
    
    // 功能标题
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = title;
    titleLabel.font = [self roundedFontOfSize:18 weight:UIFontWeightBold];
    titleLabel.textColor = kWarmCoffeeColor;
    [textStack addArrangedSubview:titleLabel];
    
    // 功能描述
    UILabel *descLabel = [[UILabel alloc] init];
    descLabel.text = desc;
    descLabel.font = [self roundedFontOfSize:15 weight:UIFontWeightRegular];
    descLabel.textColor = [kWarmCoffeeColor colorWithAlphaComponent:0.8]; // 稍微淡一点
    descLabel.numberOfLines = 0; // 允许多行
    [textStack addArrangedSubview:descLabel];
    
    [contentStack addArrangedSubview:textStack];
    // --- 原有的内容构建逻辑结束 ---
    
    
    // 3. 将内容 StackView 添加到卡片视图中
    [cardView addSubview:contentStack];
    
    // 4. 设置内容在卡片内部的边距约束 (Padding)
    // 这非常重要，让内容不要紧贴卡片边缘
    NSLayoutConstraint *bottomConstraint = [contentStack.bottomAnchor constraintEqualToAnchor:cardView.bottomAnchor constant:-20];
    // 优先级设置低一点，避免在计算高度时产生冲突
    bottomConstraint.priority = UILayoutPriorityDefaultLow;

    [NSLayoutConstraint activateConstraints:@[
        [contentStack.topAnchor constraintEqualToAnchor:cardView.topAnchor constant:20], // 上边距 20
        [contentStack.leadingAnchor constraintEqualToAnchor:cardView.leadingAnchor constant:20], // 左边距 20
        [contentStack.trailingAnchor constraintEqualToAnchor:cardView.trailingAnchor constant:-20], // 右边距 20
        bottomConstraint // 下边距 20
    ]];
    
    // 返回封装好的卡片视图
    return cardView;
}

// 辅助方法：创建底部隐私提示视图
- (UIView *)createPrivacyView {
    UIStackView *stack = [[UIStackView alloc] init];
    stack.axis = UILayoutConstraintAxisHorizontal;
    stack.spacing = 8;
    stack.alignment = UIStackViewAlignmentCenter;
    
    // 小锁图标 (使用系统图标并染成咖啡色)
    UIImage *lockImg = [[UIImage systemImageNamed:@"lock.shield.fill"] imageWithTintColor:kWarmCoffeeColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    UIImageView *icon = [[UIImageView alloc] initWithImage:lockImg];
    [icon.widthAnchor constraintEqualToConstant:16].active = YES;
    [icon.heightAnchor constraintEqualToConstant:16].active = YES;
    [stack addArrangedSubview:icon];
    
    // 提示文字
    UILabel *label = [[UILabel alloc] init];
    label.text = @"您的数据仅存储在本地，我们重视您的隐私。";
    label.font = [self roundedFontOfSize:13 weight:UIFontWeightRegular];
    label.textColor = [kWarmCoffeeColor colorWithAlphaComponent:0.7];
    [stack addArrangedSubview:label];
    
    return stack;
}

#pragma mark - Actions

// 点击开始按钮的响应方法
- (void)startButtonTapped {
    NSLog(@"OC: 点击了开始按钮");
    // 通知代理 (如果代理存在并实现了方法)
    if (self.delegate && [self.delegate respondsToSelector:@selector(didTapStartButtonInOnboardingViewController:)]) {
        [self.delegate didTapStartButtonInOnboardingViewController:self];
    } else {
        // 如果没有设置代理，默认行为是关闭自己
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

@end
