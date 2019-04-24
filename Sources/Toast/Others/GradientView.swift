//
//  GradientView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/26.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

open class GradientView: UIView {

    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        super.layer.masksToBounds = false
        super.backgroundColor = UIColor.clear
    }
    
//    private func updateColors() {
//        if colors.count != locations.count { return }
//        backLayer.colors = colors.map { $0.cgColor }
//        backLayer.locations = locations as [NSNumber]
//    }
    
    @IBInspectable open var startPoint:CGPoint = CGPoint(x: 0.5, y: 0) {
        didSet { backLayer.startPoint = startPoint }
    }
    @IBInspectable open var endPoint:CGPoint = CGPoint(x: 0.5, y: 1) {
        didSet { backLayer.endPoint = startPoint }
    }
    @IBInspectable open var colors:[UIColor] = [UIColor(white: 0, alpha: 0.5), UIColor.clear] {
        didSet { backLayer.colors = colors.map { $0.cgColor } }
    }
    @IBInspectable open var locations:[CGFloat] = [0,1] {
        didSet { backLayer.locations = locations as [NSNumber] }
    }
    
    
    private weak var _backLayer:CAGradientLayer?
    public var backLayer:CAGradientLayer {
        guard let back = _backLayer else {
            let back = CAGradientLayer()
            back.frame = bounds
            back.colors = colors.map { $0.cgColor }
            back.startPoint = startPoint
            back.endPoint = endPoint
            back.locations = locations as [NSNumber]
            back.contentsScale = UIScreen.main.scale
            layer.insertSublayer(back, at: 0)
            _backLayer = back
            return back
        }
        return back
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)

        backLayer.frame = bounds
        
        CATransaction.commit()
    }

}
