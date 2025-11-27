//
//  NoteDetailViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import "NoteDetailViewController.h"
#import "NoteModel.h"

// --- 定义宏：温馨风格颜色 ---
#define kWarmCoffeeColor [UIColor colorWithRed:110/255.0 green:93/255.0 blue:69/255.0 alpha:1.0]
#define kWarmCoralColor [UIColor colorWithRed:255/255.0 green:140/255.0 blue:148/255.0 alpha:1.0]
#define kWarmOffWhiteColor [UIColor colorWithRed:249/255.0 green:243/255.0 blue:234/255.0 alpha:1.0]

@interface NoteDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

// 卡片容器视图
@property (nonatomic, strong) UIView *cardView;
// 装饰插图
@property (nonatomic, strong) UIImageView *decorationImageView;


// 私有辅助方法
- (NSString *)generatedDefaultTitle;
- (NSString *)fallbackTitleFromContent:(NSString *)content;
// 新增 UI 设置方法
- (void)setupUI;
- (UIFont *)roundedFontOfSize:(CGFloat)size weight:(UIFontWeight)weight;

@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // 1. 进行 UI 风格化改造
    [self setupUI];
    
    // 2. 设置代理
    self.titleField.delegate = self;
    self.noteText.delegate = self;

    // 3. 根据模式填充数据
    if (self.mode == NoteDetailModeEdit && self.noteToEdit) {
        // 编辑模式：填充原数据
        self.title = @"编辑笔记";
        self.titleField.text = self.noteToEdit.titleName ?: @"";
        self.noteText.text = self.noteToEdit.contentText ?: @"";
    } else {
        // 新建模式：标题留空，仅占位符
        self.title = @"新建笔记";
        self.titleField.placeholder = @"标题";
        self.titleField.text = @""; // 保证为空，用户自行输入
        self.noteText.text = @".";
    }
}

#pragma mark - UI Setup (核心改造部分)

- (void)setupUI {
    // --- A. 设置背景 ---
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"warm_bokeh_bg"]];
    bgImageView.contentMode = UIViewContentModeScaleAspectFill;
    bgImageView.frame = self.view.bounds;
    bgImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:bgImageView atIndex:0];
    
    // --- B. 导航栏定制 ---
    [self setupNavigationBar];
    
    // --- C. 创建卡片容器 ---
    self.cardView = [[UIView alloc] init];
    self.cardView.backgroundColor = kWarmOffWhiteColor; // 米白色信纸背景
    self.cardView.layer.cornerRadius = 20; // 大圆角
    // 添加柔和阴影
    self.cardView.layer.shadowColor = kWarmCoffeeColor.CGColor;
    self.cardView.layer.shadowOffset = CGSizeMake(0, 4);
    self.cardView.layer.shadowRadius = 12;
    self.cardView.layer.shadowOpacity = 0.1;
    self.cardView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.cardView];
    
    // --- D. 迁移现有组件到卡片中 ---
    // 1. 迁移标题输入框
    [self.titleField removeFromSuperview];
    [self.cardView addSubview:self.titleField];
    [self styleTextField:self.titleField];
    self.titleField.translatesAutoresizingMaskIntoConstraints = NO;
    [self styleTextField:self.titleField];
    
    // 3. 迁移内容文本框
    [self.noteText removeFromSuperview];
    [self.cardView addSubview:self.noteText];
    [self styleTextView:self.noteText];
    self.noteText.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self styleTextView:self.noteText];
    // --- E. 添加装饰插图 ---
    // 假设你有一个名为 "icon_coffee_cup" 的图片素材
    UIImage *decorationImage = [UIImage imageNamed:@"icon_coffee_cup"];
    if (decorationImage) {
        self.decorationImageView = [[UIImageView alloc] initWithImage:decorationImage];
        self.decorationImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.decorationImageView.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置一定的透明度，使其不喧宾夺主
        self.decorationImageView.alpha = 0.8;
        [self.cardView addSubview:self.decorationImageView];
        // 确保插图在文本框下方，不遮挡文字
        [self.cardView sendSubviewToBack:self.decorationImageView];
    }
    
    // --- F. 设置 Auto Layout 约束 ---
    [self setupConstraints];
}

- (void)setupNavigationBar {
    // 设置标题属性 (深咖啡色圆体字)
    self.navigationController.navigationBar.titleTextAttributes = @{
        NSForegroundColorAttributeName: kWarmCoffeeColor,
        NSFontAttributeName: [self roundedFontOfSize:18 weight:UIFontWeightBold]
    };
    
    // 设置左右按钮颜色为珊瑚色
    self.navigationController.navigationBar.tintColor = kWarmCoralColor;
    
    // 导航栏透明化
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    self.navigationController.navigationBar.translucent = YES;
}

- (void)styleTextField:(UITextField *)tf {
    tf.borderStyle = UITextBorderStyleNone; // 去掉默认边框
    tf.font = [self roundedFontOfSize:20 weight:UIFontWeightBold];
    tf.textColor = kWarmCoffeeColor;
    // 设置光标颜色
    tf.tintColor = kWarmCoralColor;
    // 设置占位符颜色 (需要用 attributedPlaceholder)
    NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:tf.placeholder ?: @"标题" attributes:@{NSForegroundColorAttributeName: [kWarmCoffeeColor colorWithAlphaComponent:0.5]}];
    tf.attributedPlaceholder = placeholder;
}

