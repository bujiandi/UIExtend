//
//  Scene.swift
//  SceneManager
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit

public protocol Scene: class {
    
    typealias Null = () -> Void
    
    associatedtype VC : UIViewController
    associatedtype Params
    
    var vc:VC! { get }
    
    func onBuild(with params:Params)
    
}

extension Scene {
    
    // 推入下一个页面
    public func push<S:Scene>(scene:S, with params: @autoclosure () -> S.Params, animated flag: Bool = true) {
        _push(scene, animated: flag)
        _loadSceneIfNeed(scene)
        scene.onBuild(with: params())
    }
    
    
    // 推入下一个页面
    public func push<S:Scene>(scene:S, animated flag: Bool = true) where S.Params == Null {
        _push(scene, animated: flag)
        _loadSceneIfNeed(scene)
        scene.onBuild{}
    }
    
    // 呈现下一个页面
    public func present<S:Scene>(scene:S, with params: @autoclosure () -> S.Params, animated flag: Bool = true) {
        _present(scene, animated: flag)
        _loadSceneIfNeed(scene)
        scene.onBuild(with: params())
    }
    
    
    // 呈现下一个页面
    public func present<S:Scene>(scene:S, animated flag: Bool = true) where S.Params == Null {
        _present(scene, animated: flag)
        _loadSceneIfNeed(scene)
        scene.onBuild{}
    }
    
    private func _loadSceneIfNeed<S:Scene>(_ scene:S) {
        if !(scene.vc?.isViewLoaded ?? true) {
//            scene.vc.loadView()
            scene.vc.view.setNeedsLayout()
        }
    }
    
    private func _present<S:Scene>(_ scene:S, animated flag: Bool = true) {
        // 遵从可能的页面显示方式
        if let naviClazz = vc.navigationController?.classForCoder as? UINavigationController.Type {
            // 若前置页面有导航则创建默认导航
            let navi:UINavigationController! = naviClazz.init()
            navi.setViewControllers([scene.vc], animated: false)
            vc.present(navi, animated: flag, completion: nil)
            SceneManager.shared.present(scene, dismiss: { [weak navi] in
                navi?.autoDismiss(animated: $0)
                
            })
        } else {
            vc.present(scene.vc, animated: flag, completion: nil)
            SceneManager.shared.present(scene, dismiss: { [weak scene] in
                guard let scene = scene else { return }
                scene.vc.autoDismiss(animated: $0)
            })
        }
    }
    
    private func _push<S:Scene>(_ scene:S, animated flag: Bool = true) {
        
        if let navi = vc as? UINavigationController {
            // 如果自身是导航控制器,直接Push
            navi.pushViewController(scene.vc, animated: flag)
            SceneManager.shared.push(scene, pop: { [weak navi] in
                navi?.popToRootViewController(animated: $0)
            })
        } else if let navi = vc.navigationController {
            // 如果从属导航控制器,则主NaviVC Push
            navi.pushViewController(scene.vc, animated: flag)
            weak var controller:UIViewController? = vc
            SceneManager.shared.push(scene, pop: { [weak navi] in
                guard let navi = navi else { return }
                if !$0,
                    let vc = controller,
                    let index = navi.viewControllers.lastIndex(of: vc),
                    index + 1 < navi.viewControllers.count {
                    navi.viewControllers.remove(at: index + 1)
                } else if $0 {
                    navi.popViewController(animated: $0)
                } else if let vc = controller {
                    navi.popToViewController(vc, animated: $0)
                } else {
                    navi.popViewController(animated: $0)
                }
            })
        } else {
            // 遵从可能的页面显示方式
            _present(scene, animated: flag)
        }
        
    }
    
    // 返回到根
    public func backToRoot() {
        if SceneManager.shared.sceneStack.count == 1 { return }
        let sceneManager = SceneManager.shared
        let lastSceneAction = sceneManager.sceneStack.removeLast()
        lastSceneAction.dismissWithAnimated(true)
        
        for i in (1..<sceneManager.sceneStack.count).reversed() {
            sceneManager.sceneStack[i].dismissWithAnimated(false)
            sceneManager.sceneStack.remove(at: i)
        }
        // 如果没找到所需退回的页面,则尝试退到根页面
        if let rootScene = sceneManager.sceneStack.first?.scene as? SceneIsRoot {
            lastSceneAction.popWithAnimated(true)
            rootScene.onBuild()
        } else if sceneManager.sceneStack.first?.scene is Scene {
            lastSceneAction.popWithAnimated(true)
        }
    }
    
    public func back<S:Scene>(to sceneType:S.Type) where S.Params == Null {
        back(to: sceneType, with: {})
    }
    
    // 返回到指定页面
    public func back<S:Scene>(to sceneType:S.Type, with params:S.Params) {
        if SceneManager.shared.sceneStack.count == 1 { return }
        let this = self as AnyObject
        let sceneManager = SceneManager.shared
        let lastSceneAction = sceneManager.sceneStack.removeLast()
        guard this === lastSceneAction.scene else {
            fatalError("unknow pop to \(sceneType) from \(self)")
        }
        
        CATransaction.begin()
        lastSceneAction.dismissWithAnimated(true)
        for i in (0..<sceneManager.sceneStack.count).reversed() {
            if let scene = sceneManager.sceneStack[i].scene as? S {
                lastSceneAction.popWithAnimated(true)
                _loadSceneIfNeed(scene)
                scene.onBuild(with: params)
                CATransaction.commit()
                return
            } else if i > 0 {
                sceneManager.sceneStack[i].dismissWithAnimated(true)
                sceneManager.sceneStack[i].popWithAnimated(false)
                sceneManager.sceneStack.remove(at: i)
            }
        }
        // 如果没找到所需退回的页面,则尝试退到根页面
        if let rootScene = sceneManager.sceneStack.first?.scene as? SceneIsRoot {
            lastSceneAction.popWithAnimated(true)
            rootScene.onBuild()
        } else if sceneManager.sceneStack.first?.scene is S {
            lastSceneAction.popWithAnimated(true)
        }
        CATransaction.commit()
    }
    
    
}

extension UIViewController {
    
    var isPresentedBeingDismissed:Bool {
        if let navi = self as? UINavigationController {
            return navi.topViewController?.presentedViewController?.isBeingDismissed ?? isBeingDismissed
        }
        return presentedViewController?.isBeingDismissed ?? isBeingDismissed
    }
    
    @available(iOS 5.0, *)
    open func autoDismiss(animated flag: Bool) {
        
//        print(isBeingDismissed, title, flag)
        if isPresentedBeingDismissed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) { [weak self] in
                self?.autoDismiss(animated: flag)
            }
        } else {
            
            dismiss(animated: flag, completion: nil)
        }
    }
    
}

public protocol SceneIsRoot : class {
    
    func onBuild()
    
}
