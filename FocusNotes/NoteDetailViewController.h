//
//  NoteDetailViewController.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/14.
//

#import <UIKit/UIKit.h>
#import "NoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoteDetailViewController : UIViewController
@property(nonatomic,strong,nullable) NoteModel *noteToEdit;
@property (weak, nonatomic) IBOutlet UITextView *noteText;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;

@end

NS_ASSUME_NONNULL_END
