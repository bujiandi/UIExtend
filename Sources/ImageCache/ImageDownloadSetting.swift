//
//  ImageDownloadSetting.swift
//  ImageCache
//
//  Created by bujiandi on 2018/10/25.
//  Copyright © 2018 bujiandi. All rights reserved.
//

import UIKit


extension UIImage {
    
    public static var downloadSetting = Setting()
    
    public struct Setting {
        public var autoRetryCount:Int = 1
        public var placeholder:UIImage? = nil
        public var failure:UIImage? = nil
    }
    
}

