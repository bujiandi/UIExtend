//
//  HeaderRefreshView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/8.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit

open class HeaderRefreshView<V> : RefreshView<V> where V : RefreshContent {
    
    private func refreshHeader() {
        state = .updateInsets
        edgeOffset = UIEdgeInsets.init(top: moveHeight, left: 0, bottom: 0, right: 0)
        scrollView?.contentInset.top = scrollViewOriginalEdgeInsets.top + moveHeight
        scrollView?.contentOffset.y = -moveHeight - scrollViewOriginalEdgeInsets.top
        action?(self)
        contentView?.pulling(percent: 2)
    }
    
    open override func refresh(animated: Bool) {
        if !animated {
            refreshHeader()
        } else {
            UIView.animate(withDuration: 0.35) { [weak self] in
                self?.refreshHeader()
            }
        }
    }
    
    var action:((HeaderRefreshView<V>) -> Void)?
    
    open override func updateRefreshViewOffset() {
        guard let scroll = scrollView else { return }
        super.updateRefreshViewOffset()

        moveHeight = contentHeight

        if hasBar {
            
            constraint?.constant = scrollViewOriginalEdgeInsets.top - scroll.scrollIndicatorInsets.top
        } else {
            constraint?.constant = scrollViewAdjustedContentInsets.top - scroll.scrollIndicatorInsets.top
        }
     
        moveOffset = -moveHeight - scrollViewAdjustedContentInsets.top + scrollViewOriginalEdgeInsets.top
    }
    
    open override func endRefreshing() {
        state = .normal
        edgeOffset = .zero
        guard let scroll = scrollView else {
            return
        }
        let top = scrollViewOriginalEdgeInsets.top
        UIView.animate(withDuration: 0.35) {
            UIView.setAnimationCurve(.easeOut)
            scroll.contentInset.top = top
        }
        contentView?.pulling(percent: -1)
    }
    
    open override func scrollViewContentOffsetDidChange(scrollView: UIScrollView) {
        if  state == .loading ||
            state == .noMoreData ||
            scrollView.contentOffset.y > -scrollViewOriginalEdgeInsets.top {
            // 向上滚动到看不见头部控件，直接返回
            return
        }
        
        if scrollView.isDragging {  // 正在拖拽
            let offsetY = scrollView.contentOffset.y + scrollViewOriginalEdgeInsets.top
            if  offsetY < moveOffset {        // 大于偏移量，转为pulling
                state = .pulling
                contentView?.pulling(percent: 1)
            } else {                // 小于偏移量，转为正常normal
                state = .normal
                contentView?.pulling(percent: offsetY / moveOffset)
            }
        } else {
            if state == .pulling {
                refreshHeader()
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
//            let offsetHeight = -scrollView.contentOffset.y - scrollViewOriginalEdgeInsets.top
//            if offsetHeight >= 0 && offsetHeight <= moveHeight {
//                //有时进度可能会到0.991..对精度要求没那么高可以忽略
//                pullingPercent = offsetHeight/moveHeight;
//            }
//        }
    }
    
}
