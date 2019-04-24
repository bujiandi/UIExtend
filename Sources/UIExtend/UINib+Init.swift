//
//  UINib+Init.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/3/1.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

public protocol UINibCreater {
    func nib(in bundle:Bundle?) -> UINib
    func storyboard(in bundle:Bundle?) -> UIStoryboard
}

extension String : UINibCreater {
    
    public func nib(in bundle:Bundle? = nil) -> UINib {
        return UINib(nibName: self, bundle: bundle)
    }
    
    public func storyboard(in bundle:Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: self, bundle: bundle)
    }
    
}

public protocol UINibInstantiable: class {
    
    static func instantiate(atNib index:Int, withOwner owner: Any?) -> Self
}

extension UINibInstantiable where Self : UIView {
    
    public static func instantiate(atNib index:Int, withOwner owner: Any? = nil) -> Self {
        
        let identifier = NSStringFromClass(classForCoder()).split(separator: ".").last!.description
        
        return identifier.nib().instantiate(withOwner: owner, options: nil)[index] as! Self
    }
}

extension UINibInstantiable where Self : NSObject {
    
    public static func instantiate(atNib index:Int, withOwner owner: Any? = nil) -> Self {
        
        let identifier = NSStringFromClass(classForCoder()).split(separator: ".").last!.description
        
        return identifier.nib().instantiate(withOwner: owner, options: nil)[index] as! Self
    }
}

extension RawRepresentable where RawValue == String {
    
    public func nib(in bundle:Bundle? = nil) -> UINib {
        return UINib(nibName: rawValue, bundle: bundle)
    }
    
    public func storyboard(in bundle:Bundle? = nil) -> UIStoryboard {
        return UIStoryboard(name: rawValue, bundle: bundle)
    }
    
}

extension UIStoryboard {
    
    public func instantiateViewController<C>(with clz:C.Type) -> C where C : UIViewController {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        return instantiateViewController(withIdentifier: identifier) as! C
    }
    
}

extension UITableView {
    
    
    public func register<C>(nibHeaderOrFooter reused:C) where C : RawRepresentable, C.RawValue == String {
        register(reused.nib(), forHeaderFooterViewReuseIdentifier: reused.rawValue)
    }
    public func register<C>(headerOrFooter clz:C.Type) where C : UITableViewHeaderFooterView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(clz as AnyClass, forHeaderFooterViewReuseIdentifier: identifier)
    }
    public func register<C>(nibHeaderOrFooter clz:C.Type) where C : UITableViewHeaderFooterView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(identifier.nib(), forHeaderFooterViewReuseIdentifier: identifier)
    }
    
    public func register<C>(nibCell reused:C) where C : RawRepresentable, C.RawValue == String {
        register(reused.nib(), forCellReuseIdentifier: reused.rawValue)
    }
    public func register<C>(cell clz:C.Type) where C : UITableViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(clz as AnyClass, forCellReuseIdentifier: identifier)
    }
    public func register<C>(nibCell clz:C.Type) where C : UITableViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(identifier.nib(), forCellReuseIdentifier: identifier)
    }
    
    public func dequeueReusable<C>(cell reused: C, for indexPath: IndexPath) -> UITableViewCell where C : RawRepresentable, C.RawValue == String {
        return dequeueReusableCell(withIdentifier: reused.rawValue, for: indexPath)
    }
    public func dequeueReusable<C>(cell clz: C.Type, for indexPath: IndexPath) -> C where C : UITableViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        return dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! C
    }
    
    public func dequeueReusable<C>(headerOrFooter reused: C) -> UITableViewHeaderFooterView? where C : RawRepresentable, C.RawValue == String {
        
        return dequeueReusableHeaderFooterView(withIdentifier: reused.rawValue)
    }
    public func dequeueReusable<C>(headerOrFooter clz: C.Type) -> C? where C : UITableViewHeaderFooterView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description

        return dequeueReusableHeaderFooterView(withIdentifier: identifier) as? C
    }
}



extension UICollectionView {
    
    
    public func register<C>(cell clz:C.Type) where C : UICollectionViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(clz as AnyClass, forCellWithReuseIdentifier: identifier)
    }
    
    public func register<C>(nibCell clz:C.Type) where C : UICollectionViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(identifier.nib(), forCellWithReuseIdentifier: identifier)
    }
    
    public func register<C>(header clz:C.Type) where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(clz as AnyClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    public func register<C>(nibHeader clz:C.Type) where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(identifier.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier)
    }
    
    public func register<C>(footer clz:C.Type) where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(clz as AnyClass, forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    public func register<C>(nibFooter clz:C.Type) where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        register(identifier.nib(), forSupplementaryViewOfKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier)
    }
    
    public func dequeueReusable<C>(cell clz: C.Type, for indexPath: IndexPath) -> C where C : UICollectionViewCell {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        return dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! C
    }

    public func dequeueReusable<C>(header clz: C.Type, for indexPath: IndexPath) -> C where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: identifier, for: indexPath) as! C
    }
    
    public func dequeueReusable<C>(footer clz: C.Type, for indexPath: IndexPath) -> C where C : UICollectionReusableView {
        let identifier = NSStringFromClass(clz as AnyClass).split(separator: ".").last!.description
        
        return dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: identifier, for: indexPath) as! C
    }
}
// 构造方法行不通
//extension UINib : ExpressibleByStringLiteral {
//    public typealias StringLiteralType = StaticString
//    public typealias UnicodeScalarLiteralType = UnicodeScalarType
//    public typealias ExtendedGraphemeClusterLiteralType = String
//    public convenience init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
//        self.init(nibName: value, bundle: nil)
//    }
//    public convenience init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
//        self.init(nibName: value.description, bundle: nil)
//    }
//    public convenience init(stringLiteral value: StringLiteralType) {
//        self.init(nibName: value.description, bundle: nil)
//    }
//}

