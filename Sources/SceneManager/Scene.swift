//
//  Scene.swift
//  SceneManager
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit
//#if canImport(Toast)
import Toast
//#endif

public protocol Scene: class {
    
    typealias Null = () -> Void
    
    associatedtype VC : UIViewController
    associatedtype Params
    
    var vc:VC! { get }
    
    func onBuild(with params:Params)
    
}

//#if canImport(Toast)

public enum ToastLevel:Int, Codable {
    case custom
    case dialog
    case active
}

extension Scene {
    
    /// Toast overlay 覆盖显示下一个页面
    @discardableResult
    public func toast<S:Scene>(scene:S, atLevel level:ToastLevel = .custom, with params: @autoclosure () -> S.Params, animated flag: Bool = true) -> ToastOverlay {
        let custom = _toast(scene, atLevel: level, animated: flag)
        _loadSceneIfNeed(scene)
        let paramValues = params()
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild(with: paramValues)
        }
        return custom
    }
    
    /// Toast overlay 覆盖显示下一个页面
    @discardableResult
    public func toast<S:Scene>(scene:S, atLevel level:ToastLevel = .custom, animated flag: Bool = true) -> ToastOverlay where S.Params == Null {
        let custom = _toast(scene, atLevel: level, animated: flag)
        _loadSceneIfNeed(scene)
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild{}
        }
        return custom
    }
    
    private func _toast<S:Scene>(_ scene:S, atLevel level:ToastLevel, animated flag: Bool = true) -> ToastOverlay {
        let container = UIView(frame: UIScreen.main.bounds)
        let toastTask:ToastOverlay
        let controller:UIViewController
        if let naviClazz = vc.navigationController?.classForCoder as? UINavigationController.Type {
            // 若前置页面有导航则创建默认导航
            let navi:UINavigationController! = naviClazz.init()
            navi.setViewControllers([scene.vc], animated: false)
            controller = navi
        } else {
            controller = scene.vc
        }
        // toast overlay window level
        switch level {
        case .custom:
            toastTask = Toast.custom(controller: controller, container: container)
        case .dialog:
            toastTask = Toast.dialog(controller: controller, container: container)
        case .active:
            toastTask = Toast.active(controller: controller, container: container)
        }
        
        toastTask.layoutContainerOn { (root, toast) in
            toast.container.layout(to: root, insets: .zero)
        }
        toastTask.layoutContentOn { (container, toast) in
            toast.content.layout(to: container, insets: .zero)
        }
        SceneManager.shared.present(scene, dismiss: {
            toastTask.hide(animated: $0)
        })
        defer {
            DispatchQueue.main.async { [weak toastTask] in
                toastTask?.show(animated: flag)
            }
        }
        return toastTask
    }
}

//#endif

extension Scene {
    
    /// 推入下一个页面
    public func push<S:Scene>(scene:S, with params: @autoclosure () -> S.Params, animated flag: Bool = true) {
        _push(scene, animated: flag)
        _loadSceneIfNeed(scene)
        let paramValues = params()
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild(with: paramValues)
        }
    }
    
    
    /// 推入下一个页面
    public func push<S:Scene>(scene:S, animated flag: Bool = true) where S.Params == Null {
        _push(scene, animated: flag)
        _loadSceneIfNeed(scene)
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild{}
        }
    }
    
    /// 呈现下一个页面
    public func present<S:Scene>(scene:S, with params: @autoclosure () -> S.Params, animated flag: Bool = true) {
        _present(scene, animated: flag)
        _loadSceneIfNeed(scene)
        let paramValues = params()
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild(with: paramValues)
        }
    }
    
    
    /// 呈现下一个页面
    public func present<S:Scene>(scene:S, animated flag: Bool = true) where S.Params == Null {
        _present(scene, animated: flag)
        _loadSceneIfNeed(scene)
        DispatchQueue.main.async { [weak scene] in
            scene?.onBuild{}
        }
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
    
    /// 本场景是当前场景
    @inlinable public var isCurrent:Bool {
        return SceneManager.shared.wasCurrent(scene: self)
    }
    
    /// 返回到上一个场景, 不触发 非SceneIsRoot 得 onBuild
    public func backToPrevious(animated flag:Bool = true) {
        let manager = SceneManager.shared
        if manager.sceneStack.count == 1 { return }
        let lastSceneAction = manager.sceneStack.removeLast()
        
        CATransaction.begin()
        lastSceneAction.dismissWithAnimated(flag)
        for i in (0..<manager.sceneStack.count).reversed() {
            if i > 0 {
                manager.sceneStack[i].dismissWithAnimated(flag)
                manager.sceneStack[i].popWithAnimated(false)
                manager.sceneStack.remove(at: i)
            }
            if manager.sceneStack[i].scene === self {
                lastSceneAction.popWithAnimated(flag)
                CATransaction.commit()
                return
            }
        }
        // 如果没找到所需退回的页面,则尝试退到根页面
        if let rootScene = manager.sceneStack.first?.scene as? SceneIsRoot {
            lastSceneAction.popWithAnimated(flag)
            DispatchQueue.main.async { [weak rootScene] in
                rootScene?.onBuild()
            }
        } else {
            lastSceneAction.popWithAnimated(flag)
        }
        CATransaction.commit()
    }

    
    /// 返回到根
    @inlinable public func backToRoot(animated flag:Bool = true) {
        SceneManager.shared.backToRoot(animated: flag)
    }
    
    /// 返回到指定页面
    @inlinable public func back<S:Scene>(to sceneType:S.Type, animated flag:Bool = true) where S.Params == Null {
        back(to: sceneType, animated: flag, with: {})
    }
    
    /// 返回到指定页面
    @inlinable public func back<S:Scene>(to sceneType:S.Type, animated flag:Bool = true, with params:@autoclosure () -> S.Params) {
        guard isCurrent else {
            fatalError("unknow pop to \(sceneType) from \(self)")
        }
        SceneManager.shared.back(to: sceneType, animated: flag, with: params())
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
