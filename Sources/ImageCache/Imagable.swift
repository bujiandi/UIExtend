//
//  Imagable.swift
//  ImageCache
//
//  Created by bujiandi on 2018/10/25.
//  Copyright © 2018 bujiandi. All rights reserved.
//

import UIKit

public enum ImageType {
    case image(UIImage)
    case href(String)
}


public protocol Imagable : class {
    
    func update(image:UIImage?)
    func updateComplete()
    
}


extension UIImageView : Imagable {
    
    public func updateComplete() {
    }
    
    public func update(image:UIImage?) {
        self.image = image
    }
    
}


public class ImageDispalyer: Imagable {
    
    public func update(image:UIImage?) {
        action(image)
    }
    
    public var action:(UIImage?) -> Void
    
    public var remove:(()->Void)?
    
    init(_ block: @escaping (UIImage?) -> Void) {
        action = block
    }
    
    public func updateComplete() {
        remove?()
    }
    
}


private var kButtonBackgroundImage = "button.background.image"
extension UIButton : Imagable {
    
    public func updateComplete() {
    }
    
    public func update(image:UIImage?) {
        setImage(image, for: .normal)
    }
    
    public var backgroundImage:ImageDispalyer {
        var dispalyer = objc_getAssociatedObject(self, &kButtonBackgroundImage) as? ImageDispalyer
        if  dispalyer == nil {
            dispalyer = ImageDispalyer() { [weak self] in
                self?.setBackgroundImage($0, for: .normal)
            }
            dispalyer?.remove = { [weak self] in
                guard let this = self else { return }
                objc_setAssociatedObject(this, &kButtonBackgroundImage, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            objc_setAssociatedObject(self, &kButtonBackgroundImage, dispalyer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return dispalyer!
    }
}
