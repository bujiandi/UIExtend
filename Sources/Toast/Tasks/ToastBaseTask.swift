//
//  ToastTask.swift
//  Toast
//
//  Created by 招利 李 on 2017/8/17.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout
import CoreAnimations


internal let kToastShowHideAnimation = "ToastShowHideAnimation"

public func ==<T:ToastBaseTask>(lhs: T, rhs: T) -> Bool {
    return lhs.isEqual(rhs)
}

open class ToastBaseTask : Equatable {
    
    public let content:UIView
    open var container:UIView
    open var childController:UIViewController?
    
    internal func isEqual<T:ToastBaseTask>(_ task:T) -> Bool {
        return content === task.content
    }
    
    /**
     * @param content   内容视图
     * @param container 背景视图
     */
    public init(content:UIView, container:UIView) {
        self.content = content
        self.container = container
        self.frame = content.frame
    }
    
    
    open var frame:CGRect   = CGRect.zero
    open var alpha:CGFloat  = 1
    open var autoresizingMask:UIView.AutoresizingMask = []
    
    open var view:UIView { return content }
    
    open func defaultLayouts() -> [NSLayoutConstraint] {
        let left    = content.anchor.leading   == container.margin.leading && .levelHigh
        let top     = content.anchor.top       == container.margin.top
        let right   = content.anchor.trailing  == container.margin.trailing && .levelHigh
        let bottom  = content.anchor.bottom    == container.margin.bottom
        return [left, top, right, bottom]
    }
    
    open func defaultLayouts(on root:UIView) -> [NSLayoutConstraint] {
        return [
            container.anchor.leading     == root.anchor.leading,
            container.anchor.trailing    == root.anchor.trailing,
            container.anchor.top         == root.anchor.top,
            container.anchor.bottom      == root.anchor.bottom
        ]
    }
    
    @discardableResult
    open func layoutContentOn(_ block: @escaping (_ container:UIView, _ toast:ToastBaseTask) -> Void) -> Self {
        _layoutContentOn = block
        return self
    }
    
    /// 布局内容视图到容器视图上
    internal lazy var _layoutContentOn:(UIView, ToastBaseTask) -> Void = {
        (container:UIView, toast:ToastBaseTask) in
        
        let content = toast.content
        
        if  content.superview != nil {
            content.removeFromSuperview()
        }
        // 如果使用自动布局掩码, 则忽略约束布局
        let autoresizingMask = toast.autoresizingMask
        container.addSubview(content)
        if autoresizingMask.rawValue > 0 { return }
        
        content.translatesAutoresizingMaskIntoConstraints = false
        container.layoutMargins = Toast.setting.padding
        
        let layouts = toast.defaultLayouts()
        if  layouts.count > 0 {
            container.addConstraints(layouts)
        }
    }
    
    /// 当需要显示的时候添加布局
    @discardableResult
    open func layoutContainerOn(_ block: @escaping (_ superview:UIView, _ toast:ToastBaseTask) -> Void) -> Self {
        _layoutContainerOn = block
        return self
    }
    
    internal lazy var _layoutContainerOn:(UIView, ToastBaseTask) -> Void = {
        (superview:UIView, toast:ToastBaseTask) in
        
        let container = toast.container
        
        if container.superview != nil {
            container.removeFromSuperview()
        }
        
        let layouts = toast.defaultLayouts(on: superview)
        superview.addSubview(container) { layouts }
    }
    
    internal var _showAnimations:(ToastBaseTask) -> Void = {
        (task:ToastBaseTask) in
        let duration = task.showDuration
        let container = task.container
        let y = container.layer.position.y
        
        let alpha = container.layer.presentation()?.opacity ?? 0
        let begin = container.layer.presentation()?.position.y ?? y + 30

        container.layer.alpha = 1
        container.layer.animate(forKey: kToastShowHideAnimation) {
//            if #available(iOS 9.0, *) {
//                $0.position.y.value(from: begin, to: y, damping: 0, duration: duration).timingFunction(.easeIn)
//            } else {
//                $0.position.y.value(from: begin, to: y, duration: duration)
//            }
            $0.position.y.value(from: begin, to: y, duration: duration)
            $0.opacity.value(from: alpha, to: 1, duration: duration)
            $0.timingFunction(.easeOut)
        }
    }
    
