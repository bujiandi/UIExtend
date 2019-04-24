//
//  ToastDialog.swift
//  Toast
//
//  Created by 小歪 on 2018/8/10.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

open class ToastDialog: ToastOverlay {
    
    @discardableResult
    open override func show() -> Self {
        super.show()
        Toast.dialogManager.append(self)
        Toast.dialogManager.animateCallThis()//.resetTimer(minTime: 0.05)
        return self
    }
    
    @discardableResult
    open override func hide() -> Self {
        super.hide()
        if  Toast.dialogManager.remove(self) {
            Toast.removeManager.append(self)
            Toast.removeManager.animateCallThis()
            Toast.dialogManager.resetTimer(minTime: Toast.setting.animDuration + 0.08)
        }
        return self
    }

}
