//
//  CashOutController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class CashOutController: BaseController {
    
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    let errHeight: CGFloat = 30
    let CellHeight: CGFloat = 58
    let maxAlipayLength = 30
    let maxAmountLength = 8
    let maxAmount = 10000
    let minAmount = 100
    var userPageData: UserPageModel = LoginManager.shared.getUserPageInfo() ?? UserPageModel()

    override func viewDidLoad() {
        title = "提现"
        super.viewDidLoad()
        view.backgroundColor = UIColor.ls_color("#F6F6F6")
        setupUI()
        resetNavigation()
        addObservers()
    }
    
    // 错误提示
    fileprivate lazy var errView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#FE9C5B")
        return view
    }()
    
    fileprivate lazy var errLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 桔子币余额
    fileprivate lazy var coinTitleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#777777")
        label.text = "桔子币余额"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#777777")
        label.text = String(format: "%.2f", Double(userPageData.user.coinBalance)/100)
        label.sizeToFit()
        return label
    }()
    
    // 提现金额
    fileprivate lazy var amountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let countTapGes = UITapGestureRecognizer(target: self, action: #selector(amountDidClick))
        view.addGestureRecognizer(countTapGes)
        return view
    }()
    
    fileprivate lazy var amountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "提现金额"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var amountTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ls_color("#333333")
        textField.delegate = self
        textField.font = kFontRegualer16
        textField.textAlignment = .right
        textField.keyboardType = .decimalPad
        return textField
    }()
    
    fileprivate lazy var amountPlaceHolderLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = kColorTextTips
        label.text = "¥0.00"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var amountUnitLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "¥"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // 支付宝账号
    fileprivate lazy var alipayAccountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let countTapGes = UITapGestureRecognizer(target: self, action: #selector(alipayAccountDidClick))
        view.addGestureRecognizer(countTapGes)
        return view
    }()
    
    fileprivate lazy var alipayAccountLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "支付宝账号"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var alipayAccountTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ls_color("#333333")
        textField.delegate = self
        textField.font = kFontRegualer16
        textField.textAlignment = .right
        textField.attributedPlaceholder = NSAttributedString(string: "请输入账号", attributes: [NSAttributedString.Key.foregroundColor: kColorTextTips])
        return textField
    }()
    
    // 支付宝实名
    fileprivate lazy var alipayRealNameView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 8
        let countTapGes = UITapGestureRecognizer(target: self, action: #selector(alipayRealNameClick))
        view.addGestureRecognizer(countTapGes)
        return view
    }()
    
    fileprivate lazy var alipayRealNameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#333333")
        label.text = "支付宝实名"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var alipayRealNameTextField: UITextField = {
        let textField = UITextField()
        textField.textColor = UIColor.ls_color("#333333")
        textField.delegate = self
        textField.font = kFontRegualer16
        textField.textAlignment = .right
        textField.attributedPlaceholder = NSAttributedString(string: "请输入真实姓名", attributes: [NSAttributedString.Key.foregroundColor: kColorTextTips])
        return textField
    }()
    
    // 提交
    fileprivate lazy var submitBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("提交", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium18
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickCashOutBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 兑换比例
    fileprivate lazy var rateLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = kColorGray
        label.text = "兑换比例：1桔子币=1元"
        label.sizeToFit()
        return label
    }()
    
    // 提现规则说明
    fileprivate lazy var ruleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = kColorGray
        label.text = "提现规则说明\n1. 每次提现最少100元，单笔最大10000元。\n2.提交审核后，一般会在72小时内到账。\n3.超过一定额度后，系统会自动扣税，税额根据用户一个自然月的提现总额计算。"
        label.numberOfLines = 0;
        label.sizeToFit()
        return label
    }()
}

extension CashOutController {
    
