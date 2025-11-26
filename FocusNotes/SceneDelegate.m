//
//  SceneDelegate.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "SceneDelegate.h"
#import "CustomOnboardingViewController.h" // 引入自定义欢迎页
#import <UIKit/UIKit.h>

@interface SceneDelegate () <CustomOnboardingViewControllerDelegate> // 遵守自定义代理协议

@end

@implementation SceneDelegate


- (void)scene:(UIScene *)scene willConnectToSession:(UISceneSession *)session options:(UISceneConnectionOptions *)connectionOptions {
    if (![scene isKindOfClass:[UIWindowScene class]]) { return; }
    UIWindowScene *windowScene = (UIWindowScene *)scene;
    self.window = [[UIWindow alloc] initWithWindowScene:windowScene];

    BOOL hasCompletedOnboarding = [[NSUserDefaults standardUserDefaults] boolForKey:@"hasCompletedOnboarding"];
    if (!hasCompletedOnboarding) {
        // 启动时直接显示自定义欢迎页作为根控制器
        CustomOnboardingViewController *onboardingVC = [[CustomOnboardingViewController alloc] init];
        onboardingVC.delegate = self; // 设置代理
        self.window.rootViewController = onboardingVC;
        [self.window makeKeyAndVisible];
    } else {
        // 直接进入主界面（Storyboard 初始控制器）
        UIViewController *main = [self createMainRootController];
        self.window.rootViewController = main;
        [self.window makeKeyAndVisible];
    }
}


- (void)sceneDidDisconnect:(UIScene *)scene {
    // Called as the scene is being released by the system.
    // This occurs shortly after the scene enters the background, or when its session is discarded.
    // Release any resources associated with this scene that can be re-created the next time the scene connects.
    // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
}


- (void)sceneDidBecomeActive:(UIScene *)scene {
    // Called when the scene has moved from an inactive state to an active state.
    // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
}


- (void)sceneWillResignActive:(UIScene *)scene {
    // Called when the scene will move from an active state to an inactive state.
    // This may occur due to temporary interruptions (ex. an incoming phone call).
}


- (void)sceneWillEnterForeground:(UIScene *)scene {
    // Called as the scene transitions from the background to the foreground.
    // Use this method to undo the changes made on entering the background.
}


- (void)sceneDidEnterBackground:(UIScene *)scene {
    // Called as the scene transitions from the foreground to the background.
    // Use this method to save data, release shared resources, and store enough scene-specific state information
    // to restore the scene back to its current state.
}


#pragma mark - CustomOnboardingViewControllerDelegate

- (void)didTapStartButtonInOnboardingViewController:(CustomOnboardingViewController *)viewController {
    // 标记完成
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasCompletedOnboarding"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    // 切换到主界面（淡入过渡）
    UIViewController *main = [self createMainRootController];
    UIWindow *window = self.window;
    [UIView transitionWithView:window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ window.rootViewController = main; }
                    completion:nil];
}

- (UIViewController *)createMainRootController {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [sb instantiateInitialViewController];
    return vc ?: [UIViewController new];
}

@end
