
import UIKit

public protocol KeyboardRootManager: class {
    
    var offsetLayout:NSLayoutConstraint? { get }
    
}

private var kKeyboardWillChangeFrameObserver = "KeyboardWillChangeFrameObserver"

extension KeyboardRootManager where Self : UIViewController {
    
    public func registerKeyboardEvent() {
        
        unregisterKeyboardEvent()
        
        let observer = NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillChangeFrameNotification, object: nil, queue: .main) { [weak self] in
            self?.keyboardWillChangeFrame($0)
        }
        
        objc_setAssociatedObject(self, &kKeyboardWillChangeFrameObserver, observer, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
    
    public func unregisterKeyboardEvent() {
        
        let center = NotificationCenter.default
        if let observer = objc_getAssociatedObject(self, &kKeyboardWillChangeFrameObserver) {
            center.removeObserver(observer)
            objc_setAssociatedObject(self, &kKeyboardWillChangeFrameObserver, nil, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }

    }
    
    private func keyboardWillChangeFrame(_ notification:Notification) {
        
        guard let info = notification.userInfo else { return }
        
        let endFrame = info[UIResponder.keyboardFrameEndUserInfoKey] as! CGRect
        let duration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! TimeInterval
        let curve    = info[UIResponder.keyboardAnimationCurveUserInfoKey] as! Int
        let options  = UIView.AnimationOptions(rawValue:UInt(curve))
        
        
        var view:UIView! = self.view//window.rootViewController?.view

        if let layout = offsetLayout {
            if let firstView = UIResponder.firstResponder() as? UIView {
                let viewFrame = view.convert(firstView.frame, from: firstView.superview)
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    layout.constant = endFrame.minY - min(viewFrame.maxY, UIScreen.main.bounds.height)
                    view.layoutIfNeeded()
                    
                }) { (finish:Bool) in
                    view = nil
                }
            } else {
                
                UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                    
                    layout.constant = endFrame.minY - UIScreen.main.bounds.height
                    view.layoutIfNeeded()
                    
                }) { (finish:Bool) in
                    view = nil
                }
            }
            
        } else {

            UIView.animate(withDuration: duration, delay: 0, options: options, animations: {
                
                view.frame.size.height = endFrame.minY
                view.layoutIfNeeded()
                
            }) { (finish:Bool) in
                view = nil
            }
        }
        
    }
}
