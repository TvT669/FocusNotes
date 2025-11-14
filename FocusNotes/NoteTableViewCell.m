//
//  NoteTableViewCell.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/5.
//

#import "NoteTableViewCell.h"

@implementation NoteTableViewCell

-(void)configCell:(NoteModel *)note{
    self.title.text = note.titleName;
    self.content.text = note.contentText;
    self.date.text = note.dateText;
}

@end
