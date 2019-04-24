//
//  ToastOverlay.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

open class ToastOverlay: ToastBaseTask {
    
    internal var autorotate:Bool? = nil
    internal var statusBarHidden:Bool? = nil
    internal var supportedOrientations: UIInterfaceOrientationMask = []
    internal var homeIndicatorAutoHidden:Bool? = nil
    internal var preferredInterfaceOrientation:UIInterfaceOrientation = .portrait
    
    internal var hasOverlay:Bool = false
    internal var isHideOnOverlayTapped:Bool = false
    
//    internal func layouts(on root:UIView) -> [NSLayoutConstraint] {
//        return [
//            container.centerX  == root.centerX,
//            container.centerY  == root.centerY,
//            container.leading  >= root.leading  + Toast.setting.marginScreenLeft  && .levelHigh + 1,
//            container.trailing <= root.trailing - Toast.setting.marginScreenRight && .levelHigh + 1
//        ]
//    }

    open override func defaultLayouts(on root:UIView) -> [NSLayoutConstraint] {
        return [
            container.anchor.centerX  == root.anchor.centerX,
            container.anchor.centerY  == root.anchor.centerY,
            container.anchor.leading  >= root.anchor.leading  + Toast.setting.marginScreenLeft  && .levelHigh + 1,
            container.anchor.trailing <= root.anchor.trailing - Toast.setting.marginScreenRight && .levelHigh + 1
        ]
    }
    
    @discardableResult
    open func set(autorotate:Bool) -> Self {
        self.autorotate = autorotate
        return self
    }
    
    @discardableResult
    open func set(statusBarHidden:Bool) -> Self {
        self.statusBarHidden = statusBarHidden
        return self
    }
    
    @discardableResult
    open func set(supportedOrientations:UIInterfaceOrientationMask) -> Self {
        self.supportedOrientations = supportedOrientations
        return self
    }
    
    @discardableResult
    open func set(homeIndicatorAutoHidden:Bool) -> Self {
        self.homeIndicatorAutoHidden = homeIndicatorAutoHidden
        return self
    }
    
    @discardableResult
    open func set(preferredInterfaceOrientation:UIInterfaceOrientation) -> Self {
        self.preferredInterfaceOrientation = preferredInterfaceOrientation
        return self
    }
    
    @discardableResult
    open func has(overlay:Bool) -> Self {
        hasOverlay = overlay
        return self
    }
    
    @discardableResult
    open func hide(onOverlayTapped:Bool) -> Self {
        isHideOnOverlayTapped = onOverlayTapped
        return self
    }

}
