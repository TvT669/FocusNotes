//
//  NoteModel.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "NoteModel.h"

@implementation NoteModel
- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content {
    self = [super init];
    if (self) {
        _title = title;
        _content = content;
        _date = [NSDate date];
    }
    return self;
}

@end
