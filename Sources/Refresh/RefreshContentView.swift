//
//  RefreshContentView.swift
//  Toast
//
//  Created by 慧趣小歪 on 2018/2/8.
//  Copyright © 2018年 yFenFen. All rights reserved.
//

import UIKit
import OperatorLayout

open class RefreshContentView : UIView, Animationable {
    
    
    /// 根据百分比数值确定状态
    public var state:RefreshState {
        return getState(by: _percent)
    }
    
    /// 设置拉动百分比 0 到 1
    private var _percent:CGFloat = -1
    public func pulling(percent:CGFloat) {
        _percent = percent
//        if pullingTransform == .identity, state == .normal, percent < 0  {
//            print(state)
//        }
        switch state {
        case .normal:
            _stateLabel?.text = normalText
            stopAnimating()
            UIView.animate(withDuration: 0.2) { [unowned self] in
                UIView.setAnimationCurve(.easeInOut)
                self.arrowView.transform = self.loadingTransform
            }
        case .loading:
            _stateLabel?.text = loadingText
            startAnimating()
            arrowView.transform = loadingTransform
        case .pulling:
            _stateLabel?.text = pullingText
            stopAnimating()
            UIView.animate(withDuration: 0.2) { [unowned self] in
                UIView.setAnimationCurve(.easeInOut)
                self.arrowView.transform = self.pullingTransform
            }
        case .noMoreData:
            _stateLabel?.text = noMoreDataText
            stopAnimating()
            arrowView.transform = loadingTransform
        case .updateInsets: return
        }
        updateRefreshDate()
    }
    
    open var lastRefreshDate:Date? {
        didSet { updateRefreshDate() }
    }
    
    private func updateRefreshDate() {
        
        var dateText = "最近更新：无"
        if let date = lastRefreshDate {
            let fmt = DateFormatter()
            fmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateText = fmt.string(from: date)
        }
        
        _dateLabel?.text = dateText
    }
    
    public func startAnimating() {
        activityView.startAnimating()
        arrowView.isHidden = true
    }
    
    public func stopAnimating() {
        if activityView.isAnimating {
            activityView.stopAnimating()
            arrowView.isHidden = false
        }
    }
    
    public var isAnimating: Bool {
        return activityView.isAnimating
    }
    
    open var viewHeight:CGFloat = 50 {
        didSet {
            if viewHeight != oldValue {
                constraint?.constant = viewHeight
            }
        }
    }
    
    open var pullingTransform:CGAffineTransform = CGAffineTransform(rotationAngle: 0.000001 - .pi)
    open var loadingTransform:CGAffineTransform = .identity
    
    open var normalText:String?     { didSet { pulling(percent: _percent) } }
    open var loadingText:String?    { didSet { pulling(percent: _percent) } }
    open var pullingText:String?    { didSet { pulling(percent: _percent) } }
    open var noMoreDataText:String? { didSet { pulling(percent: _percent) } }
    
    private weak var constraint: NSLayoutConstraint?

    private weak var _stateLabel: UILabel?
    private weak var _dateLabel: UILabel?
    private weak var _arrowView: UIImageView?
    private weak var _activityView: UIActivityIndicatorView?

    private func createLabel(color:UIColor, size:CGFloat) -> UILabel {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: size)
        label.textAlignment = .center
        label.isUserInteractionEnabled = false
        label.numberOfLines = 1
        label.lineBreakMode = .byClipping
        label.textColor = color
        return label
    }
    
    open var stateLabel: UILabel {
        guard let label = _stateLabel else {
            let label = createLabel(color: .darkGray, size: 14)

            _stateLabel = label
            pulling(percent: _percent)
            addSubview(label) {
                $0 += label.anchor.leading == self.anchor.centerX * 0.85
                $0 += label.anchor.bottom  == self.anchor.centerY
            }
            return label
        }
        return label
    }
    
    open var dateLabel: UILabel {
        guard let label = _dateLabel else {
            let label = createLabel(color: .gray, size: 11)

            _dateLabel = label
            addSubview(label) {
                $0 += label.anchor.leading == self.anchor.centerX * 0.85
                $0 += label.anchor.top == self.anchor.centerY + 2
            }
            return label
        }
        return label
    }
    
    open var arrowView: UIImageView {
        guard let image = _arrowView else {
            let bundle = Bundle(for: RefreshContentView.self)
            let icon = UIImage(named: "arrow", in: bundle, compatibleWith: nil)
            let image = UIImageView(image: icon)
            image.contentMode = .center
            _arrowView = image
            addSubview(image) {
                $0 += image.anchor.centerX == self.anchor.centerX * 0.7
                $0 += image.anchor.centerY == self.anchor.centerY
            }
            return image
        }
        return image
    }
    
    open var activityView: UIActivityIndicatorView {
        guard let activity = _activityView else {
            let activity = UIActivityIndicatorView(style: .gray)
            activity.hidesWhenStopped = true
            _activityView = activity
            addSubview(activity) {
                $0 += activity.anchor.centerX == self.anchor.centerX * 0.7
                $0 += activity.anchor.centerY == self.anchor.centerY
            }
            return activity
        }
        return activity
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        
        if  let parentView  = superview,
            let layout      = constraint {
            parentView.removeConstraint(layout)
        }
        
        super.willMove(toSuperview: newSuperview)
        
        guard let parentView = newSuperview else { return }
        
        tintColor = parentView.tintColor
        stateLabel.tintColor = tintColor
        dateLabel.tintColor = tintColor
        arrowView.tintColor = tintColor
        activityView.tintColor = tintColor
    }
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        let layout = self.anchor.height == viewHeight
        constraint = layout
        superview?.addConstraint(layout)
    }
    
}
