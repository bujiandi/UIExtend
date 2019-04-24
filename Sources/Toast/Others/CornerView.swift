//
//  CornerView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/24.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

@IBDesignable
open class CornerView: UIView {

    
    @IBInspectable open var borderColor:UIColor? {
        didSet{
            backLayer.strokeColor = borderColor?.cgColor
        }
    }
    
    @IBInspectable open var borderWidth:CGFloat = 0 {
        didSet{
            backLayer.lineWidth = borderWidth
        }
    }
    
    @IBInspectable open var cornerRadius:CGFloat = 0 {
        didSet{
            setNeedsLayout()
        }
    }
    
    @IBInspectable open var rotateAngle:CGFloat = 0 {
        didSet {
            updateTransform()
        }
    }
    
    @IBInspectable open var scale:CGSize = CGSize(width: 1, height: 1) {
        didSet {
            updateTransform()
        }
    }
    
    private var _backgroundColor:UIColor?
    open override var backgroundColor: UIColor? {
        set {
            _backgroundColor = newValue
            backLayer.fillColor = newValue?.cgColor
            super.backgroundColor = UIColor.clear
        }
        get { return _backgroundColor }
    }
    
    private func updateTransform() {
        let radians = rotateAngle / 180 * CGFloat.pi
        
        self.transform = CGAffineTransform(rotationAngle: radians)
            .scaledBy(x: scale.width, y: scale.height)
    }
    
    @IBInspectable public var hasEffect:Bool = false {
        didSet {
            if effectView == nil && hasEffect {
                let effect = UIBlurEffect(style: .extraLight)
                let view = UIVisualEffectView(effect: effect)
                view.frame = bounds
                insertSubview(view, at: 0)
                effectView = view
            } else if !hasEffect {
                effectView?.removeFromSuperview()
            }
        }
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        super.layer.masksToBounds = false
        super.backgroundColor = UIColor.clear
        
    }
    
    private weak var _backLayer:CAShapeLayer?
    public var backLayer:CAShapeLayer {
        guard let back = _backLayer else {
            let back = CAShapeLayer()
            back.frame = bounds.insetBy(dx: 0.5, dy: 0.5)
            back.lineWidth = ceil(borderWidth)
            back.strokeColor = borderColor?.cgColor
            back.fillColor = (_backgroundColor ?? UIColor.white).cgColor
            back.contentsScale = UIScreen.main.scale
            layer.insertSublayer(back, at: 0)
            _backLayer = back
            return back
        }
        return back
    }
    
    @IBInspectable public var leftTopCorner:Bool = true {
        didSet{
            if leftTopCorner {
                rectCorners.insert(.topLeft)
            } else {
                rectCorners.remove(.topLeft)
            }
        }
    }

    
    open var rectCorners:UIRectCorner = .allCorners {
        didSet{
            setNeedsLayout()
        }
    }
    
    open override func layoutSublayers(of layer: CALayer) {
        super.layoutSublayers(of: layer)
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let layerRect = bounds//.insetBy(dx: 0.5, dy: 0.5)
        let roundRect = CGRect(origin: CGPoint.zero, size: layerRect.size)
        
        let path = UIBezierPath(roundedRect: roundRect, byRoundingCorners: rectCorners, cornerRadii: CGSize(width: cornerRadius, height: cornerRadius))
        
        if let (sharpPoint, orientation) = sharp {
            
            let side:CGFloat = 20
            var point = sharpPoint
            let path1 = UIBezierPath()
            
            switch orientation {
            case .top:
                point.x = max(min(layerRect.width - side - 5, point.x - frame.minX), side + 5)

                path1.move(to: CGPoint(x: point.x - side, y: 0))
                path1.addQuadCurve(to: CGPoint(x: point.x - side + 4, y: -2), controlPoint: CGPoint(x: point.x - side + 2, y: 0))
                path1.addLine(to: CGPoint(x: point.x - 2, y: point.y + 2))
                path1.addQuadCurve(to: CGPoint(x: point.x + 2, y:point.y + 2), controlPoint: point)
                path1.addLine(to: CGPoint(x: point.x + side - 4, y: -2))
                path1.addQuadCurve(to: CGPoint(x: point.x + side, y:0), controlPoint: CGPoint(x: point.x + side - 2, y: 0))
            case .left:
                point.y = max(min(layerRect.height - side - 5, point.y - frame.minY), side + 5)

                path1.move(to: CGPoint(x: 0, y: point.y - side))
                path1.addQuadCurve(to: CGPoint(x: -2, y: point.y - side + 4), controlPoint: CGPoint(x: 0, y: point.y - side + 2))
                path1.addLine(to: CGPoint(x: point.x + 2, y: point.y - 2))
                path1.addQuadCurve(to: CGPoint(x: point.x + 2, y:point.y + 2), controlPoint: point)
                path1.addLine(to: CGPoint(x: -2, y: point.y + side - 4))
                path1.addQuadCurve(to: CGPoint(x: 0, y:point.y + side), controlPoint: CGPoint(x: 0, y: point.y + side - 2))
            case .right:
                point.y = max(min(layerRect.height - side - 5, point.y - frame.minY), side + 5)

                path1.move(to: CGPoint(x: layerRect.width, y: point.y - side))
                path1.addQuadCurve(to: CGPoint(x: layerRect.width + 2, y: point.y - side + 4), controlPoint: CGPoint(x: layerRect.width, y: point.y - side + 2))
                path1.addLine(to: CGPoint(x: point.x - 2, y: point.y - 2))
                path1.addQuadCurve(to: CGPoint(x: point.x - 2, y:point.y + 2), controlPoint: point)
                path1.addLine(to: CGPoint(x: layerRect.width + 2, y: point.y + side - 4))
                path1.addQuadCurve(to: CGPoint(x: layerRect.width, y:point.y + side), controlPoint: CGPoint(x: layerRect.width, y: point.y + side - 2))
            case .bottom:
                point.x = max(min(layerRect.width - side - 5, point.x - frame.minX), side + 5)
                
                path1.move(to: CGPoint(x: point.x - side, y: layerRect.height))
                path1.addQuadCurve(to: CGPoint(x: point.x - side + 4, y: layerRect.height + 2), controlPoint: CGPoint(x: point.x - side + 2, y: layerRect.height))
                path1.addLine(to: CGPoint(x: point.x - 2, y: point.y - 2))
                path1.addQuadCurve(to: CGPoint(x: point.x + 2, y:point.y - 2), controlPoint: point)
                path1.addLine(to: CGPoint(x: point.x + side - 4, y: layerRect.height + 2))
                path1.addQuadCurve(to: CGPoint(x: point.x + side, y:layerRect.height), controlPoint: CGPoint(x: point.x + side - 2, y: layerRect.height))
            }
            path.append(path1)
        }
        
        path.usesEvenOddFillRule = true
        backLayer.fillRule = CAShapeLayerFillRule.evenOdd
        backLayer.path = path.cgPath

        backLayer.frame = layerRect
        
        CATransaction.commit()
    }
    
    open var sharp:(CGPoint, CornerViewSharpOrientation)? = nil
    open weak var effectView:UIVisualEffectView?

}

public enum CornerViewSharpOrientation: Int {
    case top
    case left
    case right
    case bottom
}
