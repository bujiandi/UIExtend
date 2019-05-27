//
//  Refresh.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/6.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

extension UIEdgeInsets {
    
    @inline(__always)
    public static func +(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: lhs.top + rhs.top, left: lhs.left + rhs.left, bottom: lhs.bottom + rhs.bottom, right: lhs.right + rhs.right)
    }
    
    @inline(__always)
    public static func -(lhs: UIEdgeInsets, rhs: UIEdgeInsets) -> UIEdgeInsets {
        return UIEdgeInsets.init(top: lhs.top - rhs.top, left: lhs.left - rhs.left, bottom: lhs.bottom - rhs.bottom, right: lhs.right - rhs.right)
    }

    @inline(__always)
    public static func +=(lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) {
        lhs.top += rhs.top
        lhs.left += rhs.left
        lhs.bottom += rhs.bottom
        lhs.right += rhs.right
    }
    
    @inline(__always)
    public static func -=(lhs: inout UIEdgeInsets, rhs: UIEdgeInsets) {
        lhs.top -= rhs.top
        lhs.left -= rhs.left
        lhs.bottom -= rhs.bottom
        lhs.right -= rhs.right
    }
}

public struct HeaderRefresh {
    public static var normalText:String     = "下拉既可刷新"
    public static var pullingText:String    = "松开既可刷新"
    public static var loadingText:String    = "正在刷新数据..."
    public static var noMoreDataText:String = "没有数据更新"
}

public struct FooterRefresh {
    public static var normalText:String     = "上拉加载更多"
    public static var pullingText:String    = "松开加载更多"
    public static var loadingText:String    = "正在加载更多..."
    public static var noMoreDataText:String = "数据已全加载"
}


public enum RefreshState: Int {
    case normal, pulling, loading, noMoreData, updateInsets
}

public protocol Animationable {
        
    func startAnimating()
    
    func stopAnimating()
    
    var isAnimating: Bool { get }
    
    func pulling(percent:CGFloat)
    
}

extension Animationable {
    public func getState(by percent:CGFloat) -> RefreshState {
        if /* -2 */ percent < -1 { return .noMoreData
        } else if   percent <  0 { return .normal
        } else if   percent >  1 { return .loading
        } else if   percent == 1 { return .pulling
        } else     /* 0 ..< 1 */ { return .normal
        }
    }

    fileprivate func stopAnimatingIfNeed() {
        if isAnimating { stopAnimating() }
    }
}

extension UIActivityIndicatorView : Animationable {
    public func pulling(percent: CGFloat) {
        switch getState(by: percent) {
        case .loading:
            layer.repeatDuration = 0
            layer.speed = 1
            startAnimating()
        default:
            if percent <= 1 && percent >= 0 {
                if !isAnimating {
                    startAnimating()
                    layer.speed = 0
                    layer.repeatDuration = layer.convertTime(0, from: nil)
                }
                layer.timeOffset = layer.repeatDuration + Double(percent * .pi / 2)
            } else {
                layer.repeatDuration = 0
                layer.speed = 1
                stopAnimatingIfNeed()
            }
        }
    }
}

extension UIImageView : Animationable {
    public func pulling(percent: CGFloat) {
        switch getState(by: percent) {
        case .loading:
            layer.repeatDuration = 0
            layer.speed = 1
            startAnimating()
        default:
            if percent <= 1 && percent >= 0 {
                if !isAnimating {
                    startAnimating()
                    layer.speed = 0
                    layer.repeatDuration = layer.convertTime(0, from: nil)
                }
                layer.timeOffset = layer.repeatDuration + Double(percent * .pi / 2)
            } else {
                layer.repeatDuration = 0
                layer.speed = 1
                stopAnimatingIfNeed()
            }
        }
    }
}

public typealias RefreshContent = UIView & Animationable
