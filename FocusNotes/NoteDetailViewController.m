//
//  NoteDetailViewController.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import "NoteDetailViewController.h"

@interface NoteDetailViewController ()

@end

@implementation NoteDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    // 如果有要编辑的笔记，填充数据
      if (self.noteToEdit) {
          self.noteText.text = self.noteToEdit.contentText;
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
    // 获取文本框中的内容
        NSString *content = self.noteText.text ?: @"";
        
        // 更新或创建笔记
        if (self.noteToEdit) {
            // 编辑现有笔记
            self.noteToEdit.contentText = content;
        } else {
            // 创建新笔记
            NoteModel *newNote = [[NoteModel alloc] init];
            newNote.contentText = content;
            newNote.dateText = [NSDate date]; // 设置创建时间
            // 注意：你可能还需要设置 titleName，这里假设你有另一个输入框
        }
        
        // 关闭详情页，返回列表
        [self.navigationController popViewControllerAnimated:YES];
        
    
}

- (IBAction)cancel:(id)sender {
    // 只是返回，不保存任何更改
       [self.navigationController popViewControllerAnimated:YES];
    
}
-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([segue.identifier isEqualToString:@"showNoteDetail"]){
        NoteDetailViewController *detailVC = segue.destinationViewController;
        detailVC.noteToEdit = sender;
        
    }
}
@end
