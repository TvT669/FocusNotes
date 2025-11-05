//
//  NoteModel.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteModel : NSObject
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *content;
@property (nonatomic, strong) NSDate *date;

- (instancetype)initWithTitle:(NSString *)title content:(NSString *)content;

@end

NS_ASSUME_NONNULL_END
