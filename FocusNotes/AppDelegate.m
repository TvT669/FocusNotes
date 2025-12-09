//
//  AppDelegate.m
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/4.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    // 【新增】启动 3 秒后检查更新
    // 延迟是为了不影响启动速度，并确保主界面已经显示出来，弹窗才不会报错
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self checkAppUpdate];
    });
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}

#pragma mark - 版本更新检测逻辑

- (void)checkAppUpdate {
    // 1. 获取当前 App 的本地信息
    NSDictionary *infoDict = [[NSBundle mainBundle] infoDictionary];
    NSString *currentVersion = [infoDict objectForKey:@"CFBundleShortVersionString"]; // 本地版本号，如 "1.0.0"
    NSString *bundleId = [infoDict objectForKey:@"CFBundleIdentifier"]; // Bundle ID，如 "com.bee.FocusNotes"
    
    // 如果无法获取 Bundle ID，直接返回
    if (!bundleId) return;
    
    // 2. 组装 iTunes Search API 请求地址
    // 注意：country=cn 代表中国区。如果App 是全球上架，可以去掉这个参数，或者根据系统语言动态设置
    NSString *urlString = [NSString stringWithFormat:@"https://itunes.apple.com/cn/lookup?bundleId=%@", bundleId];
    NSURL *url = [NSURL URLWithString:urlString];
    // 3. 发起网络请求 (异步)
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (error || !data) {
            NSLog(@"[Update] 检测更新失败: %@", error);
            return;
        }
        
        NSError *jsonError;
        NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
        
        if (jsonError) return;
        
        // 获取结果数组
        NSArray *results = jsonDict[@"results"];
        if (results.count > 0) {
            NSDictionary *appStoreInfo = results.firstObject;
            
            // 获取 App Store 上的版本号
            NSString *storeVersion = appStoreInfo[@"version"];
            // 获取 App Store 的下载链接
            NSString *trackViewUrl = appStoreInfo[@"trackViewUrl"];
            // 获取更新日志 (Release Notes)
            NSString *releaseNotes = appStoreInfo[@"releaseNotes"];
            
            NSLog(@"[Update] 当前版本: %@ | 商店版本: %@", currentVersion, storeVersion);
            
            // 4. 版本号比对 (使用 NumericSearch 确保 1.2.0 < 1.10.0)
            if ([currentVersion compare:storeVersion options:NSNumericSearch] == NSOrderedAscending) {
                
                // 5. 发现新版本，回到主线程弹出提示框
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self showUpdateAlertWithVersion:storeVersion notes:releaseNotes url:trackViewUrl];
                });
            } else {
                NSLog(@"[Update] 当前已是最新版本，无需更新");
            }
        } else {
            NSLog(@"[Update] 未在 App Store 找到此应用信息 (如果是新 App 刚提交尚未上架，这是正常的)");
        }
    }];
    
    [task resume];
}

// 弹出更新提示框
- (void)showUpdateAlertWithVersion:(NSString *)version notes:(NSString *)notes url:(NSString *)urlString {
    NSString *title = [NSString stringWithFormat:@"发现新版本 %@", version];
    // 这里的文案可以自定义，也可以直接显示 App Store 的 releaseNotes
    NSString *message = @"FocusNotes 有新功能啦！\n更新一下，让专注体验更丝滑～ 🌱";
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    
  
    if (@available(iOS 13.0, *)) {
        alert.overrideUserInterfaceStyle = UIUserInterfaceStyleLight;
    }
    
    // "立即更新" 按钮
    UIAlertAction *updateAction = [UIAlertAction actionWithTitle:@"立即更新"
                                                           style:UIAlertActionStyleDefault
                                                         handler:^(UIAlertAction * _Nonnull action) {
        // 跳转到 App Store
        NSURL *url = [NSURL URLWithString:urlString];
        if ([[UIApplication sharedApplication] canOpenURL:url]) {
            [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
        }
    }];
    
    // "稍后再说" 按钮 (App Store 审核要求必须有这个按钮，不能强制更新)
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"稍后再说"
                                                           style:UIAlertActionStyleCancel
                                                         handler:nil];
    
    [alert addAction:updateAction];
    [alert addAction:cancelAction];
    
    // 获取当前最顶层的 Window 来展示 Alert
    UIWindow *keyWindow = nil;
    if (@available(iOS 13.0, *)) {
        for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                for (UIWindow *window in scene.windows) {
                    if (window.isKeyWindow) {
                        keyWindow = window;
                        break;
                    }
                }
            }
        }
    } else {
        keyWindow = [UIApplication sharedApplication].keyWindow;
    }
    
    if (keyWindow) {
        UIViewController *rootVC = keyWindow.rootViewController;
        // 如果 rootVC 正在显示其他弹窗，循环找到最上层的控制器
        while (rootVC.presentedViewController) {
            rootVC = rootVC.presentedViewController;
        }
        [rootVC presentViewController:alert animated:YES completion:nil];
    }
}

@end
