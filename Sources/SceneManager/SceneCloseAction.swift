//
//  SceneCloseAction.swift
//  SceneManager
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit

open class SceneCloseAction {
    
    let scene:AnyObject
    var dismissWithAnimated: (Bool) -> Void = { _ in }
    var popWithAnimated:(Bool) -> Void = { _ in }
    
    init(_ scene:AnyObject, dismiss: @escaping (Bool) -> Void ) {
        self.scene = scene
        self.dismissWithAnimated = dismiss
    }
    
    init(_ scene:AnyObject, pop: @escaping (Bool) -> Void ) {
        self.scene = scene
        self.popWithAnimated = pop
    }
    
}
