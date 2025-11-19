//
//  OnboardingManager.swift
//  FocusNotes
//
//  Created by 珠穆朗玛小蜜蜂 on 2025/11/19.
//

import UIKit
import UIOnboarding

@objc class OnboardingManager: NSObject {

    // 代理桥接：把 Swift 协议回调转发给任意 OC/Swift 对象（只要实现 didFinishOnboarding:）
    private final class OnboardingProxy: NSObject, UIOnboardingViewControllerDelegate {
        weak var target: AnyObject?
        func didFinishOnboarding(onboardingViewController: UIOnboardingViewController) {
            let sel = Selector(("didFinishOnboarding:"))
            if let t = target, t.responds(to: sel) {
                _ = t.perform(sel, with: onboardingViewController)
            }
        }
    }

    @MainActor @objc static func createOnboardingViewController(delegate: Any) -> UIViewController {
        
        // 1. 设置图标 (尝试获取 App 图标，如果没有则使用默认占位图)
        let icon = Bundle.main.appIcon ?? UIImage(systemName: "timer")!
        
        // 2. 设置标题
        let firstTitle = NSMutableAttributedString(string: "欢迎使用", attributes: [
            .foregroundColor: UIColor.label,
            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ])
        let secondTitle = NSMutableAttributedString(string: "FocusNotes", attributes: [
            .foregroundColor: UIColor.systemRed, // 番茄钟通常用红色
            .font: UIFont.systemFont(ofSize: 40, weight: .bold)
        ])
        
        // 3. 设置功能列表 (结合你的 App 功能)
        let features: [UIOnboardingFeature] = [
            .init(icon: UIImage(systemName: "timer")!,
                  title: "番茄专注",
                  description: "基于番茄工作法，帮助你保持专注，提升效率。"),
            .init(icon: UIImage(systemName: "note.text")!,
                  title: "快速记录",
                  description: "完成专注后自动提示记录笔记，捕捉灵感瞬间。"),
            .init(icon: UIImage(systemName: "chart.bar.fill")!,
                  title: "回顾统计",
                  description: "清晰的时间统计，让你看见每一分钟的价值。")
        ]
        
        // 4. 设置底部提示
        let notice = UIOnboardingTextViewConfiguration(
            icon: UIImage(systemName: "lock.shield")!,
            text: "您的数据仅存储在本地，我们重视您的隐私。",
            linkTitle: "",
            link: "",
            linkColor: .systemRed
        )
        
        // 5. 设置按钮
        let button = UIOnboardingButtonConfiguration(
            title: "开启专注之旅",
            titleColor: .white, // 显式设置文字颜色
            backgroundColor: .systemRed // 与标题颜色呼应
        )
        
        // 6. 组装配置
        let config = UIOnboardingViewConfiguration(
            appIcon: icon,
            firstTitleLine: firstTitle,
            secondTitleLine: secondTitle,
            features: features,
            textViewConfiguration: notice,
            buttonConfiguration: button
        )
        
        // 7. 创建并返回控制器
        let onboardingVC = UIOnboardingViewController(withConfiguration: config)
        // 使用代理桥接，避免 OC 必须显式声明遵循 Swift 协议
        let proxy = OnboardingProxy()
        proxy.target = delegate as AnyObject
        onboardingVC.delegate = proxy
        // 关联生命周期，避免 proxy 被释放
        objc_setAssociatedObject(onboardingVC, Unmanaged.passUnretained(onboardingVC).toOpaque(), proxy, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return onboardingVC
    }
}
