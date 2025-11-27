//
//  NoteTableViewCell.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/5.
//

#import "NoteTableViewCell.h"
#define kWarmCoffeeColor [UIColor colorWithRed:74/255.0 green:64/255.0 blue:58/255.0 alpha:1.0]

@interface NoteTableViewCell ()
// 卡片容器视图 (承载背景色、圆角、阴影)
@property (nonatomic, strong) UIView *cardContainerView;

// UI 元素 (改为纯代码属性)
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *dateLabel;
@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation NoteTableViewCell
/**
-(void)configCell:(NoteModel *)note{
    self.title.text = note.titleName;
    self.content.text = note.contentText;
    self.date.text = note.dateText;
}
 */
- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self setupUI];
    }
    return self;
}
// 如果你是从 Storyboard 加载的 Cell，这个方法会被调用
- (void)awakeFromNib {
    [super awakeFromNib];
    // 这里可以清空 Storyboard 的原有内容，或者直接在 Storyboard 里把内容清空
    [self setupUI];
}
- (void)setupUI {
    // 1. 设置 Cell 本身为透明
    self.backgroundColor = [UIColor clearColor];
    self.contentView.backgroundColor = [UIColor clearColor];
    // 去掉选中时的灰色背景，卡片式设计通常不需要默认选中效果
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // --- 创建卡片容器视图 ---
    self.cardContainerView = [[UIView alloc] init];
    self.cardContainerView.translatesAutoresizingMaskIntoConstraints = NO;
    // 设置圆角
    self.cardContainerView.layer.cornerRadius = 20;
    // 设置阴影 (注意： masksToBounds 必须为 NO)
    self.cardContainerView.layer.masksToBounds = NO;
    self.cardContainerView.layer.shadowColor = kWarmCoffeeColor.CGColor;
    self.cardContainerView.layer.shadowOffset = CGSizeMake(0, 4);
    self.cardContainerView.layer.shadowRadius = 10;
    self.cardContainerView.layer.shadowOpacity = 0.1;
    
    [self.contentView addSubview:self.cardContainerView];
    
    // --- 初始化卡片内部元素 ---
    // 标题：粗圆体，深咖啡色
    self.titleLabel = [self createLabelWithFont:[self roundedFontOfSize:18 weight:UIFontWeightBold] color:kWarmCoffeeColor];
    
    // 日期：小号圆体，稍淡的咖啡色，右对齐
    self.dateLabel = [self createLabelWithFont:[self roundedFontOfSize:13 weight:UIFontWeightRegular] color:[kWarmCoffeeColor colorWithAlphaComponent:0.6]];
    self.dateLabel.textAlignment = NSTextAlignmentRight;
    
    // 内容预览：小号圆体，最多显示两行
    self.contentLabel = [self createLabelWithFont:[self roundedFontOfSize:15 weight:UIFontWeightRegular] color:[kWarmCoffeeColor colorWithAlphaComponent:0.8]];
    self.contentLabel.numberOfLines = 2;
    
    // 将元素添加到卡片容器
    [self.cardContainerView addSubview:self.titleLabel];
    [self.cardContainerView addSubview:self.dateLabel];
    [self.cardContainerView addSubview:self.contentLabel];
    
    // --- 设置 Auto Layout 约束 ---
    [self setupConstraints];
}
- (void)setupConstraints {
    // --- A. 卡片容器相对于 Cell contentView 的约束 (制造间距的核心!) ---
    CGFloat horizontalPadding = 20.0; // 左右边距
    CGFloat verticalPadding = 10.0;   // 上下边距 (实现 Cell 之间的间距)
    
    [NSLayoutConstraint activateConstraints:@[
        [self.cardContainerView.topAnchor constraintEqualToAnchor:self.contentView.topAnchor constant:verticalPadding],
        [self.cardContainerView.bottomAnchor constraintEqualToAnchor:self.contentView.bottomAnchor constant:-verticalPadding],
        [self.cardContainerView.leadingAnchor constraintEqualToAnchor:self.contentView.leadingAnchor constant:horizontalPadding],
        [self.cardContainerView.trailingAnchor constraintEqualToAnchor:self.contentView.trailingAnchor constant:-horizontalPadding]
    ]];
    
    // --- B. 卡片内部元素的约束 ---
    CGFloat innerPadding = 16.0;
    
    [NSLayoutConstraint activateConstraints:@[
        // 标题：左上
        [self.titleLabel.topAnchor constraintEqualToAnchor:self.cardContainerView.topAnchor constant:innerPadding],
        [self.titleLabel.leadingAnchor constraintEqualToAnchor:self.cardContainerView.leadingAnchor constant:innerPadding],
        
        // 日期：右上，与标题对齐
        [self.dateLabel.centerYAnchor constraintEqualToAnchor:self.titleLabel.centerYAnchor],
        [self.dateLabel.trailingAnchor constraintEqualToAnchor:self.cardContainerView.trailingAnchor constant:-innerPadding],
        // 防止标题和日期重叠，日期抗压缩优先级高
        [self.dateLabel.leadingAnchor constraintGreaterThanOrEqualToAnchor:self.titleLabel.trailingAnchor constant:8],
        
        // 内容预览：在标题下方，撑满宽度
        [self.contentLabel.topAnchor constraintEqualToAnchor:self.titleLabel.bottomAnchor constant:12],
        [self.contentLabel.leadingAnchor constraintEqualToAnchor:self.cardContainerView.leadingAnchor constant:innerPadding],
        [self.contentLabel.trailingAnchor constraintEqualToAnchor:self.cardContainerView.trailingAnchor constant:-innerPadding],
        // 关键：预览文本的底部约束决定了卡片的高度
        [self.contentLabel.bottomAnchor constraintLessThanOrEqualToAnchor:self.cardContainerView.bottomAnchor constant:-innerPadding]
    ]];
}
// 优化阴影性能，在布局完成后设置 shadowPath
- (void)layoutSubviews {
    [super layoutSubviews];
    self.cardContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRoundedRect:self.cardContainerView.bounds cornerRadius:self.cardContainerView.layer.cornerRadius].CGPath;
}
// 辅助方法：创建 Label
- (UILabel *)createLabelWithFont:(UIFont *)font color:(UIColor *)textColor {
    UILabel *label = [[UILabel alloc] init];
    label.font = font;
    label.textColor = textColor;
    label.translatesAutoresizingMaskIntoConstraints = NO;
    return label;
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

// 配置数据的新方法
- (void)configCell:(NoteModel *)note backgroundColor:(UIColor *)bgColor {
    self.cardContainerView.backgroundColor = bgColor;
    self.titleLabel.text = note.titleName;
    self.contentLabel.text = note.contentText;
    // 这里假设 note.dateText 已经是格式化好的字符串，如果不是，需要先格式化
    self.dateLabel.text = note.dateText;
}
@end
