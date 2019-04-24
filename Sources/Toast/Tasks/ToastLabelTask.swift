//
//  ToastMomentTask.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/22.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class ToastLabelTask : ToastBaseTask {
    
    internal static func createLabel() -> UILabel {
        let label = UILabel()
        label.font = Toast.setting.font
        label.numberOfLines = 3
        label.textAlignment = .center
        label.textColor = UIColor(white: 0.9, alpha: 1)
        label.setContentHuggingPriority(.defaultLow + 1, for: .horizontal)
        label.setContentHuggingPriority(.required, for: .vertical)
        label.setContentCompressionResistancePriority(.defaultLow + 1, for: .horizontal)
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }
    
    override func isEqual<T:ToastBaseTask>(_ task: T) -> Bool {
        if let notice = task as? ToastLabelTask {
            return hashKey == notice.hashKey
        }
        return super.isEqual(task)
    }
    
    open var label:UILabel { return content as! UILabel }
    
    /// 持续时长
    open var holdSecond:TimeInterval = 0 {
        didSet {
            // 如果 已显示更新 失效时间
            if dismissTime == 0 { return }
            dismissTime = dismissTime - oldValue + holdSecond
        }
    }
    
    internal var hashKey:Int
    internal var dismissTime:TimeInterval = 0
    internal weak var centerY:NSLayoutConstraint?
    
    public init(rich:NSAttributedString, container:UIView) {
        hashKey = rich.string.hashValue
        let label = ToastLabelTask.createLabel()
        label.attributedText = rich
        super.init(content: label, container: container)
    }
    
    /// 自动消失时间
    @discardableResult
    open func hold(second:TimeInterval) -> Self {
        holdSecond = second
        return self
    }
    
    @discardableResult
    open override func hide() -> Self {
        dismissTime = 0
        super.hide()
        return self
    }
    
}

extension ToastLabelTask : CustomStringConvertible {
    public var description: String { return label.text ?? "" }
}
