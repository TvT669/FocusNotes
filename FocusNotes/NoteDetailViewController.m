//
//  NoteDetailViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import "NoteDetailViewController.h"
#import "NoteModel.h"

@interface NoteDetailViewController ()

@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 标题及初始数据
    if (self.mode == NoteDetailModeEdit && self.noteToEdit) {
        self.title = @"编辑笔记";
        self.noteText.text = self.noteToEdit.contentText ?: @"";
    } else {
        self.title = @"新建笔记";
        self.noteText.text = @"";
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)save:(id)sender {
    NSString *content = self.noteText.text ?: @"";

    BOOL isNew = (self.mode == NoteDetailModeCreate || self.noteToEdit == nil);
    NoteModel *target = self.noteToEdit;
    if (!target) {
        target = [[NoteModel alloc] init];
        // 默认标题
        NSDateFormatter *tf = [[NSDateFormatter alloc] init];
        tf.dateFormat = @"MM-dd HH:mm";
        target.titleName = [NSString stringWithFormat:@"新笔记 %@", [tf stringFromDate:[NSDate date]]];
    }
    target.contentText = content;
    // 更新时间字符串
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
// 不在详情页里处理自身的 segue；由列表页设置 mode 与回调

@end
