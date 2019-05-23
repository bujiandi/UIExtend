//
//  ToastActive.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/28.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class ToastActive: ToastOverlay {

    
    @discardableResult
    open override func show(animated flag:Bool = true) -> Self {
        super.show(animated: flag)
        Toast.activeManager.append(self, animated: flag)
        defer { Toast.activeManager.animateCallThis() } //.resetTimer(minTime: 0.05)
        return self
    }
    
    @discardableResult
    open override func hide(animated flag:Bool = true) -> Self {
        super.hide(animated: flag)
        if  Toast.activeManager.remove(self) {
            Toast.removeManager.append(self, animated: flag)
            Toast.removeManager.animateCallThis()
            Toast.activeManager.resetTimer(minTime: Toast.setting.animDuration + 0.08)
        }
        return self
    }
}
