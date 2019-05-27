//
//  BasicRefreshView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/8.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

private let kPathContentSize = #keyPath(UIScrollView.contentSize)
private let kPathContentInset = #keyPath(UIScrollView.contentInset)
private let kPathContentOffset = #keyPath(UIScrollView.contentOffset)

private var KVOContext = "KVOContext"

open class RefreshView<V> : UIView where V : RefreshContent {
    
    var moveHeight:CGFloat = 0
    var moveOffset:CGFloat = 0
    
    open func printInset() {
        print(scrollViewAdjustedContentInsets,"AdjustedContentInsets")
        print(scrollViewOriginalEdgeInsets,"OriginalEdgeInsets")
    }
        
///    @available(iOS 11.0, *)
    var scrollViewAdjustedContentInsets:UIEdgeInsets = .zero
    var scrollViewOriginalEdgeInsets:UIEdgeInsets = .zero
    
    weak var constraint: NSLayoutConstraint?
    weak var scrollView: UIScrollView?
    
    open var hasBar:Bool = true
    
    open var state:RefreshState = .normal
    
    open var isNoMoreData:Bool { return state == .noMoreData }
    
    open var isHeader:Bool { return (self as AnyObject) is HeaderRefreshView<V> }
    open var isFooter:Bool { return (self as AnyObject) is FooterRefreshView<V> }
    
    open var contentView:V! {
        didSet { contentView.layout(toMargin: self, insets: layoutMargins) }
    }
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        updateRefreshViewOffset()
    }
    
    
    open var yOffset:CGFloat = 0 {
        didSet { updateRefreshViewOffset() }
    }
    
    var edgeOffset:UIEdgeInsets = .zero
    
    @discardableResult
    open func offset(_ value:CGFloat) -> Self {
        yOffset = value
        return self
    }
    
    open var contentHeight:CGFloat {
        let contentSize = contentView.systemLayoutSizeFitting(frame.size, withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .fittingSizeLevel)
        
        return max(contentSize.height + layoutMargins.top + layoutMargins.bottom, 44)
    }
    
    open func updateRefreshViewOffset() {
        updateContentInset()
    }
    
    open func removeObservers() {
        guard let scroll = superview as? UIScrollView else { return }
        
        scroll.removeObserver(self, forKeyPath: kPathContentSize, context: &KVOContext)
        scroll.removeObserver(self, forKeyPath: kPathContentInset, context: &KVOContext)
        scroll.removeObserver(self, forKeyPath: kPathContentOffset, context: &KVOContext)
    }
    
    open func addObservers(scrollView:UIScrollView) {
        
        scrollView.addObserver(self, forKeyPath: kPathContentSize, options: .new, context: &KVOContext)
        scrollView.addObserver(self, forKeyPath: kPathContentInset, options: .new, context: &KVOContext)
        scrollView.addObserver(self, forKeyPath: kPathContentOffset, options: .new, context: &KVOContext)
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        
        removeObservers()
        
        guard let scroll = newSuperview as? UIScrollView else { return }
        
        scrollView = scroll
        
        addObservers(scrollView: scroll)
        observeValue(forKeyPath: kPathContentInset, of: self, change: [.newKey: scroll.contentInset], context: &KVOContext)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard context == &KVOContext, let scroll = scrollView else { return }
        
        let path = keyPath ?? ""
        
        switch path {
        case kPathContentInset:
            updateContentInset()
            fallthrough
        case kPathContentSize:
            updateRefreshViewOffset()
        case kPathContentOffset:
            scrollViewContentOffsetDidChange(scrollView: scroll)
        default: break
        }
    }
    
    open func updateContentInset() {
        guard let scroll = scrollView else { return }

        if state != .updateInsets {
            if #available(iOS 11, *) {
                scrollViewAdjustedContentInsets = scroll.adjustedContentInset - edgeOffset
            } else {
                scrollViewAdjustedContentInsets = scroll.contentInset - edgeOffset
            }
            scrollViewOriginalEdgeInsets = scroll.contentInset - edgeOffset
//            if state == .loading {
//                scrollViewAdjustedContentInsets -= edgeOffset
//                scrollViewOriginalEdgeInsets -= edgeOffset
//            }
        } else {
            state = .loading
        }
    }
    
    open func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {}
    
    open func endRefreshing() {}
    
    open func endNoMoreData() { endRefreshing() }
    
    open func refresh(animated:Bool = true) {}
}

