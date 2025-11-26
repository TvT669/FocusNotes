//
//  CustomOnboardingViewController.h
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/26.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CustomOnboardingViewController;

// 定义一个代理协议，用来告诉外界用户点击了开始按钮
@protocol CustomOnboardingViewControllerDelegate <NSObject>
- (void)didTapStartButtonInOnboardingViewController:(CustomOnboardingViewController *)vc;
@end

@interface CustomOnboardingViewController : UIViewController
// 代理属性，使用 weak 防止循环引用
@property (nonatomic, weak) id<CustomOnboardingViewControllerDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
