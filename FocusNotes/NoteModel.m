//
//  NoteModel.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "NoteModel.h"
@interface NoteModel()
@property (strong, nonatomic) NSArray *contents;
@property (strong, nonatomic) NSArray *titles;
@property (strong, nonatomic) NSArray *dates;
@end

@implementation NoteModel
// 1. 开启安全编码支持 (必须返回 YES)
+ (BOOL)supportsSecureCoding {
    return YES;
}

// 2. 归档：告诉系统如何把对象变成二进制数据 (保存时调用)
- (void)encodeWithCoder:(NSCoder *)coder {
    // 把属性以 Key-Value 的形式存起来
    [coder encodeObject:self.titleName forKey:@"titleName"];
    [coder encodeObject:self.contentText forKey:@"contentText"];
    [coder encodeObject:self.dateText forKey:@"dateText"];
}

// 3. 解档：告诉系统如何把二进制数据变回对象 (读取时调用)
- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super init];
    if (self) {
        // 使用 decodeObjectOfClass 进行安全解码
        self.titleName = [coder decodeObjectOfClass:[NSString class] forKey:@"titleName"];
        self.contentText = [coder decodeObjectOfClass:[NSString class] forKey:@"contentText"];
        self.dateText = [coder decodeObjectOfClass:[NSString class] forKey:@"dateText"];
        
        // 防空处理：如果解档出来是空的（比如旧数据），给个默认值，防止崩溃
        if (!self.titleName) self.titleName = @"无标题";
        if (!self.contentText) self.contentText = @"";
        // 如果没有日期，默认给当前时间
        if (!self.dateText) {
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm";
            self.dateText = [formatter stringFromDate:[NSDate date]];
        }
    }
    return self;
}
-(NSMutableArray *)notes{
    if(_notes == nil){
        _notes = [NSMutableArray array];
        for(int i = 0; i<self.titles.count;i++){
            NoteModel *note = [[NoteModel alloc]init];
            note.titleName = self.titles[i];
            note.contentText = self.contents[i];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            formatter.dateFormat = @"yyyy-MM-dd HH:mm"; // 与 NoteDetailViewController 保持一致
            note.dateText = [formatter stringFromDate:self.dates[i]];
            [_notes addObject:note];
        }
    }
    return _notes;
}

-(NSArray *)titles{
    if(_titles == nil){
        _titles = @[@"第一篇笔记"];
        
    }
    return _titles;
}
-(NSArray *)contents{
    if(_contents == nil){
        _contents = @[@"写下你的第一篇笔记内容"];
        
    }
    return _contents;
}
-(NSArray *)dates{
    if(_dates == nil){
        _dates = @[
                [self dateFromString:@"2025年5月28日"]
                
           ];
        
    }
    return _dates;
}
// 新增日期转换方法
- (NSDate *)dateFromString:(NSString *)dateString {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    return [formatter dateFromString:dateString];
}
@end
