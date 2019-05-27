//
//  FooterRefreshView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/8.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

open class FooterRefreshView<V> : RefreshView<V> where V : RefreshContent {
    
    
    private func refreshFooter(_ scrollView:UIScrollView, _ beyondScrollViewHeight:CGFloat) {
        state = .updateInsets
        edgeOffset = UIEdgeInsets.init(top: 0, left: 0, bottom: moveHeight, right: 0)
        if beyondScrollViewHeight > 0 {
            scrollView.contentInset.bottom = scrollViewOriginalEdgeInsets.bottom + moveHeight
        } else {
            scrollView.contentInset.bottom = (constraint?.constant ?? 0) - scrollView.contentSize.height + moveHeight + scrollView.scrollIndicatorInsets.bottom
        }

        action?(self)
        contentView?.pulling(percent: 2)
    }
    
    open override func refresh(animated: Bool) {
        guard let scroll = self.scrollView else { return }
        
        /// scrollview实际显示内容高度
        let realHeight = scroll.frame.size.height - scrollViewAdjustedContentInsets.top - scrollViewAdjustedContentInsets.bottom
        
        /// 计算超出scrollView的高度
        let beyondScrollViewHeight = scroll.contentSize.height - realHeight

        if !animated {
            refreshFooter(scroll, beyondScrollViewHeight)
        } else {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.refreshFooter(scroll, beyondScrollViewHeight)
            }
        }
    }
    
    var action:((FooterRefreshView<V>) -> Void)?

    open override func updateRefreshViewOffset() {
        guard let scroll = scrollView else { return }
        super.updateRefreshViewOffset()
        
        moveHeight = contentHeight
        
        var bottom1 = scroll.contentSize.height
        var bottom2 = scroll.frame.height
        
        if hasBar {
            bottom1 += scrollViewOriginalEdgeInsets.bottom - scroll.scrollIndicatorInsets.bottom
            bottom2 -= scrollViewAdjustedContentInsets.top + scrollViewAdjustedContentInsets.bottom - scrollViewOriginalEdgeInsets.bottom + scroll.scrollIndicatorInsets.bottom
        } else {
            bottom1 += scrollViewAdjustedContentInsets.bottom
            bottom2 -= scrollViewAdjustedContentInsets.top
        }
        
        let bottom = max(bottom1, bottom2)
        
        moveOffset = bottom + moveHeight
        
        constraint?.constant = bottom
    }
    
    open override func endRefreshing() {
        endTo(state: .normal)
        contentView?.pulling(percent: -1)
    }
    
    open override func endNoMoreData() {
        endTo(state: .noMoreData)
        contentView?.pulling(percent: -2)
    }
    
    private func endTo(state:RefreshState) {
        self.state = state
        edgeOffset = .zero
        
        guard let scroll = scrollView else {
            return
        }
        let bottom = scrollViewOriginalEdgeInsets.bottom
        UIView.animate(withDuration: 0.35) {
            UIView.setAnimationCurve(.easeOut)
            scroll.contentInset.bottom = bottom
        }
    }
    
    open override func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {
        
        switch state {
        case .noMoreData, .loading: return
        default: break
        }
        
        /// scrollview实际显示内容高度
        let realHeight = scrollView.frame.size.height - scrollViewAdjustedContentInsets.top - scrollViewAdjustedContentInsets.bottom
        /// 计算超出scrollView的高度
        let beyondScrollViewHeight = scrollView.contentSize.height - realHeight
        
        /// 刚刚出现底部控件时出现的offsetY
        let offSetY = beyondScrollViewHeight - scrollViewAdjustedContentInsets.top
        
        /// 当前scrollView的contentOffsetY超出offsetY的高度
        var beyondOffsetHeight:CGFloat = 0
        if beyondScrollViewHeight > 0 {
            beyondOffsetHeight = scrollView.contentOffset.y - offSetY
        } else {
            beyondOffsetHeight = scrollView.contentOffset.y - offSetY + beyondScrollViewHeight
        }
        
        guard beyondOffsetHeight > 0 else {
            return
        }
        
//        if scrollView.isDecelerating && refreshType == .autoFooter {//如果是自动加载更多
//            state = .loading
//            return
//        }
        
        if scrollView.isDragging {
            if beyondOffsetHeight >= moveHeight {
                state = .pulling
                contentView?.pulling(percent: 1)
            } else {
                state = .normal
                contentView?.pulling(percent: beyondOffsetHeight / moveHeight)
            }
        } else {
            if state == .pulling {
                refreshFooter(scrollView, beyondScrollViewHeight)
            } else {
                contentView?.pulling(percent: -1)
            }
//            switch state {
//            case .loading:  contentView?.pulling(percent: 2)
//            case .pulling:  contentView?.pulling(percent: 1)
//            default:        contentView?.pulling(percent: -1)
//            }
        }
        
//        if pullingPercentHandler != nil {
//            if beyondOffsetHeight <= hangingHeight {
//                //有时进度可能会到0.991..对精度要求没那么高可以忽略
//                pullingPercent = beyondOffsetHeight/hangingHeight;
//            }
//        }
    }
}
