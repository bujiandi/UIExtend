//
//  Scene.swift
//  SceneKit
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
