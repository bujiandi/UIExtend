//
//  ToastManager.swift
//  Toast
//
//  Created by 招利 李 on 2017/8/17.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit



open class ToastManager<T:ToastBaseTask> {
    
    public var queue:[T] // ToastQueue<T>
    public func append(_ task:T) {
        if let index = queue.firstIndex(where: { $0 === task }) {
            queue.remove(at: index)
        }
        queue.append(task)
    }

    internal lazy var lastTime:TimeInterval = CACurrentMediaTime()
    internal let windowLevel:UIWindow.Level
    internal let animateCall:(_ manager:ToastManager<T>) -> Void
    internal let animDamping:CGFloat
    
    internal init(_ level:UIWindow.Level, damping:CGFloat = 0.8, animate:@escaping (_ manager:ToastManager<T>) -> Void) {
        windowLevel = level
        animDamping = damping
        animateCall = animate
        queue = [T]()    // ToastQueue<T>()
        
        // 处理内存警告监听
        NotificationCenter.default.addObserver(self, selector: #selector(didReceiveMemoryWarning), name: UIApplication.didReceiveMemoryWarningNotification, object: nil)

        // 处理键盘弹出
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardFrameWillChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
    }
    
    @objc func didReceiveMemoryWarning() {
        if self.queue.capacity <= self.queue.count { return }
        self.queue.reserveCapacity(self.queue.count)
    }
    
    @objc func keyboardFrameWillChange(_ notification:Notification) {
        guard let window = self._window else { return }
        guard let info = notification.userInfo else { return }

        let endFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve    = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let options  = UIView.AnimationOptions(rawValue:UInt(curve))
        
        var view:UIView! = window.rootViewController?.view
        
        UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
            
            view.frame.size.height = endFrame.minY
            view.layoutIfNeeded()
            
        }) { (finish:Bool) in
            view = nil
        }
    }
    
    internal var _window:UIWindow?
    public var window:UIWindow {
        guard let window = _window else {
            let controller = OverlayRootController()
            
            let window = UIWindow(frame: UIScreen.main.bounds)
            window.windowLevel = windowLevel
            window.rootViewController = controller
            window.backgroundColor = UIColor.clear
            window.isUserInteractionEnabled = false
            window.isHidden = false
            _window = window
            return window
        }
        return window
    }
    
    internal var timer:DispatchSourceTimer?
    // = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.main)
    
    internal func animateCallThis() {
        animateCall(self)
    }

    internal func resetTimer(minTime:TimeInterval) {
        cancel()
        
        if minTime == TimeInterval.greatestFiniteMagnitude { return }
        // 如果有需更新的状态则开始定时器
        timer = DispatchSource.makeTimerSource(flags: [], queue: .main)
        timer!.setEventHandler { [unowned self] in self.animateCall(self) }
        timer!.schedule(deadline: .now() + minTime)
        timer!.resume()
    }

    internal func cancel() {
        timer?.cancel()
        timer = nil
    }
    
    internal func hideWindowIfNeed() {
        if queue.count == 0 {
            if _window?.isKeyWindow ?? false {
                UIApplication.shared.delegate?.window??.becomeKey()
//                UIApplication.shared.delegate?.window??.makeKey()
            }
            _window?.isHidden = true
            _window = nil
        }
    }
    
    internal func windowAdd(task:T, layouts: @convention(block) (_ container:UIView, _ superView:UIView)->[NSLayoutConstraint]) {
        if task.container.superview != nil { return }

        if _window?.isHidden ?? true { window.isHidden = false }

        guard let overlayController = window.rootViewController else {
            return
        }
        // 添加约束
        let contraints = layouts(task.container, overlayController.view)
        if contraints.count > 0 {
            task.container.translatesAutoresizingMaskIntoConstraints = false
            task.container.autoresizingMask = []
        } else {
            task.container.translatesAutoresizingMaskIntoConstraints = true
            task.container.autoresizingMask = task.autoresizingMask
        }
        
        task.container.alpha = 0
        task.alpha = 1
        overlayController.view.addSubview(task.container)
        if let controller = task.childController {
            overlayController.addChild(controller)
        }

        overlayController.view.addConstraints(contraints)
        overlayController.view.layoutIfNeeded()
    }
    
    @discardableResult
    public func remove(_ task:T) -> Bool {
        if let index = queue.firstIndex(where: { $0 === task }) {
            queue.remove(at: index)
            return true
        }
        return false
    }
    
//    internal func animate() {
//        
//        timer?.scheduleOneshot(deadline: .now() + 20)
//        
//    }

}

extension UIInterfaceOrientationMask {
    
    public func contains(orientation: UIInterfaceOrientation) -> Bool {
        switch orientation {
        case .landscapeLeft:        return contains(.landscapeLeft)
        case .landscapeRight:       return contains(.landscapeRight)
        case .portrait:             return contains(.portrait)
        case .portraitUpsideDown:   return contains(.portraitUpsideDown)
        case .unknown:              fallthrough
        @unknown default:           return contains(.portrait)
        }
    }
}

extension UIInterfaceOrientation : CustomStringConvertible {
    public var description: String {
        switch self {
        case .portrait: return "portrait"
        case .landscapeLeft: return "landscapeLeft"
        case .landscapeRight: return "landscapeRight"
        case .portraitUpsideDown: return "portraitUpsideDown"
        case .unknown: fallthrough
        @unknown default: return "unknown"
        }
    }
}
