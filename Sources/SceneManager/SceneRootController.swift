//
//  SceneRootController.swift
//  SceneManager
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit
import Adapter

public protocol SceneRootController {
    var rootNavigationController:UINavigationController? { get }
}


extension UIView : Viewer {}