- (void)styleTextView:(UITextView *)tv {
    tv.backgroundColor = [UIColor clearColor]; // 透明背景
    tv.font = [self roundedFontOfSize:16 weight:UIFontWeightRegular];
    tv.textColor = kWarmCoffeeColor;
    tv.tintColor = kWarmCoralColor;
    // 增加一些内边距，让文字不贴边
    tv.textContainerInset = UIEdgeInsetsMake(10, 5, 10, 5);
}

- (void)setupConstraints {
    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    CGFloat cardMargin = 20.0;
    CGFloat innerPadding = 20.0;
    
    [NSLayoutConstraint activateConstraints:@[
        // 1. 卡片容器约束 (保持不变)
        [self.cardView.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:cardMargin],
        [self.cardView.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:cardMargin],
        [self.cardView.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-cardMargin],
        // 卡片底部距离屏幕底部有一定距离，可以根据需要调整
        [self.cardView.bottomAnchor constraintEqualToAnchor:safeArea.bottomAnchor constant:-cardMargin * 2],
        
        // 2. 标题输入框约束 (修改高度)
        [self.titleField.topAnchor constraintEqualToAnchor:self.cardView.topAnchor constant:innerPadding],
        [self.titleField.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:innerPadding],
        [self.titleField.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-innerPadding],
        // 【修改点 1】：将高度从 20 增加到 40，让输入框更舒适
        [self.titleField.heightAnchor constraintEqualToConstant:40],
        
        // 4. 内容文本框约束 (修改顶部间距)
        // 【修改点 3】：将顶部间距从 10 增加到 12，让内容区域与分割线稍微拉开一点距离
        [self.noteText.topAnchor constraintEqualToAnchor:self.titleField.bottomAnchor constant:12],
        [self.noteText.leadingAnchor constraintEqualToAnchor:self.cardView.leadingAnchor constant:innerPadding - 5], // TextView 自带 padding，稍微减少一点
        [self.noteText.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-(innerPadding - 5)],
        [self.noteText.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-innerPadding],
        
        // 5. 装饰插图约束 (右下角) (保持不变)
        [self.decorationImageView.trailingAnchor constraintEqualToAnchor:self.cardView.trailingAnchor constant:-15],
        [self.decorationImageView.bottomAnchor constraintEqualToAnchor:self.cardView.bottomAnchor constant:-15],
        [self.decorationImageView.widthAnchor constraintEqualToConstant:60],
        [self.decorationImageView.heightAnchor constraintEqualToConstant:60],
    ]];
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


#pragma mark - Actions (保持不变)

- (IBAction)save:(id)sender {
    NSString *content = self.noteText.text ?: @"";
    NSString *rawTitle = self.titleField.text ?: @"";
    NSString *trimTitle = [rawTitle stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

    BOOL isNew = (self.mode == NoteDetailModeCreate || self.noteToEdit == nil);
    NoteModel *target = self.noteToEdit;
    if (!target) {
        target = [[NoteModel alloc] init];
    }

    // 标题优先使用用户输入；为空时尝试用内容首行；仍为空则使用时间默认标题
    NSString *finalTitle = trimTitle.length ? trimTitle : [self fallbackTitleFromContent:content];
    if (finalTitle.length == 0) {
        finalTitle = [self.generatedDefaultTitle copy];
    }

    target.titleName = finalTitle;
    target.contentText = content;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"yyyy-MM-dd HH:mm";
    target.dateText = [df stringFromDate:[NSDate date]];

    if (self.onSave) {
        self.onSave(target, isNew);
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)cancel:(id)sender {
    // 只是返回，不保存任何更改
       [self.navigationController popViewControllerAnimated:YES];
    
}

#pragma mark - Helpers (保持不变)

- (NSString *)generatedDefaultTitle {
    NSDateFormatter *tf = [[NSDateFormatter alloc] init];
    tf.dateFormat = @"MM-dd HH:mm";
    return [NSString stringWithFormat:@"新笔记 %@", [tf stringFromDate:[NSDate date]]];
}

- (NSString *)fallbackTitleFromContent:(NSString *)content {
    NSString *trim = [content stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (trim.length == 0) return @"";
    NSString *firstLine = [trim componentsSeparatedByCharactersInSet:[NSCharacterSet newlineCharacterSet]].firstObject;
    // 限制长度避免过长
    if (firstLine.length > 30) {
        firstLine = [[firstLine substringToIndex:30] stringByAppendingString:@"…"];
    }
    return firstLine;
}

#pragma mark - UITextFieldDelegate (保持不变)
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate (保持不变)
- (void)textViewDidChange:(UITextView *)textView {
    // 如果是新建且标题还空，动态预填内容第一行（不覆盖用户已输入的标题）
    if (self.mode == NoteDetailModeCreate && (self.titleField.text.length == 0)) {
        NSString *candidate = [self fallbackTitleFromContent:textView.text];
        // 仅在尚未输入且存在内容首行时显示（不保存，用户可手动修改）
        if (candidate.length) {
            // 需要重新设置 attributedPlaceholder 以保持颜色
            NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:candidate attributes:@{NSForegroundColorAttributeName: [kWarmCoffeeColor colorWithAlphaComponent:0.5]}];
            self.titleField.attributedPlaceholder = placeholder;
        } else {
             NSAttributedString *placeholder = [[NSAttributedString alloc] initWithString:@"标题" attributes:@{NSForegroundColorAttributeName: [kWarmCoffeeColor colorWithAlphaComponent:0.5]}];
            self.titleField.attributedPlaceholder = placeholder;
        }
    }
}

@end
