//
//  NoteTableViewCell.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/5.
//

#import <UIKit/UIKit.h>
#import "NoteModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface NoteTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *content;
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *date;

-(void)configCell:(NoteModel *)note;

@end

NS_ASSUME_NONNULL_END
