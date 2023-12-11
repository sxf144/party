//
//  RegisterController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit


enum RegisterVCType: String {
    ///注册
    case register = "注册"
    ///绑定手机号
    case bingDing = "绑定手机号"
    ///修改密码
    case changePassWord = "修改密码"
    ///忘记密码
    case forgetPassWord = "忘记密码"
    
}

class RegisterController: BaseController {
    
    ///验证码限制个数
    let codeLimit = 4


    var topTextField = LoginTextFieldView(frame: CGRect.init(x: 0, y: 0, width: kScreenW-72, height: 50))
    var centerTextField = LoginTextFieldView(frame: CGRect.init(x: 0, y: 0, width: kScreenW/375*181, height: 50))
    var botttomTextField = LoginTextFieldView(frame: CGRect.init(x: 0, y: 0, width: kScreenW-72, height: 50))
    let codeBtn = UIButton(type: .custom)
    let agreeBtn = UIButton(type: .custom)
    var type = RegisterVCType.register
    /// 登录没有绑定手机号 把session传过来， 绑定完了直接登录
//    var resp: UserLoginResp!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        createUI()
    }

    private func createUI(){
        if type == .register || type == .forgetPassWord{
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(title:"返回", style: .plain, target: self, action: #selector(backDismiss))
        }else if type == .bingDing {
            self.navigationItem.leftBarButtonItem?.isEnabled = false
            self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: nil, style: .plain, target: nil, action: nil)
        }
        let topLB = UILabel()
        view.addSubview(topLB)
        topLB.ls_set(kColorTextBlack, kFontBold41, .left)
        topLB.text = type.rawValue
        topLB.snp.makeConstraints { (make) in
            make.left.equalTo(36)
            make.top.equalTo(20)
        }
        
        let bottomLB = UILabel()
        view.addSubview(bottomLB)
        bottomLB.ls_set(kColorTextTips, kFontRegualer16)
        bottomLB.text = "设置6-16位数字、字母组合密码"
        bottomLB.snp.makeConstraints { (make) in
            make.left.equalTo(topLB)
            make.top.equalTo(topLB.snp.bottom).offset(8)
            make.right.equalTo(-10)
            make.height.equalTo(22)
        }
        if type != .register || type != .forgetPassWord{
            bottomLB.isHidden = true
        }
        
        view.addSubview(topTextField)
        topTextField.snp.makeConstraints { (make) in
            make.left.equalTo(topLB)
            make.right.equalTo(-36)
            make.height.equalTo(50)
            make.top.equalTo(bottomLB.snp.bottom).offset(29)
        }
        topTextField.textField.placeholder = "请输您的入手机号"
        topTextField.limitCount = 11
        
        view.addSubview(centerTextField)
        centerTextField.snp.makeConstraints { (make) in
            make.left.equalTo(topTextField)
            make.width.equalTo(kScreenW/375*181)
            make.height.equalTo(topTextField)
            make.top.equalTo(topTextField.snp.bottom).offset(16)
        }
        centerTextField.limitCount = 6
        centerTextField.textField.placeholder = "请输入验证码"
        
        view.addSubview(codeBtn)
        codeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(topTextField)
            make.height.equalTo(topTextField)
            make.centerY.equalTo(centerTextField)
            make.left.equalTo(centerTextField.snp.right).offset(16)
        }
        codeBtn.ls_cornerRadius(25)
        codeBtn.ls_set(text: "获取验证码", color: kColorTextTips, font: kFontRegualer14, bgColor: .white, self, action: #selector(codeBtnAction))
        codeBtn.ls_border(color: kColorTextBlack)
        
        view.addSubview(botttomTextField)
        botttomTextField.snp.makeConstraints { (make) in
            make.left.equalTo(topTextField)
            make.right.equalTo(topTextField)
            make.height.equalTo(topTextField)
            make.top.equalTo(centerTextField.snp.bottom).offset(16)
        }
        botttomTextField.limitCount = 16
        botttomTextField.textField.placeholder = "请输入6-15位数字、大小写字母或符号"
        botttomTextField.textField.keyboardType = .default
        botttomTextField.textField.isSecureTextEntry = true
        
//        agreeBtn.setImage(checkOnImg, for: .selected)
//        agreeBtn.setImage(checkOffImg, for: .normal)
        agreeBtn.isSelected = false
        view.addSubview(agreeBtn)
        agreeBtn.snp.makeConstraints { (make) in
            make.left.equalTo(topTextField)
            make.top.equalTo(botttomTextField.snp.bottom).offset(23)
        }
        agreeBtn.ls_addTarget(self, action: #selector(agreeBtnAction))
        
        let delegateLB = UILabel()
        view.addSubview(delegateLB)
        delegateLB.snp.makeConstraints { (make) in
            make.left.equalTo(topTextField).offset(19)
            make.centerY.equalTo(agreeBtn)
        }
        delegateLB.font = kFontRegualer14
//        delegateLB.attributedText = "我同意".withTextColor(kColorTextTips)+"《心理注册协议》".withTextColor(kColorTextBlack)
        delegateLB.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(delegateAttachment)))
        delegateLB.isUserInteractionEnabled  = true
        
        let registerBtn = UIButton(type: .custom)
        view.addSubview(registerBtn)
        registerBtn.snp.makeConstraints { (make) in
            make.left.equalTo(topTextField)
            make.right.equalTo(topTextField)
            make.height.equalTo(56)
            make.top.equalTo(delegateLB.snp.bottom).offset(56)
        }
        registerBtn.tag = 0
        registerBtn.ls_set(text: "完成注册", color: .white, font: kFontRegualer18, bgColor: kColorTextTips, self, action: #selector(registerBtnAction))
        registerBtn.ls_addShadowAndCorner(color: kColorTextTips, UIColor.ls_color("#CDF9DD"), corner: (56)/2.0, size: CGSize.init(width: 0, height: 8), radius: 10)
        var temp = ""
        if self.type == .register {
            temp = "完成注册"
        }else if self.type == .bingDing{
            temp = "绑定手机"
            agreeBtn.isHidden = true
            delegateLB.isHidden = true
        }else if self.type == .changePassWord {
            temp = "修改密码"
            agreeBtn.isHidden = true
            delegateLB.isHidden = true
            bottomLB.isHidden  = false
        }else if self.type == .forgetPassWord{
            temp = "重置密码"
            agreeBtn.isHidden = true
            delegateLB.isHidden = true
            bottomLB.isHidden = false
            bottomLB.text = "找回密码，请直接输入新的密码"
        }
        registerBtn.setTitle(temp, for: .normal)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    @objc func registerBtnAction(){
        if !(topTextField.textField.text ?? "").ls_isMobile(){
            LSHUD.showInfo("请输入11位手机号")
            return
        }
        
        if centerTextField.textField.text?.count != codeLimit {
            LSHUD.showInfo("请输入\(codeLimit)位验证码")
            return
        }
        
        if !((botttomTextField.textField.text ?? "").count >= 6 && (botttomTextField.textField.text ?? "").count <= 16) {
            LSHUD.showInfo("请输入6-15位数字、大小写字母或符号")
            return
        }
        
        if type == .register {
            if !agreeBtn.isSelected {
                LSHUD.showInfo("请先勾选协议")
                return
            }
        }

        if type == .register {
//            PSNetworkManager.shared.postUsers(centerTextField.textField.text ?? "", botttomTextField.textField.text ?? "", topTextField.textField.text ?? "") { (resp) in
//                if resp.code == .success{
//                    LSHUD.showInfo("注册成功")
//                    PSLoginManager.share.loginSuccess(resp: resp)
//                    self.dismissToRoot()
//                }else{
//                    LSHUD.showInfo(resp.errmsg ?? "")
//                }
//            }
        }else if type == .changePassWord {
//            PSNetworkManager.shared.putUsersPassword(["code": centerTextField.textField.text ?? "", "new_password": (botttomTextField.textField.text ?? "").md5]) { (resp) in
//                if resp.code == .success {
//                    PSLoginManager.share.loginOut()
//                    (UIApplication.shared.keyWindow?.rootViewController as! UITabBarController).selectedIndex = 0
//                    self.navigationController?.popToRootViewController(animated: false)
//                    LSHUD.showSuccess("修改密码成功")
//                }else{
//                    LSHUD.showInfo(resp.errmsg ?? "")
//                }
//            }
        }else if type == .bingDing {
            ///绑定手机号
//            PSNetworkManager.shared.putUsersPhone(session: resp.session, ["code": centerTextField.textField.text ?? "","password": botttomTextField.textField.text?.md5 ?? "","phone": topTextField.textField.text ?? ""]) { (resp) in
//                if resp.code == .success {
//                    PSNetworkManager.shared.postUsersLogin(param: ["phone":self.topTextField.textField.text ?? "","password":self.botttomTextField.textField.text?.md5 ?? "","kind":1], { (resp) in
//                        if resp.code == .success{
//                            LSHUD.showInfo("绑定手机成功")
//                            self.resp = resp
//                            PSLoginManager.share.loginSuccess(resp: self.resp)
//                            self.dismissToRoot()
//                        }else{
//                            LSHUD.showInfo(resp.errmsg ?? "")
//                        }
//                        self.dismissToRoot()
//                    })
//
//                }else{
//                    LSHUD.hide()
//                    LSHUD.showInfo(resp.errmsg ?? "")
//                }
//            }
        }else if type == .forgetPassWord {
//            PSNetworkManager.shared.putUsersPassword(["code": centerTextField.textField.text ?? "", "new_password": (botttomTextField.textField.text ?? "").md5,"phone":topTextField.textField.text ?? ""]) { (resp) in
//                if resp.code == .success {
//                    self.dismiss(animated: true, completion: nil)
//                    LSHUD.showSuccess("找回密码成功")
//                }else{
//                    LSHUD.showInfo(resp.errmsg ?? "")
//                }
//            }
        }
    }
    
    func dismissToRoot(){
        var temp = self.presentingViewController
        while temp?.presentingViewController != nil {
            temp = temp?.presentingViewController
        }
        temp?.dismiss(animated: true, completion: nil)
    }
    
    @objc func delegateAttachment(){
//        pushTo(PSProtocalVC())
    }
    
    @objc func agreeBtnAction(){
        agreeBtn.isSelected = !agreeBtn.isSelected
    }
    
    @objc func codeBtnAction(){
        if !(topTextField.textField.text ?? "").ls_isMobile() {
            LSHUD.showInfo("请填写正确手机号")
            return
        }
        //todo发送验证码，请求成功之后调用
//        PSNetworkManager.shared.postThirdPhonePhoneCode(topTextField.textField.text ?? "") { (response) in
//            if response.errcode == .success {
//                LSHUD.showSuccess("发送验证码成功")
//                self.codeBtn.animationCodeBtn(second: 60, done: {
//
//                })
//            }
//        }
    }
    
    @objc func backDismiss(){
        if self.type == .register || type == .forgetPassWord{
            self.dismiss(animated: true, completion: nil)
        }else{
            pop()
        }
    }
}

