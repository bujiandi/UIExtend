//
//  SimpleGradientView.swift
//  GradientColor
//
//  Created by bujiandi on 2019/5/5.
//

import UIKit

@IBDesignable
open class SimpleGradientView : GradientView {
    
    @IBInspectable open var startColor:UIColor = UIColor(white: 0, alpha: 0.5) {
        didSet { colors = [startColor, endColor] }
    }
    
    @IBInspectable open var endColor:UIColor = UIColor.clear {
        didSet { colors = [startColor, endColor] }
    }
    
}
