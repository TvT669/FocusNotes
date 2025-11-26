//
//  CustomTabBarController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/26.
//

#import "CustomTabBarController.h"

// 定义温馨风格的颜色宏 (如果项目其他地方已经定义，可以 import 进来)
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
#define kWarmOffWhiteColor [UIColor colorWithRed:249/255.0 green:243/255.0 blue:234/255.0 alpha:1.0]

@interface CustomTabBarController ()
@end

@implementation CustomTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 设置基本样式 (颜色和字体)
    [self setupTabBarStyle];
}

// 这个方法在视图的子视图布局完成后调用，是修改 TabBar Frame 的最佳时机
- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    // 2. 设置悬浮胶囊样式 (圆角、阴影和位置)
    [self setupFloatingCapsuleStyle];
}

#pragma mark - Style Setup Methods

- (void)setupTabBarStyle {
    // 获取 TabBar appearance 对象 (iOS 13+)
    UITabBarAppearance *appearance = [[UITabBarAppearance alloc] init];
    [appearance configureWithOpaqueBackground];
    
    // 设置背景色为米白色
    appearance.backgroundColor = kWarmOffWhiteColor;
    
    // 去掉顶部的分割线/阴影线
    appearance.shadowImage = [UIImage new];
    appearance.shadowColor = [UIColor clearColor];
    
    // 设置未选中状态的图标和文字颜色 (深咖啡色)
    NSDictionary *normalAttributes = @{
        NSForegroundColorAttributeName: kWarmCoffeeColor,
        NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium] // 设置字体
    };
    appearance.stackedLayoutAppearance.normal.titleTextAttributes = normalAttributes;
    appearance.stackedLayoutAppearance.normal.iconColor = kWarmCoffeeColor;
    
    // 设置选中状态的图标和文字颜色 (温馨珊瑚色)
    NSDictionary *selectedAttributes = @{
        NSForegroundColorAttributeName: kWarmCoralColor,
        NSFontAttributeName: [UIFont systemFontOfSize:10 weight:UIFontWeightMedium]
    };
    appearance.stackedLayoutAppearance.selected.titleTextAttributes = selectedAttributes;
    appearance.stackedLayoutAppearance.selected.iconColor = kWarmCoralColor;
    
    // 应用外观设置
    self.tabBar.standardAppearance = appearance;
    // iOS 15+ 需要同时设置 scrollEdgeAppearance，否则在滚动边缘时样式会失效
    if (@available(iOS 15.0, *)) {
        self.tabBar.scrollEdgeAppearance = appearance;
    }
    
    // 设置全局的 Tint Color (影响选中图标)
    self.tabBar.tintColor = kWarmCoralColor;

}

- (void)setupFloatingCapsuleStyle {
    // 获取当前的 TabBar
    UITabBar *tabBar = self.tabBar;
    CGFloat capsuleHeight = 60.0;
    
    // --- 1. 设置圆角 ---
    tabBar.layer.masksToBounds = NO; // 必须设为 NO，否则阴影会被切掉
    tabBar.layer.cornerRadius = 30;  // 设置大圆角，形成胶囊状
    // 关键：只圆角化背景层，而不是整个 layer，否则内容也会被裁切
    tabBar.layer.maskedCorners = kCALayerMinXMinYCorner | kCALayerMaxXMinYCorner | kCALayerMinXMaxYCorner | kCALayerMaxXMaxYCorner;

    
    // --- 2. 设置柔和阴影 ---
    tabBar.layer.shadowColor = kWarmCoffeeColor.CGColor; // 使用深咖啡色阴影
    tabBar.layer.shadowOffset = CGSizeMake(0, 4);        // 向下偏移
    tabBar.layer.shadowRadius = 12;                      // 大模糊半径，柔和
    tabBar.layer.shadowOpacity = 0.15;                   // 低透明度
    
    
    // --- 3. 修改 Frame 使其悬浮 ---
    // 获取新的 Frame
    CGRect newFrame = tabBar.frame;
    
    // 设置水平边距 (左右各留多少空隙)
    CGFloat horizontalMargin = 70.0;
    // 设置底部边距 (距离屏幕底部多高)
    CGFloat bottomMargin = 10.0;
    // 考虑安全区域 (适配 iPhone X 等有 HomeBar 的机型)
    CGFloat safeAreaBottom = self.view.safeAreaInsets.bottom;
    
    // 重新计算宽度和 X 坐标
    newFrame.size.width = self.view.bounds.size.width - (horizontalMargin * 2);
    newFrame.origin.x = horizontalMargin;
    newFrame.size.height = capsuleHeight;
    
    // 重新计算 Y 坐标，使其向上浮动
    // 注意：原来的 Y 是贴底的，我们要把它往上提 bottomMargin 的距离
    // 如果有安全区域，可以根据需要决定是包含还是排除安全区域高度。这里我们选择在安全区域之上再浮动。
    newFrame.origin.y = self.view.bounds.size.height - newFrame.size.height - bottomMargin - safeAreaBottom;

    // 应用新的 Frame
    tabBar.frame = newFrame;
    
    // --- 4. 处理背景裁切问题 (高级技巧) ---
    // 直接设置 TabBar 的圆角和阴影有时会有问题，因为背景色的 layer 和阴影层可能冲突。
    // 一个更稳妥的做法是插入一个自定义的背景 Layer。
    
    // 移除系统背景，确保透明
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = self.tabBar.standardAppearance;
        appearance.backgroundColor = [UIColor clearColor];
        appearance.backgroundEffect = nil;
        self.tabBar.standardAppearance = appearance;
        if (@available(iOS 15.0, *)) {
            self.tabBar.scrollEdgeAppearance = appearance;
        }
    } else {
        [self.tabBar setBackgroundImage:[UIImage new]];
        [self.tabBar setShadowImage:[UIImage new]];
    }
    self.tabBar.backgroundColor = [UIColor clearColor];

    
    // 检查是否已经添加过背景 layer，避免重复添加
    CAShapeLayer *backgroundLayer = nil;
    for (CALayer *layer in self.tabBar.layer.sublayers) {
        if ([layer.name isEqualToString:@"CustomBackgroundLayer"]) {
            backgroundLayer = (CAShapeLayer *)layer;
            break;
        }
    }
    
    if (!backgroundLayer) {
        backgroundLayer = [CAShapeLayer layer];
        backgroundLayer.name = @"CustomBackgroundLayer";
        // 插入到最底层
        [self.tabBar.layer insertSublayer:backgroundLayer atIndex:0];
    }
    
    // 更新背景 layer 的路径和样式
    backgroundLayer.path = [UIBezierPath bezierPathWithRoundedRect:self.tabBar.bounds cornerRadius:30].CGPath;
    backgroundLayer.fillColor = kWarmOffWhiteColor.CGColor;
    
    backgroundLayer.shadowColor = kWarmCoffeeColor.CGColor;
    backgroundLayer.shadowOffset = CGSizeMake(0, 4);
    backgroundLayer.shadowRadius = 12;
    backgroundLayer.shadowOpacity = 0.15;
    
}

@end
