//
//  Toast+Animate.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/23.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

extension Toast {
    
    // MARK: - remove
    public static func removeAnimate(manager:ToastManager<ToastBaseTask>) {
        
        // 移除队列不要使用 其 window 属性 因为队列中的ToastBaseTask 属于其他window
        if !(manager._window?.isHidden ?? true) { manager.window.isHidden = true }

        let queue:[(ToastBaseTask, animated:Bool)] = manager.queue.reversed()
        manager.queue.removeAll(keepingCapacity: false)
        
        for (task, animated) in queue {
            if animated {
                task._hideAnimations(task)
                DispatchQueue.main.asyncAfter(deadline: .now() + task.hideDuration) {
                    task.container.superview?.removeConstraints(by: task.container)
                    task.container.removeFromSuperview()
                    task.childController?.removeFromParent()
                    task.dismissBlock?()
                }
            } else {
                task.container.superview?.removeConstraints(by: task.container)
                task.container.removeFromSuperview()
                task.childController?.removeFromParent()
                task.dismissBlock?()
            }
        }
        
//        for task in queue {
//            task.frame = task.container.frame
//            task.frame.origin.y -= 30
//            task.alpha = 0
//        }
//
//        UIView.animate(withDuration: setting.animDuration,
//                       delay: 0,
//                       usingSpringWithDamping: 0.7,
//                       initialSpringVelocity: 20,
//                       options: [.curveEaseInOut],
//                       animations:
//        {
//            for task in queue {
//                task.container.frame = task.frame
//                task.container.alpha = task.alpha
//                task.container.superview?.layoutIfNeeded()
//            }
//        }) { (finish:Bool) in
//            for task in queue {
//                task.container.superview?.removeConstraints(by: task.container)
//                task.container.removeFromSuperview()
//                task.childController?.removeFromParentViewController()
//                task.dismissBlock?()
//            }
//        }
    }
    
