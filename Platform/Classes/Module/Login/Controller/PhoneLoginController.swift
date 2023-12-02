//
//  PhoneLoginController.swift
//  constellation
//
//  Created by Lee on 2020/4/21.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class PhoneLoginController: BaseController {
    
    public enum ActionType: Int {
        
        case ActionLogin = 1
        
        case ActionBind = 2
    }
    
    var countdownTimer: Timer?
    var secondsLeft = 60
    var type: ActionType = .ActionLogin
    
    override func viewDidLoad() {
        title = "手机登录"
        super.viewDidLoad()
        setupUI()
    }

    fileprivate lazy var phoneNumberTextField: UITextField = {
        let textField = UITextField()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 30
        textField.layer.borderColor = UIColor.ls_color("#FE9C5B").cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "请输入手机号码"
        textField.keyboardType = .phonePad
        return textField
    }()
    
    //getCodeButton写在verificationCodeTextField 外面是为了width正常，写在verificationCodeTextField内会有问题
    fileprivate lazy var getCodeButton:UIButton = {
        // 创建获取验证码的按钮
        let getCodeButton = UIButton(type: .custom)
        getCodeButton.setTitle("获取验证码", for: .normal)
        getCodeButton.titleLabel?.font = kFontRegualer14
        getCodeButton.setTitleColor(kColorBlack, for: .normal)
        // 设置右边距
        let rightPadding: CGFloat = 20
        getCodeButton.titleEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: rightPadding)
        getCodeButton.sizeToFit()
        getCodeButton.frame.size.width += 20
        getCodeButton.addTarget(self, action: #selector(startCountdown), for: .touchUpInside)
        return getCodeButton
    }()
    
    fileprivate lazy var verificationCodeTextField: UITextField = {
        let textField = UITextField()
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = leftView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 30
        textField.layer.borderColor = UIColor.ls_color("#FE9C5B").cgColor
        textField.layer.borderWidth = 1
        textField.placeholder = "请输入验证码"
        textField.keyboardType = .phonePad
        // 将按钮设置为rightView
        textField.rightView = getCodeButton
        textField.rightViewMode = .always
        return textField
    }()
    
    fileprivate lazy var loginBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 30
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("登录", for: .normal)
        button.addTarget(self, action: #selector(clickLoginBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension PhoneLoginController {
    
    func setType(_ type:ActionType) {
        
        self.type = type
        
        if type == .ActionLogin {
            navigationView.titleLabel.text = "手机登录"
            loginBtn.setTitle("登录", for: .normal)
        } else {
            navigationView.titleLabel.text = "绑定手机"
            loginBtn.setTitle("绑定", for: .normal)
        }
    }
    
    @objc func startCountdown() {
        
        guard let phoneNum = phoneNumberTextField.text else {
            LSHUD.showError("请输入电话号码")
            return
        }
        
        // 禁用按钮以防止多次点击
        verificationCodeTextField.rightView?.isUserInteractionEnabled = false
        
        // 启动倒计时
        countdownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCountdown), userInfo: nil, repeats: true)
        
        let mobile = "+86" + phoneNum
        //发起请求获取验证码
        NetworkManager.shared.getVerifyCode(mobile) { (resp) in
            if resp.status == .success {
                
            } else {
                LSHUD.showInfo(resp.msg)
            }
        }
    }
    
    @objc func updateCountdown() {
        
        if secondsLeft > 0 {
            verificationCodeTextField.rightView?.isUserInteractionEnabled = false
            verificationCodeTextField.rightView?.tintColor = UIColor.lightGray
            verificationCodeTextField.rightView?.tintColorDidChange()
            let buttonText = "\(secondsLeft) 秒后获取"
            (verificationCodeTextField.rightView as? UIButton)?.setTitle(buttonText, for: .normal)
            secondsLeft -= 1
        } else {
            // 倒计时结束，重新启用按钮
            verificationCodeTextField.rightView?.isUserInteractionEnabled = true
            verificationCodeTextField.rightView?.tintColor = UIColor.blue
            verificationCodeTextField.rightView?.tintColorDidChange()
            verificationCodeTextField.rightViewMode = .always
            countdownTimer?.invalidate()
            countdownTimer = nil
            secondsLeft = 60
            (verificationCodeTextField.rightView as? UIButton)?.setTitle("获取验证码", for: .normal)
        }
    }
    
    @objc func clickLoginBtn(_ sender:UIButton) {
        let mobile = "+86" + phoneNumberTextField.text!
        let smsCode = verificationCodeTextField.text!
        let grantType = GrantType.authorizationCode.rawValue
        let source = "mobile"
        
        if type == .ActionLogin {
            //发起授权登录
            NetworkManager.shared.authorize(mobile, smsCode: smsCode, code: "", grantType: grantType, source: source, refreshToken: "", identityToken: "") { (resp) in
                if resp.status == .success {
                    // 保存token
                    LoginManager.shared.saveUserToken(resp.data)
                    LSLog("authorize data:\(resp.data)")
                    LoginManager.shared.login()
                } else {
                    //错误提示
                    LSHUD.showError(resp.msg)
                }
            }
        } else {
            // 发起绑定请求
            NetworkManager.shared.bindMobile(mobile, code: smsCode) { (resp) in
                if resp.status == .success {
                    // 绑定成功
                    LSHUD.showInfo("绑定成功")
                    // 发送账号绑定成功通知
                    LSNotification.postAccountBindStatusChange()
                    self.pop()
                } else {
                    //错误提示
                    LSHUD.showError(resp.msg)
                }
            }
        }
    }
}

extension PhoneLoginController{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

extension PhoneLoginController{
    fileprivate func setupUI(){
        
        view.addSubview(phoneNumberTextField)
        view.addSubview(verificationCodeTextField)
        view.addSubview(loginBtn)
        
        
        phoneNumberTextField.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(120)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(60)
        }
        
        verificationCodeTextField.snp.makeConstraints { (make) in
            make.top.equalTo(phoneNumberTextField.snp.bottom).offset(30)
            make.centerX.equalTo(phoneNumberTextField)
            make.width.equalTo(phoneNumberTextField)
            make.height.equalTo(60)
        }
        
        // 为了width正常，目前的方式必须写在外面
        getCodeButton.snp.makeConstraints { (make) in
            make.width.equalTo(100)
            make.height.equalTo(60)
        }
        
        loginBtn.snp.makeConstraints { (make) in
            make.top.equalTo(verificationCodeTextField.snp.bottom).offset(50)
            make.centerX.equalTo(verificationCodeTextField)
            make.width.equalTo(verificationCodeTextField)
            make.height.equalTo(60)
        }
    }
}
