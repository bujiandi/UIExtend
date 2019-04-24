//
//  ToastController.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/20.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

public protocol ToastOwner: class {
    
    var toastList:[ToastBaseTask] { get set }
    
}

extension ToastOwner {
    
    public func hideAllToast() {
    
        for toast in toastList where !toast.isHidden {
            toast.hide()
        }
        toastList.removeAll()
    }
    
}

extension UIViewController {
    
    public func showByToastCustom(container:UIView? = nil) -> ToastCustom {
        return Toast.custom(controller: self, container: container)
    }
    
    public func showByToastActive(container:UIView? = nil) -> ToastActive {
        return Toast.active(controller: self, container: container)
    }
}

class OverlayToastView : UIView {
    
    weak var task:ToastOverlay?
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // 如果模态 则忽略手势穿透
        
//        if Toast.windowModalTask !== nil { return view }
        if view === self || view === nil {
            
            // 防止覆盖层异常
            let rect = bounds
            var hasContent:Bool = false
            for sub in subviews {
                hasContent = hasContent || rect.intersects(sub.frame)
            }
            
            if !hasContent {
                print("Toast窗口无可显示内容隐藏 subviews.count=",subviews.count,task ?? "nil",task.customMirror)
                UIView.animate(withDuration: Toast.setting.animDuration, animations: {
                    [weak self] in
                    self?.backgroundColor = UIColor.clear
                }, completion: { [weak self] (finish:Bool) in
                    self?.window?.isHidden = true
                })
            } else if task?.hasOverlay ?? false {
                if task?.isHideOnOverlayTapped ?? false { task!.hide() }
                return view
            }
            
            let keyWindow:UIWindow? = Toast.getLowWindow(by: window)
            //print("操作穿透")
            return keyWindow?.hitTest(point, with: event)
        }
        return view
    }
    
}

class OverlayRootController: UIViewController, UIGestureRecognizerDelegate {
    
    // 当前覆盖层的 ToastTask
    var overlayToast:ToastOverlay? {
        let overlayView = view as? OverlayToastView
        return overlayView?.task
    }
    
    func updateDeviceScreenState() {
        if #available(iOS 11.0, *) {
            setNeedsUpdateOfHomeIndicatorAutoHidden()
        }
        setNeedsStatusBarAppearanceUpdate()
    }
    // 是否允许屏幕旋转
    override var shouldAutorotate: Bool {
        return overlayToast?.autorotate ?? super.shouldAutorotate
    }
    // 是否隐藏顶部通知状态条
    override var prefersStatusBarHidden: Bool {
        return overlayToast?.statusBarHidden ?? super.prefersStatusBarHidden
    }
    // 自动隐藏 iPhoneX 底部 返回条
    override var prefersHomeIndicatorAutoHidden: Bool {
        if #available(iOS 11.0, *) {
            let autoHide = overlayToast?.homeIndicatorAutoHidden
            return autoHide ?? super.prefersHomeIndicatorAutoHidden
        }
        return false
    }
    
    // 首选屏幕方向
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return overlayToast?.preferredInterfaceOrientation ?? UIApplication.shared.delegate?.window??.rootViewController?.preferredInterfaceOrientationForPresentation ?? super.preferredInterfaceOrientationForPresentation
    }
    
    // 支持屏幕方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        
        // 如果当前Toast强制指定了屏幕方向, 则忽略其他
        if let orientations = overlayToast?.supportedOrientations,
            orientations.rawValue != 0 {
            return orientations
        }
        
        // 否则如果子控制器是导航控制器，则使用顶层控制器的方向
        var orientations:UIInterfaceOrientationMask = []
        for childController in children {
            if  let navigation = childController as? UINavigationController,
                let topController = navigation.topViewController {
                return topController.supportedInterfaceOrientations
            } else {
                orientations = childController.supportedInterfaceOrientations
            }
        }
        
        // 否则如果子控制器有屏幕方向, 则优先使用
        if orientations.rawValue != 0 {
            return orientations
        }
        
        let root = UIApplication.shared.delegate?.window??.rootViewController
        // 否则使用系统默认屏幕方向
        return root?.supportedInterfaceOrientations ?? super.supportedInterfaceOrientations
    }

    // 视图加载
    override func loadView() {
        super.loadView()
        let overlay = OverlayToastView(frame: UIScreen.main.bounds)
        overlay.isUserInteractionEnabled = true
        view = overlay
        view.backgroundColor = UIColor.clear
    }
    
    // 手势代理
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        let point = gestureRecognizer.location(in: view)
        for subView in view.subviews where subView.frame.contains(point) {
            return false
        }
        return true
    }

    
}