    internal var _hideAnimations:(ToastBaseTask) -> Void = {
        (task:ToastBaseTask) in
        let duration = task.hideDuration
        let container = task.container
        let y = container.layer.position.y
        
        let alpha = container.layer.presentation()?.opacity ?? 1
        let begin = container.layer.presentation()?.position.y ?? y
        
        container.layer.alpha = 0
        container.layer.animate(forKey: kToastShowHideAnimation) {
//            if #available(iOS 9.0, *) {
//                $0.position.y.value(from: begin, to: y - 90, damping: 1, duration: duration).timingFunction(.easeOut)
//            } else {
//                $0.position.y.value(from: begin, to: y - 90, duration: duration)
//            }
            $0.position.y.value(from: begin, to: y - 60, duration: duration)
            $0.opacity.value(from: alpha, to: 0, duration: duration)
            $0.timingFunction(.easeIn)
        }
    }
    
    internal var hideDuration:TimeInterval = Toast.setting.animDuration
    internal var showDuration:TimeInterval = Toast.setting.animDuration
    open func showAnimations(duration:TimeInterval = Toast.setting.animDuration, _ animations: @escaping (ToastBaseTask) -> Void) -> Self {
//        container.layer.animate(forKey: kToastShowHideAnimation) {
//            if #available(iOS 9.0, *) {
//                $0.position.y.value(from: 0, to: 0, damping: 1, duration: duration).initialVelocity(5).timingFunction(.easeInOut)
//            } else {
//                $0.position.y.value(from: begin, to: y - 90, duration: duration)
//            }
//            $0.opacity.value(from: alpha, to: 0, duration: duration)
//        }
        _showAnimations = animations
        return self
    }
    
    open func hideAnimations(duration:TimeInterval = Toast.setting.animDuration, _ animations: @escaping (ToastBaseTask) -> Void) -> Self {
        _hideAnimations = animations
        return self
    }
    
    open var isHidden:Bool { return content.superview == nil }
    
    /// 展示 Toast
    @discardableResult
    open func show() -> Self {
        if content.superview == nil { _layoutContentOn(container, self) }
        return self
    }
    
    /// 隐藏 Toast
    @discardableResult
    open func hide() -> Self {
        return self
    }
    
    open func void() -> Void {}
    open func null<T>() -> T? { return nil }
    
    internal var dismissBlock: (@convention(block) () -> Void)?
    
    @discardableResult
    open func onDismiss(_ block:@escaping @convention(block) () -> Void) -> Self {
        dismissBlock = block
        return self
    }
    
    // 开始摇晃动画
    public func startShakeAnimation() {
        if container.layer.animation(forKey: kShakeAnimation) != nil {
            container.layer.removeAnimation(forKey: kShakeAnimation)
        }
        container.layer.add(shakeAnimation, forKey: kShakeAnimation)
    }
    
    // 开始摇晃动画
    public func startShockAnimation(horizontal:Bool) {
        
        if container.layer.animation(forKey: kShockAnimation) != nil {
            container.layer.removeAnimation(forKey: kShockAnimation)
        }
        container.layer.add(horizontal ? shockAnimationX : shockAnimationY, forKey: kShockAnimation)
    }

}

private let kShakeAnimation:String = "shakeAnimation"
private let kShockAnimation:String = "shockAnimation"


internal var shakeAnimation: CABasicAnimation {
    let shake = CABasicAnimation(keyPath: "transform.rotation.z")
    // 晃动步长, 晃动幅度+-, 动画时间, 晃动次数
    shake.byValue       = 0.003
    shake.fromValue     =  0.08 as Any  //NSNumber(+0.1)
    shake.toValue       = -0.08  //NSNumber(-0.1)
    shake.duration      = 0.1
    shake.autoreverses  = true
    shake.repeatCount   = 3
    
    return shake
}

internal var shockAnimationY: CAKeyframeAnimation {
    let shock = CAKeyframeAnimation(keyPath: "transform.translation.x")
    // 晃动步长, 晃动幅度+-, 动画时间, 晃动次数
    shock.values = [0, -10, 10, 0]
    shock.duration      = 0.15
    shock.autoreverses  = true
    shock.repeatCount   = 2
    
    return shock
}

internal var shockAnimationX: CAKeyframeAnimation {
    let shock = CAKeyframeAnimation(keyPath: "transform.translation.x")
    // 晃动步长, 晃动幅度+-, 动画时间, 晃动次数
    shock.values = [0, -10, 10, 0]
    shock.duration      = 0.15
    shock.autoreverses  = true
    shock.repeatCount   = 2
    
    return shock
}
