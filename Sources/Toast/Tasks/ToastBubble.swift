//
//  ToastBubble.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout


extension CGRect {
    internal var center:CGPoint { return CGPoint(x: minX + width / 2, y: minY + height / 2) }
}

open class ToastBubble: ToastOverlay {

    open lazy var fromRect:CGRect = {
        return CGRect(x: UIScreen.main.bounds.width / 2, y: 0, width: 0, height: 0)
    }()
    
    open override func defaultLayouts(on root: UIView) -> [NSLayoutConstraint] {
        let screenSize = UIScreen.main.bounds.size
        let containerSize = container.systemLayoutSizeFitting(screenSize, withHorizontalFittingPriority: .levelFittingSize, verticalFittingPriority: .levelFittingSize)
        
        var layouts:[NSLayoutConstraint] = []
        if containerSize.height <= fromRect.minY - 20 {
            // 显示在上面
            let centerX = fromRect.center.x
            layouts = [
                container.anchor.centerX   == root.anchor.leading + centerX && .levelHigh,
                container.anchor.bottom    == root.anchor.top + fromRect.minY - 20,
                container.anchor.width     == containerSize.width,
                container.anchor.height    == containerSize.height,
                container.anchor.leading   >= root.anchor.leading  && .levelHigh + 2,
                container.anchor.trailing  <= root.anchor.trailing && .levelHigh + 1
            ]
            (container as? CornerView)?.sharp = (CGPoint(x: centerX, y: containerSize.height + 19), .bottom)
            
        } else if containerSize.height <= screenSize.height - fromRect.maxY - 20 {
            // 显示在下面
            let centerX = fromRect.center.x
            
            layouts = [
                container.anchor.centerX   == root.anchor.leading + centerX && .levelHigh,
                container.anchor.top       == root.anchor.top + fromRect.maxY + 20,
                container.anchor.width     == containerSize.width,
                container.anchor.height    == containerSize.height,
                container.anchor.leading   >= root.anchor.leading  && .levelHigh + 2,
                container.anchor.trailing  <= root.anchor.trailing && .levelHigh + 1
            ]
            (container as? CornerView)?.sharp = (CGPoint(x: centerX, y: -20), .top)
            
        } else if containerSize.width <= fromRect.minX - 20 {
            // 显示在左侧
            let centerY = fromRect.center.y
            layouts = [
                container.anchor.centerY   == root.anchor.top + centerY && .levelHigh,
                container.anchor.trailing  == root.anchor.leading + fromRect.minX - 20,
                container.anchor.width     == containerSize.width,
                container.anchor.height    == containerSize.height,
                container.anchor.top       >= root.anchor.top     && .levelHigh + 2,
                container.anchor.bottom    <= root.anchor.bottom  && .levelHigh + 1
            ]
            (container as? CornerView)?.sharp = (CGPoint(x: containerSize.width + 19, y: centerY), .right)
        } else if containerSize.width <= screenSize.width - fromRect.maxX - 20 {
            // 显示在右侧
            let centerY = fromRect.center.y
            
            layouts = [
                container.anchor.centerY   == root.anchor.top + centerY && .defaultHigh,
                container.anchor.leading   == root.anchor.leading + fromRect.maxX + 20,
                container.anchor.width     == containerSize.width,
                container.anchor.height    == containerSize.height,
                container.anchor.top       >= root.anchor.top && .levelHigh + 2,
                container.anchor.bottom    <= root.anchor.bottom && .levelHigh + 1
            ]
            (container as? CornerView)?.sharp = (CGPoint(x: -20, y: centerY), .left)
        } else {
            layouts = [
                container.anchor.centerX   == root.anchor.leading + fromRect.center.x && .levelHigh,
                container.anchor.centerY   == root.anchor.top + fromRect.center.y && .levelHigh,
                container.anchor.width     == containerSize.width,
                container.anchor.height    == containerSize.height,
                container.anchor.top       >= root.anchor.top && .levelHigh + 3,
                container.anchor.bottom    <= root.anchor.bottom && .levelHigh + 1,
                container.anchor.leading   >= root.anchor.leading && .levelHigh + 2,
                container.anchor.trailing  <= root.anchor.trailing && .levelHigh + 1
            ]
        }
//        container.frame = CGRect(x: fromRect.center.x - containerSize.width / 2, y: fromRect.minY
//             - containerSize.height - 10, width: containerSize.width, height: containerSize.height)
        
        container.frame = fromRect
        
//        layouts = layoutsBlock?(container, root, layouts) ?? layouts
        
        return layouts

    }
    
//    override func layouts(on root: UIView) -> [NSLayoutConstraint] {
//        let screenSize = UIScreen.main.bounds.size
//        let containerSize = container.systemLayoutSizeFitting(screenSize, withHorizontalFittingPriority: .levelFittingSize, verticalFittingPriority: .levelFittingSize)
//        
//        var layouts:[NSLayoutConstraint] = []
//        if containerSize.height <= fromRect.minY - 20 {
//            // 显示在上面
//            let centerX = fromRect.center.x
//            layouts = [
//                container.centerX   == root.leading + centerX && .levelHigh,
//                container.bottom    == root.top + fromRect.minY - 20,
//                container.width     == containerSize.width,
//                container.height    == containerSize.height,
//                container.leading   >= root.leading  && .levelHigh + 2,
//                container.trailing  <= root.trailing && .levelHigh + 1
//            ]
//            (container as? CornerView)?.sharp = (CGPoint(x: centerX, y: containerSize.height + 19), .bottom)
//
//        } else if containerSize.height <= screenSize.height - fromRect.maxY - 20 {
//            // 显示在下面
//            let centerX = fromRect.center.x
//
//            layouts = [
//                container.centerX   == root.leading + centerX && .levelHigh,
//                container.top       == root.top + fromRect.maxY + 20,
//                container.width     == containerSize.width,
//                container.height    == containerSize.height,
//                container.leading   >= root.leading  && .levelHigh + 2,
//                container.trailing  <= root.trailing && .levelHigh + 1
//            ]
//            (container as? CornerView)?.sharp = (CGPoint(x: centerX, y: -20), .top)
//
//        } else if containerSize.width <= fromRect.minX - 20 {
//            // 显示在左侧
//            let centerY = fromRect.center.y
//            layouts = [
//                container.centerY   == root.top + centerY && .levelHigh,
//                container.trailing  == root.leading + fromRect.minX - 20,
//                container.width     == containerSize.width,
//                container.height    == containerSize.height,
//                container.top       >= root.top     && .levelHigh + 2,
//                container.bottom    <= root.bottom  && .levelHigh + 1
//            ]
//            (container as? CornerView)?.sharp = (CGPoint(x: containerSize.width + 19, y: centerY), .right)
//        } else if containerSize.width <= screenSize.width - fromRect.maxX - 20 {
//            // 显示在右侧
//            let centerY = fromRect.center.y
//
//            layouts = [
//                container.centerY   == root.top + centerY && .defaultHigh,
//                container.leading   == root.leading + fromRect.maxX + 20,
//                container.width     == containerSize.width,
//                container.height    == containerSize.height,
//                container.top       >= root.top && .levelHigh + 2,
//                container.bottom    <= root.bottom && .levelHigh + 1
//            ]
//            (container as? CornerView)?.sharp = (CGPoint(x: -20, y: centerY), .left)
//        } else {
//            layouts = [
//                container.centerX   == root.leading + fromRect.center.x && .levelHigh,
//                container.centerY   == root.top + fromRect.center.y && .levelHigh,
//                container.width     == containerSize.width,
//                container.height    == containerSize.height,
//                container.top       >= root.top && .levelHigh + 3,
//                container.bottom    <= root.bottom && .levelHigh + 1,
//                container.leading   >= root.leading && .levelHigh + 2,
//                container.trailing  <= root.trailing && .levelHigh + 1
//            ]
//        }
////        container.frame = CGRect(x: fromRect.center.x - containerSize.width / 2, y: fromRect.minY
////             - containerSize.height - 10, width: containerSize.width, height: containerSize.height)
//        
//        container.frame = fromRect
//        
////        layouts = layoutsBlock?(container, root, layouts) ?? layouts
//        
//        return layouts
//    }
    
    @discardableResult
    open override func show(animated flag:Bool = true) -> Self {
        super.show(animated: flag)
        Toast.bubbleManager.append(self, animated: flag)
        defer { Toast.bubbleManager.animateCallThis() } //.resetTimer(minTime: 0.05)
        return self
    }
    
    @discardableResult
    open override func hide(animated flag:Bool = true) -> Self {
        super.hide(animated: flag)
        if  Toast.bubbleManager.remove(self) {
            Toast.removeManager.append(self, animated: flag)
            Toast.removeManager.animateCallThis()
            Toast.bubbleManager.resetTimer(minTime: Toast.setting.animDuration + 0.08)
        }
        return self
    }
    
}
