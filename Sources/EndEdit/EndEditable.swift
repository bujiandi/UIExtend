//
//  EndEditable.swift
//  ScoreLib
//
//  Created by bujiandi on 2018/8/2.
//  Copyright © 2018 bujiandi. All rights reserved.
//

import UIKit

public protocol EndEditable: class {
    
    var excludeViews:[UIView] { get }
    
    func endEditing(_ force: Bool) -> Bool
    func convert(_ point: CGPoint, to view: UIView?) -> CGPoint
}

extension EndEditable {
    
    public func endEditTest(point:CGPoint, in view:UIView?) {
        
        var parent:UIView! = view
        
        while parent != nil {
            if parent.isKind(of: UITextField.self)  {
                return
            }
            if parent.isKind(of: UITextView.self)  {
                return
            }
            if parent.isKind(of: UISearchBar.self) {
                return
            }
            if parent is UITextInput {
                return
            }
            if parent.canBecomeFirstResponder {
                return
            }
            for excludeView in excludeViews {
                if  excludeView === parent,
                    excludeView.frame.contains(convert(point, to: excludeView.superview)) {
                    return
                }
            }
            parent = parent.superview
        }
        DispatchQueue.main.async { [weak self] in
            _ = self?.endEditing(true)
        }
    }
    
    
}
