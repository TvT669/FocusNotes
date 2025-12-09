//
//  NoteModel.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NoteModel : NSObject <NSSecureCoding>
@property (nonatomic, copy) NSString *titleName;
@property (nonatomic, copy) NSString *contentText;
@property (nonatomic, copy) NSString *dateText;



@property (nonatomic, strong) NSMutableArray *notes;



@end

NS_ASSUME_NONNULL_END
