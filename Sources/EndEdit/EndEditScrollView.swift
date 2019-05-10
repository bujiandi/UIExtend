//
//  EndEditScrollView.swift
//  ScoreLib
//
//  Created by bujiandi on 2018/8/2.
//  Copyright © 2018 bujiandi. All rights reserved.
//

import UIKit

public class EndEditScrollView: UIScrollView, EndEditable {
    
    @IBOutlet public var excludeViews: [UIView] = []

    override public func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let view = super.hitTest(point, with: event)
        // 测试是否需要结束编辑
        endEditTest(point: point, in: view)
        
        return view
    }
    
}
