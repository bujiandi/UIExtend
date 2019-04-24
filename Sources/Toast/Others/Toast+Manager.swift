//
//  Toast+Make.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/20.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout


extension Toast {
    
    /// 已移除的消息管理器
    public static let removeManager = ToastManager<ToastBaseTask>(UIWindow.Level.normal, animate: removeAnimate)
    
    /// 短暂提示消息管理器 in alertWindow auto dismiss
    public static let momentManager = ToastManager<ToastMoment>(UIWindow.Level.alert + 10, animate: momentAnimate)

    /// 顶部提示消息管理器 in alertWindow auto dismiss
    public static let noticeManager = ToastManager<ToastNotice>(UIWindow.Level.alert - 20, animate: noticeAnimate)
    public static var notice:ToastNotice?
    
    /// 气泡提示消息管理器 in statusBarWindow like popover
    public static let bubbleManager = ToastManager<ToastOverlay>(UIWindow.Level.statusBar + 30, damping: setting.animBubbleDamping, animate: overlayAnimate)
    public static var bubble:ToastBubble? { return bubbleManager.queue.first as? ToastBubble }
    
    /// 活动提示消息管理器 in statusBarWindow is custom view
    public static let activeManager = ToastManager<ToastOverlay>(UIWindow.Level.statusBar + 20, damping: setting.animActiveDamping, animate: overlayAnimate)
    public static var active:ToastActive? { return activeManager.queue.first as? ToastActive }
    
    /// 底部交互消息管理器 in alertWindow only once at screen top or bottom and can tapped
    public static let dialogManager = ToastManager<ToastOverlay>(UIWindow.Level.statusBar + 10, animate: overlayAnimate)
    public static var dialog:ToastDialog?

    
    /// 定制提示消息管理器 in statusBarWindow is custom view
    public static let customManager = ToastManager<ToastOverlay>(UIWindow.Level.normal + 10, damping: setting.animCustomDamping, animate: overlayAnimate)
    public static var custom:ToastCustom? { return customManager.queue.first as? ToastCustom }
    
  
    public static var defaultAttributes:[NSAttributedString.Key : Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        
        paragraphStyle.alignment = .justified
        paragraphStyle.lineSpacing = 1
        paragraphStyle.lineHeightMultiple = 1.02
        paragraphStyle.lineBreakMode = .byTruncatingTail
        
        return [.kern:1, .paragraphStyle:paragraphStyle]
    }
    
    /// 常用文本显示样式
    public static func attributeString(by text:String) -> NSAttributedString {
        return NSAttributedString(string: text, attributes: defaultAttributes)
    }
    // MARK: - 创建背景视图
    public enum BackgroundStyle {
        case alpha(CGFloat)
        case effect(UIBlurEffect.Style)
        case custom(UIView)
    }
    
    /// 常用视图创建
    public static func createView(by style:BackgroundStyle) -> UIView {
        let view:UIView!
        switch style {
        case .alpha (let value):
            let cv = CornerView()
            cv.cornerRadius = setting.cornerRadius
            cv.borderWidth = setting.borderWidth
            cv.borderColor = setting.borderColor
            view = cv
            view.backgroundColor = UIColor(white: 0.2, alpha: value)
        case .effect(let value):
            let blur = UIBlurEffect(style: value)
            view = UIVisualEffectView(effect: blur)
        case .custom(let value):
            view = value
        }
        return view
    }
    
    /// 获取显示级别更低的window
    internal static func getLowWindow(by window:UIWindow?) -> UIWindow? {
        
        var isLowSelf:Bool = false
        for subWindow in UIApplication.shared.windows.reversed() {
            // 还要排除键盘窗口
            if isLowSelf, !subWindow.isHidden, subWindow.isUserInteractionEnabled, NSStringFromClass(subWindow.classForCoder) != "UITextEffectsWindow" {
                return subWindow
            } else if subWindow === window {
                isLowSelf = true
            }
        }
        return UIApplication.shared.keyWindow ?? UIApplication.shared.windows[0]
    }

}
