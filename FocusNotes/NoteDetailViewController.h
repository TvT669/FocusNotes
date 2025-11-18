//
//  NoteDetailViewController.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import <UIKit/UIKit.h>
@class NoteModel;

typedef NS_ENUM(NSUInteger, NoteDetailMode) {
	NoteDetailModeCreate = 0,
	NoteDetailModeEdit
};

@interface NoteDetailViewController : UIViewController
// 进入页面时传入：编辑时为已有模型；新建为 nil
@property (nonatomic, strong) NoteModel * _Nullable noteToEdit;
// 当前模式：创建/编辑
@property (nonatomic, assign) NoteDetailMode mode;
// 保存回调：将结果回写给列表页
@property (nonatomic, copy) void (^ _Nullable onSave)(NoteModel * _Nullable note, BOOL isNew);

// UI（Storyboard 连接）
- (IBAction)save:(id _Nullable )sender;
- (IBAction)cancel:(id _Nullable )sender;
@property (weak, nonatomic) IBOutlet UITextView *noteText;

@end