    // MARK: - moment
    public static func momentAnimate(manager:ToastManager<ToastMoment>) {
        // 当前时间
        let currentTime:TimeInterval = CACurrentMediaTime() //DispatchTime.now()
        let timeOffset:TimeInterval = currentTime - manager.lastTime
        manager.lastTime = currentTime
        
        // 最小动画时间差 (不能低于单次动画时长)
        var minCallTime:TimeInterval = TimeInterval.greatestFiniteMagnitude
        
        var removeQueue = [(ToastBaseTask, animated:Bool)]()
        var offsetY:CGFloat = 0
        for i in (0..<manager.queue.count).reversed() {
            let (task, animated) = manager.queue[i]
            
            // 不在显示中的 task 补动画时间
            if i >= setting.maxCount { task.dismissTime += timeOffset }
            
            // 超时了需要加入移除队列
            let time = task.dismissTime - currentTime
            if time <= 0, i < setting.maxCount {
                manager.queue.remove(at: i)
                removeQueue.append((task, animated))
                continue
            } else if time < minCallTime {
                // 更新下次执行最小时间间隔
                minCallTime = time
            }
            // 超过3条不显示
            if i > setting.maxCount - 1 { continue }
            
            let yMultiplier:CGFloat = setting.yMultiplier

            // 将视图添加到窗口(如果需要)
            manager.windowAdd(task: task) { //(view:UIView, root:UIView) -> [NSLayoutConstraint] in

                let left    = $0.anchor.leading  >= $1.anchor.leading  + setting.padding.left     && .levelHigh
                let right   = $0.anchor.trailing <= $1.anchor.trailing - setting.padding.right    && .levelHigh
                let centerX = $0.anchor.centerX  == $1.anchor.centerX
                let centerY = $1.anchor.centerY  == $0.anchor.bottom * yMultiplier + offsetY      && .levelHigh
                
                task.centerY = centerY
                return [left, right, centerX, centerY]
            }
            task.centerY?.constant = offsetY
            
            let screenSize = UIScreen.main.bounds.size
            
            let limitSize = CGSize(width: screenSize.width - setting.marginScreenLeft - setting.marginScreenRight, height:screenSize.height)
            // 根据布局自动计算Toast 尺寸
            let size = task.container.systemLayoutSizeFitting(limitSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            
            offsetY += ceil((size.height + setting.interval) * yMultiplier)// / scale
        }
        
        // 重置回调定时器 (不能小于一次动画时间)
        manager.resetTimer(minTime: max(minCallTime, setting.animDuration + 0.01))
        
        // 如果有超时的 ToastMoment 加入移除管理器
        if removeQueue.count > 0 {
            removeManager.queue.append(contentsOf: removeQueue)
            removeManager.animateCall(removeManager)
        }
        
        for (task, animated) in manager.queue where !animated {
            if task.centerY == nil {
                task.container.frame = task.frame
            }
            task.container.alpha = task.alpha
        }
        
        UIView.animate(withDuration: setting.animDuration, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 20, options: [.curveEaseInOut], animations: {
            
            for (task, animated) in manager.queue where animated {
                if task.centerY == nil {
                    task.container.frame = task.frame
                }
                task.container.alpha = task.alpha
            }
            if manager.queue.count > 0,
                let window = manager._window {
                window.rootViewController!.view.layoutIfNeeded()
            }
        }) { (finish:Bool) in
            manager.hideWindowIfNeed()
        }
    }
    
    // MARK: - notice
    public static func noticeAnimate(manager:ToastManager<ToastNotice>) {
        let currentTime:TimeInterval = CACurrentMediaTime() //DispatchTime.now()
        
        if manager.queue.count == 0, notice == nil, manager._window == nil { return }
        
        let screenSize = UIScreen.main.bounds.size
        let root = ToastNotice.rootView

        // 如果是第一次 添加到window
        if manager._window == nil {
            manager.window.isUserInteractionEnabled = true

            let view = manager.window.rootViewController!.view!
            let rect = CGRect(x: 0, y: 0, width: screenSize.width, height: 5)
            let down = GradientView(frame: rect)

            root.translatesAutoresizingMaskIntoConstraints = false
            down.translatesAutoresizingMaskIntoConstraints = false
            
            down.colors = [
                UIColor(white: 0.2, alpha: 0.5),
                UIColor(white: 0.2, alpha: 0.4),
                UIColor(white: 0.2, alpha: 0.2),
                UIColor(white: 0.2, alpha: 0.0)
            ]
            down.locations = [0.0, 0.2, 0.5, 1.0]
         
            let top = root.anchor.top == view.anchor.top
            
            view.addSubview(down)
            view.addSubview(root)
            view.addConstraints([
                root.anchor.leading    == view.anchor.leading,
                root.anchor.trailing   == view.anchor.trailing,
                top,
                view.anchor.width      == root.contentView.anchor.width,
                down.anchor.leading    == view.anchor.leading,
                down.anchor.trailing   == view.anchor.trailing,
                down.anchor.top        == root.anchor.bottom,
                down.anchor.height     == 5
                ])
            
            root.topConstraint = top
        }
        if manager.window.isHidden { manager.window.isHidden = false }

        var removeTask:ToastNotice?
        if let task = notice,
            task.dismissTime > 0,
            task.dismissTime - currentTime <= 0 {
            notice = nil
            
            if manager.queue.count == 0 {
                root.topConstraint?.constant = -root.frame.height - 5
                // 彻底移除
            } else {
                root.contentView.removeConstraints(by: task.container)
                task.container.removeConstraints(by: task.content)
                task.container.alpha = 1
            }
            removeTask = task
        }
        
        // 如果队列中有新的通知消息
        if notice == nil, manager.queue.count > 0 {

            let (task, animated) = manager.queue.removeFirst()
            
            if task.holdSecond > 0 {
                task.dismissTime = currentTime + task.holdSecond
            }
            
            task.container.translatesAutoresizingMaskIntoConstraints = false
            
            let limitSize = CGSize(width: screenSize.width, height:screenSize.height)

            let size = task.container.systemLayoutSizeFitting(limitSize, withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel)
            
            task.container.alpha = 0
            task.container.frame = CGRect(x: 0, y: 0, width: size.width, height: size.height)
            root.topConstraint?.constant = 0
            
            root.contentView.addSubview(task.container) {[
//                task.container.leading  == root.contentView.leading,
//                task.container.trailing == root.contentView.trailing,
                task.container.anchor.width    == root.contentView.anchor.width,
                task.container.anchor.top      == root.contentView.anchor.top,
                task.container.anchor.bottom   == root.contentView.anchor.bottom - 15
            ]}

            notice = task
        }

        if let task = notice, task.dismissTime > 0 {
            // 重置回调定时器 (不能小于一次动画时间)
            manager.resetTimer(minTime: max(task.dismissTime - currentTime, setting.animDuration + 0.01))
        }
        
        UIView.animate(withDuration: setting.animDuration, animations: {
            UIView.setAnimationCurve(.easeOut)
            if let task = removeTask {
                task.container.frame.origin.y = task.container.frame.height + 15
                task.container.alpha = 0
            }
            if let task = notice {
                task.container.alpha = 1
            }
            manager.window.rootViewController!.view.layoutIfNeeded()
            
        }) { (finish:Bool) in
            removeTask?.container.removeFromSuperview()
            removeTask?.childController?.removeFromParent()
            removeTask?.dismissBlock?()
            removeTask = nil
            if notice == nil { manager.hideWindowIfNeed() }
        }
        
    }
    
    // MARK: - overlay
    public static func overlayAnimate(manager:ToastManager<ToastOverlay>) {
        
//        DispatchQueue.main.async { [weak manager] in
//
//        }

        manager.hideWindowIfNeed()
        
        guard let (task, animated) = manager.queue.first else { return }
        
        if manager._window == nil {
            manager.window.isUserInteractionEnabled = true
            if manager !== customManager, manager !== dialogManager {
                let layer = manager.window.rootViewController!.view!.layer
                layer.shadowOffset = CGSize(width: 1, height: 1)
                layer.shadowColor = UIColor(white: 0.2, alpha: 1).cgColor
                layer.shadowRadius = 3
                layer.shadowOpacity = 0.8
            }
        }
        let window = manager.window

        if window.isHidden { window.isHidden = false }
        let rootController = window.rootViewController as! OverlayRootController
        let root = rootController.view!

        (root as? OverlayToastView)?.task = task
        rootController.updateDeviceScreenState()
        
        root.backgroundColor = task.hasOverlay ? UIColor(white: 0.2, alpha: 0.5) : UIColor.clear
        
//        let screenSize = UIScreen.main.bounds.size
        
        if task.container.superview == nil {
        
//            let limitSize = CGSize(width: screenSize.width - setting.marginScreenLeft - setting.marginScreenRight, height:screenSize.height)
            // 根据布局自动计算Toast 尺寸
//            let size = task.container.systemLayoutSizeFitting(limitSize, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
            
//            task.container.frame = CGRect(x: (limitSize.width - size.width) / 2 + setting.marginScreenLeft, y: (limitSize.height - size.height) / 2, width: size.width, height: size.height)
            
//            root.addSubview(task.container) {
//                let defaultLayouts = task.layouts(on: root)
//                return task.layoutsBlock?(task.container, root, defaultLayouts) ?? defaultLayouts
//            }
            if let controller = task.childController {
                manager.window.rootViewController!.addChild(controller)
            }

            task._layoutContainerOn(root, task)
            root.layoutIfNeeded()
//            task.childController?.viewWillAppear(animated)
            // 执行显示动画
            if animated {
                task._showAnimations(task)
            }
            
        }
        
//        UIView.animate(withDuration: setting.animDuration, delay: 0, usingSpringWithDamping: manager.animDamping, initialSpringVelocity: 20, options: [.curveEaseInOut], animations: {
//
//            for task in manager.queue {
//                task.container.alpha = task.alpha
//            }
//            manager.window.rootViewController!.view.layoutIfNeeded()
//
//        }) { (finish:Bool) in
//            manager.hideWindowIfNeed()
//        }

    }
}