    func addObservers() {
        LSLog("addObservers")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPageInfoChange(_:)), name: NotificationName.userPageInfoChange, object: nil)
    }
    
    @objc func handleUserPageInfoChange(_ notification: Notification) {
        LSLog("handleUserPageInfoChange")
        userPageData = LoginManager.shared.getUserPageInfo() ?? UserPageModel()
        refreshData()
    }
    
    func refreshData() {
        coinLabel.text = String(format: "%.2f", Double(userPageData.user.coinBalance)/100)
        coinLabel.sizeToFit()
    }
    
    @objc func amountDidClick() {
        LSLog("amountDidClick")
        amountTextField.becomeFirstResponder()
    }
    
    @objc func alipayAccountDidClick() {
        LSLog("alipayAccountDidClick")
        alipayAccountTextField.becomeFirstResponder()
    }
    
    @objc func alipayRealNameClick() {
        LSLog("alipayRealNameClick")
        alipayRealNameTextField.becomeFirstResponder()
    }
    
    @objc func clickCashOutBtn(_ sender: UIButton) {
        LSLog("clickCashOutBtn")
        if !checkParam() {
            return
        }
        LSHUD.showLoading()
        let amount = (Int64(amountTextField.text?.trim() ?? "") ?? 0)*100
        let alipayAccount:String = alipayAccountTextField.text?.trim() ?? ""
        let alipayRealName:String = alipayRealNameTextField.text?.trim() ?? ""
        NetworkManager.shared.cashOut(amount, zfbAccount: alipayAccount, realName: alipayRealName) { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("cashOut succ")
                LoginManager.shared.getUserPage()
                LSHUD.showInfo("提现成功")
                self.pop()
            } else {
                LSLog("cashOut fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    // 检查参数
    func checkParam() -> Bool {
        
        if (amountTextField.text!.isEmpty) {
            LSLog("checkParam amount err")
            LSHUD.showInfo("未填写「提现金额」")
            return false
        }
        
        let amount = (Int64(amountTextField.text?.trim() ?? "") ?? 0)*100
        if (amount > userPageData.user.coinBalance) {
            LSLog("checkParam amount err")
            LSHUD.showInfo("您的余额不足")
            return false
        }
        
        if (alipayAccountTextField.text!.isEmpty) {
            LSLog("checkParam amount err")
            LSHUD.showInfo("未填写「支付宝账号」")
            return false
        }
        
        if (alipayRealNameTextField.text!.isEmpty) {
            LSLog("checkParam amount err")
            LSHUD.showInfo("未填写「真实姓名」")
            return false
        }
        
        return true
    }
    
    func showError(_ errMsg:String) {
        // 错误提示
        errLabel.text = errMsg
        errLabel.sizeToFit()
        
        // 展示错误提示
        errView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(errHeight)
        }
        
        // 使用动画来平滑地改变布局
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func hideError() {
        
        // 收起错误提示
        errView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight-errHeight)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(errHeight)
        }
        
        // 使用动画来平滑地改变布局
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    override func rightAction() {
        LSLog("rightAction")
        PageManager.shared.pushToCashOutLogController()
    }
}

extension CashOutController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        var isError = false
        var errMsg = ""
        var result = true
        
        if textField == amountTextField {
            // 获取当前文本
            if let currentText = textField.text as NSString? {
                
                // 将替换后的文本与当前文本合并
                var newText = currentText.replacingCharacters(in: range, with: string)
                LSLog("shouldChangeCharactersIn string:\(string)")
                
                // 小数点只允许存在一个，当第一个字符输入是“.”时，前方加 0
                let p = "."
                if string == p {
                    if currentText.contains(p) {
                        result = false
                    } else if currentText.length == 0 {
                        textField.text = "0"
                        newText = "0."
                    }
                }
                
                // 检查是否小数点后超过2位
                if result {
                    let separator = "."
                    let resultArray = newText.components(separatedBy: separator)
                    if resultArray.count >= 2 {
                        let lastStr = resultArray[1]
                        result = lastStr.count <= 2
                    }
                }
                
                // 检查是否超过了最大字符数
                if result {
                    result = newText.count <= maxAmountLength
                }
                
                // 结果有效，执行后续
                if result {
                    let inputValue = Double(newText)
                    
                    // 单位
                    amountUnitLabel.isHidden = newText.isEmpty
                    // 自定义PlaceHolder
                    amountPlaceHolderLabel.isHidden = !amountUnitLabel.isHidden
                    
                    // 判断金额是否超出限制
                    isError = inputValue ?? 0 > Double(maxAmount)
                    if isError {
                        errMsg = "单次提现金额不可超过\(maxAmount)元"
                    }
                    
                    if !isError {
                        isError = inputValue ?? 0 < Double(minAmount)
                        if isError {
                            errMsg = "单次提现金额不可小于\(minAmount)元"
                        }
                    }
                    
                    if !isError {
                        isError = (inputValue ?? 0)*100 > Double(userPageData.user.coinBalance)
                        if isError {
                            errMsg = "您的余额不足"
                        }
                    }
                    
                } else {
                    // 判断当前金额是否超出限制
                    let inputValue = Double(currentText as String)
                    isError = inputValue ?? 0 > Double(maxAmount)
                    if isError {
                        errMsg = "单次提现金额不可超过\(maxAmount)元"
                    }
                    
                    if !isError {
                        isError = inputValue ?? 0 < Double(minAmount)
                        if isError {
                            errMsg = "单次提现金额不可小于\(minAmount)元"
                        }
                    }
                }
            }
        } else {
            // 获取当前文本
            if let currentText = textField.text as NSString? {
                // 将替换后的文本与当前文本合并
                let newText = currentText.replacingCharacters(in: range, with: string)
                
                // 检查是否超过了最大字符数
                result = newText.count <= maxAlipayLength
            }
        }
        
        if isError {
            showError(errMsg)
        } else {
            hideError()
        }
        
        return result
    }
}

