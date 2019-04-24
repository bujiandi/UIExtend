//
//  CornerEffectView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/10/27.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class CornerEffectView: UIVisualEffectView {

    @IBInspectable open var roundingCorners:UIRectCorner = .allCorners {
        didSet { setNeedsLayout() }
    }
    
    @IBInspectable open var cornerRadius:CGFloat = 0 {
        didSet{ setNeedsLayout() }
    }
    
    public var maskLayer:CAShapeLayer {
        guard let mask = layer.mask as? CAShapeLayer else {
            let mask = CAShapeLayer()
            mask.frame = bounds
            mask.fillColor = UIColor.black.cgColor
            mask.contentsScale = UIScreen.main.scale
            layer.mask = mask
            setNeedsLayout()
            return mask
        }
        return mask
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()

        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: roundingCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))

        maskLayer.frame = bounds
        maskLayer.path = path.cgPath
    }

}
