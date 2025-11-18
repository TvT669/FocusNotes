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
        _titles = @[@"第一篇笔记",@"学习计划",@"购物清单"];
        
    }
    return _titles;
}
-(NSArray *)contents{
    if(_contents == nil){
        _contents = @[@"这是我的第一篇笔记内容",@"今天要学习 iOS 开发",@"牛奶、面包、鸡蛋"];
        
    }
    return _contents;
}
-(NSArray *)dates{
    if(_dates == nil){
        _dates = @[
                [self dateFromString:@"2025年5月28日"],
                [self dateFromString:@"2025年6月8日"],
                [self dateFromString:@"2025年7月14日"]
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
