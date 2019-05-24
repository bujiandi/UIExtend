//
//  SceneRootController.swift
//  SceneManager
//
//  Created by bujiandi on 2019/4/24.
//

import UIKit
import Displayer

public protocol SceneRootController {
    var rootNavigationController:UINavigationController? { get }
}


extension UIView : Viewer {}
