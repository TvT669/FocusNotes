//
//  TimeSelectionViewController.h
//  FocusNotes
//
//  Created by GitHub Copilot on 2025/11/27.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeSelectionViewController : UIViewController

@property (nonatomic, copy) void (^timeSelectedBlock)(NSInteger seconds);

@end

NS_ASSUME_NONNULL_END
