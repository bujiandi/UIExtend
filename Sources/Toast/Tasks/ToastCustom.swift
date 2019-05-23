//
//  ToastCustom.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

open class ToastCustom: ToastOverlay {
    
    public override init(content: UIView, container: UIView) {
        super.init(content: content, container: container)
        _layoutContentOn = { (container:UIView, toast:ToastBaseTask) in
            let content = toast.content
            container.addSubview(content) {[
                content.anchor.leading     == container.margin.leading,
                content.anchor.top         == container.margin.top,
                content.anchor.trailing    == container.margin.trailing,
                content.anchor.bottom      == container.margin.bottom,
            ]}
        }
    }
    
    @discardableResult
    open override func show(animated flag:Bool = true) -> Self {
        super.show(animated: flag)
        Toast.customManager.append(self, animated: flag)
        defer { Toast.customManager.animateCallThis() } //.resetTimer(minTime: 0.05)
        return self
    }

    @discardableResult
    open override func hide(animated flag:Bool = true) -> Self {
        super.hide(animated: flag)
        if  Toast.customManager.remove(self) {
            Toast.removeManager.append(self, animated: flag)
            Toast.removeManager.resetTimer(minTime: 0.05)
            Toast.customManager.resetTimer(minTime: Toast.setting.animDuration + 0.08)
        }
        return self
    }
}
