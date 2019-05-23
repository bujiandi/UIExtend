//
//  ToastTextTask.swift
//  Toast
//
//  Created by 招利 李 on 2017/8/17.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

public final class ToastNotice : ToastLabelTask {
    
    @discardableResult
    public override func show(animated flag:Bool = true) -> ToastNotice {
        
        let manager = Toast.noticeManager
        
        // 如果是已存在的Toast 不再重复弹出, 摇晃当前内容
        if let index = manager.queue.firstIndex(where: { $0.0 == self }) {
            let (task, _) = manager.queue[index]
            if holdSecond > 0 {
                task.dismissTime = CACurrentMediaTime() + holdSecond
            }
            task.startShockAnimation(horizontal: true)
            return task
        }
        
        manager.queue.append((self, animated: flag))
        
        if holdSecond > 0 {
            dismissTime = CACurrentMediaTime() + holdSecond
        }
            
        defer {
            manager.animateCall(manager)
        }
        
        super.show(animated: flag)
        return self
    }
    
    @discardableResult
    public override func hide(animated flag:Bool = true) -> Self {
        super.hide(animated: flag)
        dismissTime = 1
        defer {
            Toast.noticeManager.animateCallThis()
        }
        return self
    }
    
    internal static func releaseRootView() {
        _rootView?.removeFromSuperview()
        _rootView = nil
    }
    
    private static var _rootView:NoticeView? = nil
    internal static var rootView:NoticeView {
        guard let view = _rootView else {
            let height:CGFloat = 7
            let width:CGFloat = 50
            let size = UIScreen.main.bounds
            let blur = UIBlurEffect(style: .extraLight)
            let view = NoticeView(effect: blur)
            let rect = CGRect(x: 0, y: 0, width: size.width, height: 0)
            
            let mask = CAShapeLayer()
            mask.frame = CGRect(x: 0, y: 0, width: width, height: height)
            mask.path = UIBezierPath(roundedRect: mask.bounds, cornerRadius: 3).cgPath
            
            let down = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
            down.translatesAutoresizingMaskIntoConstraints = false
            down.layer.mask = mask
            down.frame = CGRect(x: (size.width - width)/2, y: 5, width: width, height: height)
            down.alpha = 0.3
            
            let line = UIView(frame: rect.insetBy(dx: 0, dy: -0.5))
            line.backgroundColor = UIColor(white: 0.80, alpha: 1)
            line.translatesAutoresizingMaskIntoConstraints = false
            
            view.frame = rect
            view.contentView.addSubview(line)
            view.contentView.addSubview(down)
            view.contentView.layout()
                .constraint(line.anchor.leading    == view.contentView.anchor.leading)
                .constraint(line.anchor.trailing   == view.contentView.anchor.trailing)
                .constraint(line.anchor.bottom     == view.contentView.anchor.bottom)
                .constraint(line.anchor.height     == Toast.onePixel)
                .constraint(down.anchor.centerX    == view.contentView.anchor.centerX     && .levelHigh)
                .constraint(down.anchor.bottom     == view.contentView.anchor.bottom - 9  && .levelHigh)
                .constraint(down.anchor.height     == height && .levelHigh)
                .constraint(down.anchor.width      == width  && .levelHigh)
            
            view.contentView.setNeedsLayout()
            
            let pan = UIPanGestureRecognizer(target: view, action: #selector(NoticeView.onPan(_:)))
            view.addGestureRecognizer(pan)
            
            _rootView = view
            return view
        }
        return view
    }
}

open class NoticeView : UIVisualEffectView {
    
    internal weak var topConstraint:NSLayoutConstraint?

    @objc internal func onPan(_ pan:UIPanGestureRecognizer) {
        let point = pan.location(in: self)
        
        switch pan.state {
        case .began:
            began = point
        case .changed:
            // 如果是纵向向上滑动
            let offset = CGPoint(x: point.x - began.x, y: point.y - began.y)
            moveNotice(offset: offset)
        case .ended:
            let offset = CGPoint(x: point.x - began.x, y: point.y - began.y)
            moveNotice(offset: offset)
            guard let task = Toast.notice else { return }
            
            var overX:CGFloat = 0
            if abs(offset.x) > 100 {
                task.dismissTime = CACurrentMediaTime() - 10
                overX = task.container.frame.width * (offset.x > 0 ? 1 : -1)
            }
            UIView.animate(withDuration: 0.3, animations: {
                UIView.setAnimationCurve(.easeOut)
                task.container.frame.origin.x = overX
            }, completion: { (finish:Bool) in
                Toast.noticeManager.animateCall(Toast.noticeManager)
            })
        default: break
        }
    }
    

    internal func moveNotice(offset:CGPoint) {
        guard let task = Toast.notice else { return }
        task.container.frame.origin.x = offset.x
    }
    
    internal var began:CGPoint = CGPoint.zero
}
