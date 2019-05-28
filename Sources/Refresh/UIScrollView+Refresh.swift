//
//  Refresh+UIScrollView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/8.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

private var kHeaderRefreshAction = "scroll.header.refresh.action"
private var kFooterRefreshAction = "scroll.footer.refresh.action"

extension UIScrollView {
    
    public func headerRefresh(animated: Bool) {
        let action = objc_getAssociatedObject(self, &kHeaderRefreshAction) as? (Bool) -> Void
        action?(animated)
    }
    public func footerRefresh(animated: Bool) {
        let action = objc_getAssociatedObject(self, &kFooterRefreshAction) as? (Bool) -> Void
        action?(animated)
    }
    
    @discardableResult
    public func setRefreshHeader(hasBar:Bool = true, _ action: @escaping (HeaderRefreshView<RefreshContentView>) -> Void) -> HeaderRefreshView<RefreshContentView> {
        let view = RefreshContentView()
        view.normalText     = HeaderRefresh.normalText
        view.pullingText    = HeaderRefresh.pullingText
        view.loadingText    = HeaderRefresh.loadingText
        view.noMoreDataText = HeaderRefresh.noMoreDataText
        return setRefreshHeader(contentView: view, hasBar: hasBar, action)
    }
    
    @discardableResult
    public func setRefreshHeader<V>(contentView:V, hasBar:Bool = true, _ action: @escaping (HeaderRefreshView<V>) -> Void) -> HeaderRefreshView<V> {
        
        for view in subviews {
            let obj = view as AnyObject
            if  obj is HeaderRefreshView<V> {
                view.removeFromSuperview()
                break
            }
        }
        
        let header = HeaderRefreshView<V>()
        header.layoutMargins = .zero
        header.hasBar = hasBar
        header.action = action
        header.contentView = contentView
        
        let headerBottom = self.anchor.top == header.anchor.bottom
        header.constraint = headerBottom
        
        addSubview(header) {
            $0 += header.anchor.leading  == self.anchor.leading
            $0 += header.anchor.trailing == self.anchor.trailing
            $0 += header.anchor.width    == self.anchor.width
            $0 += headerBottom
            $0 += header.anchor.height   >= 44 && .levelHigh + 1
        }
        
        let refreshAction:(Bool) -> Void = { [weak header] in
            header?.refresh(animated: $0)
        }
        objc_setAssociatedObject(self, &kHeaderRefreshAction, refreshAction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return header
    }
    
    @discardableResult
    public func setRefreshFooter(hasBar:Bool = false, _ action: @escaping  (FooterRefreshView<RefreshContentView>) -> Void) -> FooterRefreshView<RefreshContentView> {
        let view = RefreshContentView()
        swap(&view.loadingTransform, &view.pullingTransform)

        view.normalText     = FooterRefresh.normalText
        view.pullingText    = FooterRefresh.pullingText
        view.loadingText    = FooterRefresh.loadingText
        view.noMoreDataText = FooterRefresh.noMoreDataText
        return setRefreshFooter(contentView: view, hasBar: hasBar, action)
    }
    
    @discardableResult
    public func setRefreshFooter<V>(contentView:V, hasBar:Bool = false, _ action: @escaping (FooterRefreshView<V>) -> Void) -> FooterRefreshView<V> {
        
        for view in subviews {
            let obj = view as AnyObject
            if  obj is FooterRefreshView<V> {
                view.removeFromSuperview()
                break
            }
        }
        
        let footer = FooterRefreshView<V>()
        footer.layoutMargins = .zero
        footer.hasBar = hasBar
        footer.action = action
        footer.state = .noMoreData
        footer.contentView = contentView
        
        let footerTop = footer.anchor.top == self.anchor.top
        footer.constraint = footerTop
        
        addSubview(footer) {
            $0 += footer.anchor.leading  == self.anchor.leading
            $0 += footer.anchor.trailing == self.anchor.trailing
            $0 += footer.anchor.width    == self.anchor.width
            $0 += footerTop
            $0 += footer.anchor.height   >= 44 && .levelHigh + 1
        }
        
        let refreshAction:(Bool) -> Void = { [weak footer] in
            footer?.refresh(animated: $0)
        }
        objc_setAssociatedObject(self, &kFooterRefreshAction, refreshAction, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        
        return footer
    }
    
    public func getHeaderRefreshView<V>() -> HeaderRefreshView<V>? where V : RefreshContent {
        
        for view in subviews {
            let obj = view as AnyObject
            if  obj is HeaderRefreshView<V> {
                return obj as? HeaderRefreshView<V>
            }
        }
        return nil
    }
    
    public func getFooterRefreshView<V>() -> FooterRefreshView<V>? where V : RefreshContent {
        
        for view in subviews {
            let obj = view as AnyObject
            if  obj is FooterRefreshView<V> {
                return obj as? FooterRefreshView<V>
            }
        }
        return nil
    }
    


}
