//
//  NotesTableViewController.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NotesTableViewController : UITableViewController
@property (strong, nonatomic) NSMutableArray *notes;
- (void)saveNotesToUserDefaults;

// 从其他页面（如 TimeVC）调用，直接打开“新建笔记”界面
- (void)openCreateNote;



@end

NS_ASSUME_NONNULL_END
