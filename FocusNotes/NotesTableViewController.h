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



@end

NS_ASSUME_NONNULL_END