extension CashOutController {
    
    fileprivate func setupUI() {
        
        view.addSubview(errView)
        errView.addSubview(errLabel)
        view.addSubview(coinTitleLabel)
        view.addSubview(coinLabel)
        view.addSubview(amountView)
        amountView.addSubview(amountLabel)
        amountView.addSubview(amountTextField)
        amountView.addSubview(amountPlaceHolderLabel)
        amountView.addSubview(amountUnitLabel)
        view.addSubview(alipayAccountView)
        alipayAccountView.addSubview(alipayAccountLabel)
        alipayAccountView.addSubview(alipayAccountTextField)
        view.addSubview(alipayRealNameView)
        alipayRealNameView.addSubview(alipayRealNameLabel)
        alipayRealNameView.addSubview(alipayRealNameTextField)
        view.addSubview(submitBtn)
        view.addSubview(rateLabel)
        view.addSubview(ruleLabel)
        
        
        errView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight-errHeight)
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(errHeight)
        }
        
        errLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        coinTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(errView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(xMargin)
        }
        
        coinLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coinTitleLabel.snp.bottom).offset(8)
            make.left.equalToSuperview().offset(xMargin)
        }
        
        amountView.snp.makeConstraints { (make) in
            make.top.equalTo(coinLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(CellHeight)
        }
        
        amountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
        }
        
        amountTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        amountPlaceHolderLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        amountUnitLabel.snp.makeConstraints { (make) in
            make.right.equalTo(amountTextField.snp.left)
            make.centerY.equalTo(amountTextField)
        }
        
        alipayAccountView.snp.makeConstraints { (make) in
            make.top.equalTo(amountView.snp.bottom).offset(yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(CellHeight)
        }
        
        alipayAccountLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
        }
        
        alipayAccountTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        alipayRealNameView.snp.makeConstraints { (make) in
            make.top.equalTo(alipayAccountView.snp.bottom).offset(yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(CellHeight)
        }
        
        alipayRealNameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
        }
        
        alipayRealNameTextField.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-xMargin)
            make.centerY.equalToSuperview()
        }
        
        submitBtn.snp.makeConstraints { (make) in
            make.top.equalTo(alipayRealNameView.snp.bottom).offset(60)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(46)
        }
        
        rateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(submitBtn.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        ruleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
        }
    }
    
    fileprivate func resetNavigation() {
        navigationView.rightButton.setImage(nil, for: .normal)
        navigationView.rightButton.setTitle("历史", for: .normal)
        navigationView.rightButton.setTitleColor(UIColor.ls_color("#666666"), for: .normal)
        navigationView.rightButton.titleLabel?.font = UIFont.ls_mediumFont(15)
    }
}
