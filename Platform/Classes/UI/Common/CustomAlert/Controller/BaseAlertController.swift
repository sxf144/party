//
//  CustomAlertController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

extension BaseAlertAction {

    public enum Style : Int, @unchecked Sendable {
        
        case `default` = 0

        case cancel = 1

        case destructive = 2
    }
}

class BaseAlertAction: NSObject {

    public init(title: String?, style: BaseAlertAction.Style, handler: ((BaseAlertAction) -> Void)? = nil) {
        super.init()
        
        if let t = title {
            self.title = t
        }
        
        self.style = style
        
        if let handler = handler {
            self.actionBlock = handler
        }
    }

    open var title: String = ""

    open var style: BaseAlertAction.Style = .default

    open var isEnabled: Bool = true
    
    open var isForce: Bool = false
    
    /// 回调闭包
    public var actionBlock: ((_ action:BaseAlertAction) -> ())?
}

class BaseAlertController: UIViewController {
    
    public var actions: [BaseAlertAction] = []
    public var alertTitle: String?
    public var alertMessage: String?
    
    public init(title: String?, message: String?) {
        super.init(nibName: nil, bundle: nil)
        alertTitle = title
        alertMessage = message
        // 自定义转场动画
        transitioningDelegate = self as UIViewControllerTransitioningDelegate
        modalPresentationStyle = .custom
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    
    // 弹窗内容
    fileprivate lazy var centerView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 10
        view.clipsToBounds = true
        return view
    }()
    
    // 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = UIColor.ls_color("#333333")
        label.text = alertTitle
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    // 内容
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = alertMessage
        label.textAlignment = .center
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    // 按钮1
    fileprivate lazy var actionBtn1: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickActionBtn1(_:)), for: .touchUpInside)
        return button
    }()
    
    // 按钮2
    fileprivate lazy var actionBtn2: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickActionBtn2(_:)), for: .touchUpInside)
        return button
    }()
}

extension BaseAlertController {
    
    public func addAction(_ action: BaseAlertAction) {
        
        if actions.count == 2 {
            return
        }
        
        actions.append(action)
        var button: UIButton?
        if actions.count == 1 {
            button = actionBtn1
        } else if actions.count == 2 {
            button = actionBtn2
        }
        
        if let btn = button {
            if action.style == .default {
                btn.layer.borderWidth = 0.5
                btn.layer.borderColor = UIColor.ls_color("#CBCBCB").cgColor
                btn.backgroundColor = .clear
                btn.setTitleColor(UIColor.ls_color("#333333"), for: .normal)
                btn.setTitle(action.title, for: .normal)
            } else if action.style == .destructive {
                btn.backgroundColor = UIColor.ls_color("#FE9C5B")
                btn.setTitleColor(UIColor.white, for: .normal)
                btn.setTitle(action.title, for: .normal)
            }
        }
    }
    
    @objc func clickActionBtn1(_ sender:UIButton) {
        if actions.count > 0 {
            let action = actions[0]
            if let handler = action.actionBlock {
                handler(action)
            }
            if !action.isForce {
                dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
    
    @objc func clickActionBtn2(_ sender:UIButton) {
        if actions.count > 1 {
            let action = actions[1]
            if let handler = action.actionBlock {
                handler(action)
            }
            if !action.isForce {
                dismiss(animated: true)
            }
        } else {
            dismiss(animated: true)
        }
    }
}

extension BaseAlertController: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if (touch.view?.isDescendant(of: centerView))! {
            return false;
        }else{
            return true;
        }
    }
}

// MARK: - 转场动画delegate
extension BaseAlertController: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        LSLog("animationController presented")
        let animated = BaseAlertPresentAnimated(type: .present)
        return animated
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        LSLog("animationController dismissed")
        let animated = BaseAlertPresentAnimated(type: .dismiss)
        return animated
    }
}

fileprivate enum BaseAlertPresentAnimateType {
    case present//被推出时
    case dismiss//取消时
}

//EWDatePickerViewController的推出和取消动画
fileprivate class BaseAlertPresentAnimated: NSObject,UIViewControllerAnimatedTransitioning {

    var type: BaseAlertPresentAnimateType = .present

    init(type: BaseAlertPresentAnimateType) {
        self.type = type
    }
    /// 动画时间
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    /// 动画效果
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        switch type {
        case .present:
            guard let toVC = transitionContext.viewController(forKey: .to) as? BaseAlertController else {
                return
            }
            
            let containerView = transitionContext.containerView
            
            let toView = toVC.view
            containerView.addSubview(toView!)

            UIView.animate(withDuration: 0.25, animations: {
                /// 背景变色
                toVC.view.backgroundColor = UIColor.ls_color("#000000", alpha: 0.2)
                /// 剧中弹出
                toVC.centerView.alpha = 1.0
            }) { ( _ ) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        case .dismiss:
            guard let toVC = transitionContext.viewController(forKey: .from) as? BaseAlertController else {
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                toVC.view.backgroundColor = UIColor.ls_color("#000000", alpha: 0.0)
                /// 直接dissmiss
                toVC.centerView.alpha = 0.0
            }) { (_) in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
    }
}


extension BaseAlertController {
    
    fileprivate func setupUI() {
        
        view.addSubview(centerView)
        centerView.addSubview(titleLabel)
        centerView.addSubview(messageLabel)
        
        centerView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-56)
            make.height.greaterThanOrEqualTo(180)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalToSuperview().offset(30)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.top.equalTo(titleLabel.snp.bottom).offset(20)
        }
        
        actionBtn1.isHidden = actions.count < 1
        actionBtn2.isHidden = actions.count < 2
        
        if actions.count == 1 {
            centerView.addSubview(actionBtn1)
            
            actionBtn1.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(16)
                make.right.equalToSuperview().offset(-16)
                make.top.equalTo(messageLabel.snp.bottom).offset(30)
                make.height.equalTo(42)
                make.bottom.equalToSuperview().offset(-20)
            }
            
        } else if actions.count == 2 {
            centerView.addSubview(actionBtn1)
            centerView.addSubview(actionBtn2)
            
            actionBtn1.snp.makeConstraints { (make) in
                make.top.greaterThanOrEqualTo(messageLabel.snp.bottom).offset(30)
                make.left.equalToSuperview().offset(16)
                make.width.equalToSuperview().dividedBy(2).offset(-20)
                make.height.equalTo(42)
                make.bottom.equalToSuperview().offset(-20)
            }
            
            actionBtn2.snp.makeConstraints { (make) in
                make.top.greaterThanOrEqualTo(messageLabel.snp.bottom).offset(30)
                make.right.equalToSuperview().offset(-16)
                make.width.equalToSuperview().dividedBy(2).offset(-20)
                make.height.equalTo(42)
                make.bottom.equalToSuperview().offset(-20)
            }
        }
    }
}

