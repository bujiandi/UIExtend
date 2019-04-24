//
//  Toast.swift
//  Toast
//
//  Created by bujiandi on 2017/8/17.
//  Copyright © 2017 bujiandi. All rights reserved.
//

import UIKit

public struct Toast {
    
    
    /// 1像素
    public static let onePixel = 1 / UIScreen.main.scale
    
    /// Toast 默认配置
    public static var setting:ToastSetting = ToastSetting()
    
    // MARK: - moment text task
    /// 自动消失的富文本提示
    public static func moment(rich: NSAttributedString) -> ToastMoment {
        let back = createView(by: .alpha(0.7))
        back.layer.shadowColor = UIColor(white: 0.2, alpha: 1).cgColor
        back.layer.shadowRadius = 3
        back.layer.shadowOpacity = 0.8
        back.layer.shadowOffset = CGSize(width: 1, height: 1)
        return ToastMoment(rich: rich, container: back)
    }
    /// 自动消失的文本提示
    public static func moment(text: String) -> ToastMoment {
        return moment(rich: attributeString(by: text))
    }
    
    // MARK: - notice text task
    /// 顶部可交互的富文本提示
    public static func notice(rich: NSAttributedString) -> ToastNotice {
        let back = UIView()
        back.backgroundColor = UIColor.clear
        let task = ToastNotice(rich: rich, container: back)
        task.label.textColor = UIColor(white: 51/255.0, alpha: 1)
        return task
    }
    /// 顶部可交互的文本提示
    public static func notice(text: String) -> ToastNotice {
        return notice(rich: attributeString(by: text))
    }
    
    // MARK: - dialog text task
    /// 类似于Custom 但 windowLevel高
    public static func dialog(view:UIView, container:UIView? = nil) -> ToastDialog {
        let back:UIView = container ?? createView(by: .alpha(1))
        return ToastDialog(content: view, container: back)
    }
    /// 类似于Custom 但 windowLevel高
    public static func dialog(controller:UIViewController, container:UIView? = nil) -> ToastDialog {
        let dialog = self.dialog(view: controller.view, container: container)
        dialog.childController = controller
        return dialog
    }
    
    // MARK: - bubble view task
    public static func bubble(view:UIView, from rect:CGRect) -> ToastBubble {
        let back = CornerView()
        back.cornerRadius = setting.cornerRadius
        back.borderWidth = 0
        back.backgroundColor = UIColor.white
        let task = ToastBubble(content: view, container: back)
            .has(overlay: true)
            .hide(onOverlayTapped: true)
        task.fromRect = rect
        return task
    }
    public static func bubble(list:[String], from rect:CGRect) -> ToastBubble {
        let tableView = UITableView()
        return bubble(view: tableView, from: rect)
    }
    
    // MARK: - active view task
    public static func active(view:UIView, container:UIView? = nil) -> ToastActive {
        let back:UIView = container ?? createView(by: .alpha(1))
        return ToastActive(content: view, container: back).has(overlay: true)
    }
    public static func active(controller:UIViewController, container:UIView? = nil) -> ToastActive {
        let active = self.active(view: controller.view, container: container)
        active.childController = controller
        return active
    }
    
    // MARK: - custom view task
    public static func custom(view:UIView, container:UIView? = nil) -> ToastCustom {
        let back:UIView = container ?? createView(by: .alpha(1))
        return ToastCustom(content: view, container: back)
    }
    public static func custom(controller:UIViewController, container:UIView? = nil) -> ToastCustom {
        let custom = self.custom(view: controller.view, container: container)
        custom.childController = controller
        return custom
    }
    
}
