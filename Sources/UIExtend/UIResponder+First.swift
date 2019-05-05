//
//  UIResponder+First.swift
//  Toast
//
//  Created by 李招利 on 2018/11/12.
//  Copyright © 2018 yFenFen. All rights reserved.
//

import UIKit
import ObjectiveC.runtime

private weak var ff_currentFirstResponder: UIResponder?
private let kGetFirstResponder:NSNumber = -159287123

private var isSwizzleFirstResponder = false

public final class FirstResponderListener {
    
    public var value:UIResponder? {
        didSet {
            guard let val = value, val !== oldValue else { return }
            observers = observers.filter {
                if $0.target == nil { return false }
                $0.notice(val)
                return true
            }
        }
    }
    
    private var observers:[Observer] = []
    
    init() {
        if !isSwizzleFirstResponder {
            isSwizzleFirstResponder = true
            replaceBecomeFirstResponder()
            replaceResignFirstResponder()
        }
        value = UIResponder.firstResponder()
    }
    
    private func replaceBecomeFirstResponder() {
        
        let method1 = class_getInstanceMethod(UIResponder.self, #selector(UIResponder.becomeFirstResponder))!
        let method2 = class_getInstanceMethod(UIResponder.self, #selector(UIResponder.swizzle_becomeFirstResponder))!
        
        method_exchangeImplementations(method1, method2)
    }
    
    private func replaceResignFirstResponder() {
        
        let method1 = class_getInstanceMethod(UIResponder.self, #selector(UIResponder.resignFirstResponder))!
        let method2 = class_getInstanceMethod(UIResponder.self, #selector(UIResponder.swizzle_resignFirstResponder))!
        
        method_exchangeImplementations(method1, method2)
    }
    
    public func addNotice(target: AnyObject, change: @escaping (UIResponder?) -> Void) {
        observers.append(Observer(target, change))
    }
    
    public func addNotice(target: AnyObject, action: Selector, needRelease:Bool = false) {
        observers.append(Observer(target, action, needRelease))
    }
    
    public func removeNotice(target: AnyObject) {
        observers = observers.filter { $0.target != nil && $0.target !== target }
    }
}

extension FirstResponderListener {
    
    fileprivate struct Observer {
        
        weak var target:AnyObject?
        
        var notice : Notice
        
        typealias Notice = (_ new:UIResponder) -> Void
        
        init(_ target: AnyObject, _ notice: @escaping Notice) {
            self.target = target
            self.notice = notice
        }
        
        init(_ target: AnyObject, _ action: Selector, _ needRelease:Bool = false) {
            self.target = target
            self.notice = { [weak target] in
                let r = target?.perform(action, with: $0)
                if needRelease {
                    r?.release()
                }
            }
        }
    }
    
}

extension UIResponder {
    
    
    @objc fileprivate func swizzle_becomeFirstResponder() -> Bool {
        let result = swizzle_becomeFirstResponder()
        
        if  result {
            UIApplication.firstResponderListener.value = self
        }
        return result
    }
    
    @objc fileprivate func swizzle_resignFirstResponder() -> Bool {
        let result = swizzle_resignFirstResponder()
        
        if  result, UIApplication.firstResponderListener.value === self {
            UIApplication.firstResponderListener.value = nil
        }
        return result
    }
    
}

extension UIApplication {
    
    public static let firstResponderListener = FirstResponderListener()
 
    public final func firstResponder() -> UIResponder? {
        return UIResponder.firstResponder()
    }
    
}

extension UIResponder {
    
    public static func firstResponder() -> UIResponder? {
        ff_currentFirstResponder = nil
        // 通过将target设置为nil，让系统自动遍历响应链
        // 从而响应链当前第一响应者响应我们自定义的方法
        UIApplication.shared.sendAction(#selector(ff_findFirstResponder(_:)), to: nil, from: kGetFirstResponder, for: nil)
        return ff_currentFirstResponder
    }
    
    @objc private func ff_findFirstResponder(_ sender: Any?) {
        // 第一响应者会响应这个方法，并且将静态变量wty_currentFirstResponder设置为自己
        switch sender {
        case let num as NSNumber where num.intValue == kGetFirstResponder.intValue:
            ff_currentFirstResponder = self
        default: break
        }
        
    }
}

/*
前言

在iOS中，当发生事件响应时，必须知道由谁来响应事件。而UIResponder类就是专门用来响应用户的操作，处理各种事件的，包括触摸事件(Touch Events)、运动事件(Motion Events)和远程控制事件(Remote Control Events)。iOS处理事件的流程将遵循一个不同对象组成的层次结构，也就是响应者链(Responder Chain)，网上目前有很多关于响应者链的介绍，这里就不再细讲。在响应者链中非常重要的一个概念就是第一响应者(First Responder)，当前第一响应者负责响应事件，或将事件传递给下一响应者。

在编写iOS程序时，我们经常会遇到需要获取当前的第一响应者，例如系统弹出键盘时，我们希望得到当前输入框(也就是第一响应者)的Frame，从而调整视图避免键盘遮挡输入框。然而UIKit并没有提供官方的API专门用于该用途。本文将介绍一种非常简单的且未用到私有API的方法来获取当前第一响应者。

实现思路

常规思路

通过遍历当前UIWindow的所有子视图，从而找到当前的第一响应者。这种方法首先需要做非常多的递归调用，从而判断所有子视图，同时当前响应链上的第一响应者还有可能是子视图的ViewController，这种方法也会漏掉。

使用私有API的思路

使用苹果的私有API可以很容易地解决这个问题，然而苹果不会允许使用私有API的App上架App Store，而且私有API很有可能随时变化，所以这种方式也很不完美。

UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
UIView *firstResponder = [keyWindow performSelector:@selector(firstResponder)];
本文的思路

本文的思路用到的核心Public API就是
    
    - (BOOL)sendAction:(SEL)action to:(id)target from:(id)sender forEvent:(UIEvent *)event
苹果文档对该API的target参数的描述如下：

The object to receive the action message. If target is nil, the app sends the message to the first responder, from whence it progresses up the responder chain until it is handled.
从而可知，利用该API，只要将传入的target设置为nil，则系统会自动顺着响应链查找能够响应action的响应者。我们只需让所有UIResponder的子类都响应我们自定义的action，即可知道当前第一响应者是哪个对象。

实现方法

为实现本文的思路，我们需要为UIResponder提供一个Category(objc)或者Extension(swift)。

Objective-C

// UIResponder+WTYFirstResponder.h
#import <UIKit/UIKit.h>

@interface UIResponder (WTYFirstResponder)
//使用时只需要对UIResponder类调用该类方法即可获得当前第一响应者
+ (id)wty_currentFirstResponder;
@end

//  UIResponder+WTYFirstResponder.m
#import "UIResponder+WTYFirstResponder.h"

static __weak id wty_currentFirstResponder;

@implementation UIResponder (WTYFirstResponder)
+ (id)wty_currentFirstResponder {
    wty_currentFirstResponder = nil;
    // 通过将target设置为nil，让系统自动遍历响应链
    // 从而响应链当前第一响应者响应我们自定义的方法
    [[UIApplication sharedApplication] sendAction:@selector(wty_findFirstResponder:)
        to:nil
        from:nil
        forEvent:nil];
    return wty_currentFirstResponder;
    }
    - (void)wty_findFirstResponder:(id)sender {
        // 第一响应者会响应这个方法，并且将静态变量wty_currentFirstResponder设置为自己
        wty_currentFirstResponder = self;
}
@end
使用方法

#import "UIResponder+WTYFirstResponder.h"

id firstResponder = [UIResponder wty_firstResponder];

Swift

//  UIResponder+WTYFirstResponder.swift

import UIKit

private weak var wty_currentFirstResponder: AnyObject?

extension UIResponder {
    
    static func wty_firstResponder() -> AnyObject? {
        wty_currentFirstResponder = nil
        // 通过将target设置为nil，让系统自动遍历响应链
        // 从而响应链当前第一响应者响应我们自定义的方法
        UIApplication.shared.sendAction(#selector(wty_findFirstResponder(_:)), to: nil, from: nil, for: nil)
        return wty_currentFirstResponder
    }
    
    func wty_findFirstResponder(_ sender: AnyObject) {
        // 第一响应者会响应这个方法，并且将静态变量wty_currentFirstResponder设置为自己
        wty_currentFirstResponder = self
    }
}
使用方法

firstResponder = UIResponder.wty_firstResponder()
思路衍生

如果只希望让第一响应者取消其第一响应者的状态，则可以做如下操作:

Objective-C

[[UIApplication sharedApplication] sendAction:@selector(resignFirstResponder) to:nil from:nil forEvent:nil];
Swift

UIApplication.shared.sendAction(#selector(resignFirstResponder), to: nil, from: nil, for: nil)

作者：wty21cn
链接：https://www.jianshu.com/p/84c0eddf2378
來源：简书
简书著作权归作者所有，任何形式的转载都请联系作者获得授权并注明出处。
*/
