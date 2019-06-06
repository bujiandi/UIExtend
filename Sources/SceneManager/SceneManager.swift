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
        mainWindow.rootViewController?.view.setNeedsDisplay()
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
            scene?.building(with: paramValues)
        }
        
    }
    
    var sceneStack:[SceneCloseAction] = [SceneCloseAction]()
    
    public func push<S:Scene>(_ scene:S, pop closure: @escaping (Bool) -> Void) {
        sceneStack.append(SceneCloseAction(scene as AnyObject, pop: closure))
    }
    
    public func present<S:Scene>(_ scene:S, dismiss closure: @escaping (Bool) -> Void) {
        sceneStack.append(SceneCloseAction(scene as AnyObject, dismiss: closure))
    }
    
    public func wasCurrent<S:Scene>(scene:S) -> Bool {
        return scene === sceneStack.last?.scene
    }
    
    /// 简单返回上一场景, 不出发onBuild
    public func backToPrevious(animated flag:Bool = true) {
        if sceneStack.count == 1 { return }
        let lastSceneAction = sceneStack.removeLast()
        lastSceneAction.dismissWithAnimated(flag)
        lastSceneAction.popWithAnimated(flag)
    }
    
    /// 返回到根
    public func backToRoot(animated flag:Bool = true) {
        if sceneStack.count == 1 { return }
        let lastSceneAction = sceneStack.removeLast()
        lastSceneAction.dismissWithAnimated(flag)
        
        for i in (1..<sceneStack.count).reversed() {
            sceneStack[i].dismissWithAnimated(false)
            sceneStack.remove(at: i)
        }
        // 如果没找到所需退回的页面,则尝试退到根页面
        if let rootScene = sceneStack.first?.scene as? SceneIsRoot {
            lastSceneAction.popWithAnimated(flag)
            DispatchQueue.main.async { [weak rootScene] in
                rootScene?.onBuild()
            }
        } else if sceneStack.first?.scene is Scene {
            lastSceneAction.popWithAnimated(flag)
        }
    }
    
    /// 返回到指定页面
    public func back<S:Scene>(to sceneType:S.Type, animated flag:Bool = true) where S.Params == Scene.Null {
        back(to: sceneType, animated: flag, with: {})
    }
    
    /// 返回到指定页面
    public func back<S:Scene>(to sceneType:S.Type, animated flag:Bool = true, with params:@autoclosure () -> S.Params) {
        if sceneStack.count == 1 { return }
        let lastSceneAction = sceneStack.removeLast()
        
        CATransaction.begin()
        lastSceneAction.dismissWithAnimated(flag)
        for i in (0..<sceneStack.count).reversed() {
            if let scene = sceneStack[i].scene as? S {
                lastSceneAction.popWithAnimated(flag)
                if !(scene.vc?.isViewLoaded ?? flag) {
                    scene.vc.view.setNeedsLayout()
                }
                let paramValues = params()
                DispatchQueue.main.async { [weak scene] in
                    scene?.onBuild(with: paramValues)
                }
                CATransaction.commit()
                return
            } else if i > 0 {
                sceneStack[i].dismissWithAnimated(flag)
                sceneStack[i].popWithAnimated(false)
                sceneStack.remove(at: i)
            }
        }
        // 如果没找到所需退回的页面,则尝试退到根页面
        if let rootScene = sceneStack.first?.scene as? SceneIsRoot {
            lastSceneAction.popWithAnimated(flag)
            DispatchQueue.main.async { [weak rootScene] in
                rootScene?.onBuild()
            }
        } else if sceneStack.first?.scene is S {
            lastSceneAction.popWithAnimated(flag)
        }
        CATransaction.commit()
    }
}
