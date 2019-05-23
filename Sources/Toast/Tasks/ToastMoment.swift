//
//  ToastMoment.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/26.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

public final class ToastMoment : ToastLabelTask {
    
    
    @discardableResult
    public override func show(animated flag:Bool = true) -> ToastMoment {
        
        if holdSecond <= 0 { holdSecond = Toast.setting.holdSecond }
        
        let manager = Toast.momentManager
        
        // 如果是已存在的Toast 不再重复弹出, 摇晃当前内容
        if let index = manager.queue.firstIndex(where: { $0.0 == self }) {
            let (task, _) = manager.queue[index]
            task.dismissTime = CACurrentMediaTime() + holdSecond
            task.startShakeAnimation()
            return task
        }
        
        manager.queue.append((self, animated: flag))
        dismissTime = CACurrentMediaTime() + holdSecond
        
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
            Toast.momentManager.animateCallThis()
        }
        return self
    }
}

