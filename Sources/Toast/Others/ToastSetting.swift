//
//  ToastSetting.swift
//  Toast
//
//  Created by 慧趣小歪 on 2017/8/20.
//  Copyright © 2017年 yFenFen. All rights reserved.
//

import UIKit

public struct ToastSetting {
    
    /// Toast 默认消息字体
    public var font:UIFont = UIFont.systemFont(ofSize: 15)
    
    /// Toast 最大数量
    public var maxCount:Int = 3
    /// Toast 相对位置y值
    public var yMultiplier:CGFloat = 0.8
    
    /// Toast 提示间距
    public var interval:CGFloat = 15
    
    /// Toast 默认持续时间
    public var holdSecond:TimeInterval = 3.5
    
    /// Toast 动画时长
    public var animDuration:TimeInterval = 0.35
    public var animCustomDamping:CGFloat = 0.9
    public var animActiveDamping:CGFloat = 0.8
    public var animBubbleDamping:CGFloat = 0.8
    
    /// Toast 文字边框间距
    public var padding:UIEdgeInsets = UIEdgeInsets(top: 8, left: 15, bottom: 8, right: 15)
    
    public var marginScreenLeft:CGFloat = 15
    public var marginScreenRight:CGFloat = 15
    
    public var cornerRadius:CGFloat = 5
    public var borderWidth:CGFloat = Toast.onePixel
    public var borderColor:UIColor = UIColor(white: 0.3, alpha: 1)
}
