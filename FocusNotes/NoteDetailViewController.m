//
//  NoteDetailViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import "NoteDetailViewController.h"
#import "NoteModel.h"

@interface NoteDetailViewController () <UITextFieldDelegate, UITextViewDelegate>

// 私有辅助方法
- (NSString *)generatedDefaultTitle;
- (NSString *)fallbackTitleFromContent:(NSString *)content;

@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.titleField.delegate = self;
    self.noteText.delegate = self;

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
// 不在详情页里处理自身的 segue；由列表页设置 mode 与回调

#pragma mark - Helpers

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

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UITextViewDelegate (可选：编辑时动态做事)
- (void)textViewDidChange:(UITextView *)textView {
    // 如果是新建且标题还空，动态预填内容第一行（不覆盖用户已输入的标题）
    if (self.mode == NoteDetailModeCreate && (self.titleField.text.length == 0)) {
        NSString *candidate = [self fallbackTitleFromContent:textView.text];
        // 仅在尚未输入且存在内容首行时显示（不保存，用户可手动修改）
        if (candidate.length) {
            self.titleField.placeholder = candidate; // 用 placeholder 不干扰真正标题
        } else {
            self.titleField.placeholder = @"标题";
        }
    }
}

@end
