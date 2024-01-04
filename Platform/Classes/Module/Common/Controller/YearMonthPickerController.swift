//
//  YearMonthPickerController.swift
//  constellation
//
//  Created by Lee on 2020/4/22.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class YearMonthPickerController: BaseController {

    public typealias Action = (_ date:Date) -> Void
       
    var confirmAction: Action?
    var years: [Int] = []
    var months: [String] = []
    var selectedYear: Int = 0
    var selectedMonth: Int = 0
    
    // MARK: - 生命周期
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if selectedYear == 0 || selectedMonth == 0 {
            // 初始化年份和月份数据
            selectedYear = Calendar.current.component(.year, from: Date())
            selectedMonth = Calendar.current.component(.month, from: Date())
        }
        
        years = Array((selectedYear-10)...(selectedYear+10))
        months = DateFormatter().monthSymbols
        
        setupView()
        self.transitioningDelegate = self as UIViewControllerTransitioningDelegate//自定义转场动画
        // 设置选择器的初始值
        if let initialSelectedIndex = years.firstIndex(of: selectedYear) {
            if selectedMonth < 1 || selectedMonth > 12  {
                selectedMonth = 1
            }
            pickerView.selectRow(initialSelectedIndex, inComponent: 0, animated: false)
            pickerView.selectRow(selectedMonth-1, inComponent: 1, animated: false)
        }
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
    
    lazy var pickerView: UIPickerView = {
        let pickerView = UIPickerView(frame: CGRect(x: 0, y: 24, width: kScreenW, height: 216))

        pickerView.delegate = self
        pickerView.dataSource = self
        return pickerView
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

extension YearMonthPickerController {
    
    func show() {
        view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        UIViewController.current()?.present(self, animated: true, completion: nil)
    }
    
    public func setDate(_ date: Date) {
        selectedYear = Calendar.current.component(.year, from: date)
        selectedMonth = Calendar.current.component(.month, from: date)
    }
}

fileprivate extension YearMonthPickerController {
    
    // MARK: onClick
    @objc func onClickCancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func onClickSure() {
        // 使用示例
        if let date = createDateFromYearMonth(year: selectedYear, month: selectedMonth) {
            confirmAction?(date)
        } else {
            confirmAction?(Date())
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func createDateFromYearMonth(year: Int, month: Int) -> Date? {
        // 创建一个日期组件
        var dateComponents = DateComponents()
        dateComponents.year = year
        dateComponents.month = month
        dateComponents.day = 1 // 设定日期为每月的第一天

        // 创建一个日历
        let calendar = Calendar.current

        // 获取日期对象
        if let date = calendar.date(from: dateComponents) {
            return date
        } else {
            return nil
        }
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
        self.containView.addSubview(pickerView)
        self.view.addSubview(self.containView)
    }
}

extension YearMonthPickerController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2 // 年份和月份
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return years.count
        } else {
            return months.count
        }
    }

    // MARK: - UIPickerViewDelegate

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return "\(years[row])"
        } else {
            return months[row]
        }
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedYear = years[pickerView.selectedRow(inComponent: 0)]
        selectedMonth = pickerView.selectedRow(inComponent: 1) + 1
    }
}


// MARK: - 转场动画delegate
extension YearMonthPickerController:UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = YearMonthPickerPresentAnimated(type: .present)
        return animated
    }
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animated = YearMonthPickerPresentAnimated(type: .dismiss)
        return animated
    }
}

fileprivate enum YearMonthPickerPresentAnimateType {
    case present//被推出时
    case dismiss//取消时
}

// DatePickerViewController的推出和取消动画
fileprivate class YearMonthPickerPresentAnimated: NSObject,UIViewControllerAnimatedTransitioning {

    var type: YearMonthPickerPresentAnimateType = .present

    init(type: YearMonthPickerPresentAnimateType) {
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
            guard let toVC = transitionContext.viewController(forKey: .to) as? YearMonthPickerController else {
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
            guard let toVC = transitionContext.viewController(forKey: .from) as? YearMonthPickerController else {
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
