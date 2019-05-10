//
//  SceneManager.swift
//  SceneKit
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit

open class SceneManager {
    
    public static let shared:SceneManager = SceneManager()
    
    open var mainWindow:UIWindow! {
        
        if let window = UIApplication.shared.delegate?.window as? UIWindow {
            return window
        } else {
            for window in UIApplication.shared.windows where window.windowLevel == .normal && !window.isHidden {
                return window
            }
            return UIApplication.shared.windows.first
        }
        
    }
    
    open func setRoot<S:Scene>(_ scene:S, animated flag: Bool = true) where S.Params == Scene.Null {
        setRoot(scene, with: {}, animated: flag)
    }
    
    open func setRoot<S:Scene>(_ scene:S, with params: @autoclosure () -> S.Params, animated flag: Bool = true) {
        sceneStack = [SceneCloseAction(scene as AnyObject, pop: { _ in })]
        if  let root = mainWindow.rootViewController as? SceneRootController,
            let navi = root.rootNavigationController {
            navi.setViewControllers([scene.vc], animated: flag)
        } else if let navi = mainWindow?.rootViewController as? UINavigationController {
            navi.setViewControllers([scene.vc], animated: flag)
        } else if let window = mainWindow {
            if flag {
                UIView.transition(with: window, duration: 0.25, options: [
                    .curveEaseInOut,
                    .transitionCrossDissolve,
                    .beginFromCurrentState,
                    .preferredFramesPerSecond60
                    ], animations: { [weak window, weak scene] in
                        window?.rootViewController = scene?.vc
                    }, completion: nil)
            } else {
                window.rootViewController = scene.vc
            }
        }
        if !(scene.vc?.isViewLoaded ?? true) {
            scene.vc.view.setNeedsLayout()
        }
        let paramValues = params()
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild(with: paramValues)
        }
        
    }
    
    var sceneStack:[SceneCloseAction] = [SceneCloseAction]()
    
    public func push<S:Scene>(_ scene:S, pop: @escaping (Bool) -> Void) {
        sceneStack.append(SceneCloseAction(scene as AnyObject, pop: pop))
    }
    
    public func present<S:Scene>(_ scene:S, dismiss: @escaping (Bool) -> Void) {
        sceneStack.append(SceneCloseAction(scene as AnyObject, dismiss: dismiss))
    }
}
