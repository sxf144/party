//
//  DatePickerController.swift
//  constellation
//
//  Created by Lee on 2020/4/22.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class DatePickerController: BaseController {

    public typealias Action = (Date) -> Void
       
    var valueChangeAction: Action?
    var confirmAction: Action?
    
    required init(mode: UIDatePicker.Mode = .date, date: Date? = nil, minimumDate: Date? = nil, maximumDate: Date? = nil) {
        super.init(nibName: nil, bundle: nil)
        datePicker.datePickerMode = mode
        datePicker.date = date ?? Date()
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        } 
        datePicker.minimumDate = minimumDate
        datePicker.maximumDate = maximumDate
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        self.transitioningDelegate = self as UIViewControllerTransitioningDelegate//自定义转场动画
    }

    ///点击任意位置view消失
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        let currentPoint = touches.first?.location(in: self.view)
        if !self.containView.frame.contains(currentPoint ?? CGPoint()) {
            self.dismiss(animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker(frame: CGRect(x: 0, y: 24, width: kScreenW, height: 216))
        picker.locale = Locale(identifier: "zh_CN")
        picker.addTarget(self, action: #selector(actionForDatePicker), for: .valueChanged)
        return picker
    }()

    fileprivate lazy var containView:UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenH-240, width: kScreenW, height: 240+kSafeAreaHeight))
        view.backgroundColor = UIColor.white
        return view
    }()
    fileprivate lazy var backgroundView:UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        return view
    }()
}

extension DatePickerController{
    
    func show(){
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        UIViewController.current()?.present(self, animated: true, completion: nil)
    }
    
    public func setDate(_ date: Date) {
        datePicker.setDate(date, animated: true)
    }
    
    public func setMinimumDate(_ date: Date) {
        datePicker.minimumDate = date
    }
    
    func setMaximumDate(_ date: Date){
        datePicker.maximumDate = date
    }
    
}

fileprivate extension DatePickerController{
    
    // MARK: onClick
    @objc func actionForDatePicker() {
        valueChangeAction?(datePicker.date)
    }
    
    @objc func onClickCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onClickSure() {
        confirmAction?(datePicker.date)
        self.dismiss(animated: true, completion: nil)
    }
    
    // MARK: - Func
    private func setupView() {
        navigationView.isHidden = true
        self.view.backgroundColor = UIColor.clear
        self.view.insertSubview(self.backgroundView, at: 0)
        self.modalPresentationStyle = .custom//viewcontroller弹出后之前控制器页面不隐藏 .custom代表自定义
        let cancel = UIButton(frame: CGRect(x: 0, y: 10, width: 70, height: 20))
        let sure = UIButton(frame: CGRect(x: kScreenW - 80, y: 10, width: 70, height: 20))
        cancel.setTitle("取消", for: .normal)
        sure.setTitle("确认", for: .normal)
        cancel.setTitleColor(UIColor.ls_color(r: 255, g: 51, b: 102, alpha: 1), for: .normal)
        sure.setTitleColor(UIColor.ls_color(r: 255, g: 51, b: 102, alpha: 1), for: .normal)
        cancel.addTarget(self, action: #selector(self.onClickCancel), for: .touchUpInside)
        sure.addTarget(self, action: #selector(self.onClickSure), for: .touchUpInside)
        
        //创建日期选择器
        self.containView.addSubview(cancel)
        self.containView.addSubview(sure)
        self.containView.addSubview(datePicker)
        self.view.addSubview(self.containView)
    }
}

// MARK: - 转场动画delegate
extension DatePickerController:UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = LSDatePickerPresentAnimated(type: .present)
        return animated
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = LSDatePickerPresentAnimated(type: .dismiss)
        return animated
    }
}

fileprivate enum LSDatePickerPresentAnimateType {
    case present//被推出时
    case dismiss//取消时
}

//EWDatePickerViewController的推出和取消动画
fileprivate class LSDatePickerPresentAnimated: NSObject,UIViewControllerAnimatedTransitioning {

    var type: LSDatePickerPresentAnimateType = .present

    init(type: LSDatePickerPresentAnimateType) {
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
            guard let toVC = transitionContext.viewController(forKey: .to) as? DatePickerController else {
                return
            }

            let toView = toVC.view

            let containerView = transitionContext.containerView
            containerView.addSubview(toView!)

            toVC.containView.transform = CGAffineTransform(translationX: 0, y: (toVC.containView.frame.height))

            UIView.animate(withDuration: 0.25, animations: {
                /// 背景变色
                toVC.backgroundView.alpha = 1.0
                /// datepicker向上推出
                toVC.containView.transform =  CGAffineTransform(translationX: 0, y: -10)
            }) { ( _ ) in
                UIView.animate(withDuration: 0.2, animations: {
                    /// transform初始化
                    toVC.containView.transform = CGAffineTransform.identity
                }, completion: { (_) in
                    transitionContext.completeTransition(true)
                })
            }
        case .dismiss:
            guard let toVC = transitionContext.viewController(forKey: .from) as? DatePickerController else {
                return
            }
            UIView.animate(withDuration: 0.25, animations: {
                toVC.backgroundView.alpha = 0.0
                /// datepicker向下推回
                toVC.containView.transform =  CGAffineTransform(translationX: 0, y: (toVC.containView.frame.height))
            }) { (_) in
                transitionContext.completeTransition(true)
            }
        }
    }
}
