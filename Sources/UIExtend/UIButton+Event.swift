//
//  UIButton+Event.swift
//  Toast
//
//  Created by 李招利 on 2018/11/16.
//  Copyright © 2018 yFenFen. All rights reserved.
//

import UIKit

private var kButtonTouchUpInsideEvent = "button.touch.up.inside.event"

extension UIButton {
    
    public func whenTouchUpInside(_ action: @escaping (UIButton) -> Void) {
        objc_setAssociatedObject(self, &kButtonTouchUpInsideEvent, action, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        addTarget(self, action: #selector(dispatchedTouchUpInside), for: .touchUpInside)
    }
    
    @objc private func dispatchedTouchUpInside() {
        let action = objc_getAssociatedObject(self, &kButtonTouchUpInsideEvent) as? (UIButton) -> Void
        action?(self)
    }
}
