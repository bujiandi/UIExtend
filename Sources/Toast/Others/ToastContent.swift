//
//  Toast+View.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/5/23.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

public protocol ToastContent : class {
    
    var toastTask:ToastBaseTask? { get set }
    
}
