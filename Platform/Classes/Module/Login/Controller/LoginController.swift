//
//  LoginController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import AuthenticationServices
import YYText

class LoginController: BaseController {

    override func viewDidLoad() {
        self.slideBackEnabled = false
        self.showNavifationBar = false
        
        super.viewDidLoad()
        setupView()
    }
    
    @objc func backDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func pop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    fileprivate lazy var bgIv:UIImageView = {
        let imv = UIImageView()
        imv.image = UIImage(named: "login_bg")
        return imv
    }()
    
    fileprivate lazy var phoneLoginBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextBlack, for: .normal)
        button.titleLabel?.font = kFontRegualer16
        button.layer.cornerRadius = 27
        button.layer.borderColor = UIColor.ls_color("#FE9C5B").cgColor
        button.layer.borderWidth = 1
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#ffffff")
        button.setTitle("手机号登录", for: .normal)
        button.addTarget(self, action: #selector(clickPhoneLoginBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var wxLoginBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_login_wx"), for: .normal)
        button.addTarget(self, action: #selector(clickWxLoginBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var appleLoginBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_login_apple"), for: .normal)
        button.addTarget(self, action: #selector(clickAppleLoginBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 协议icon
    fileprivate lazy var tipIcon:UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_cell_normal")
        imageView.highlightedImage = UIImage(named: "icon_cell_selected")
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(tipDidClick))
        imageView.addGestureRecognizer(tapGes)
        imageView.isUserInteractionEnabled = true
        imageView.isHighlighted = true
        return imageView
    }()
    
    fileprivate lazy var tipLabel:YYLabel = {
        let label = YYLabel()
        // 创建一个 NSMutableAttributedString
        let text = NSMutableAttributedString(string: "我已阅读并同意《用户服务协议》和《隐私协议》")
        text.yy_setFont(kFontRegualer12, range: NSRange(location: 0, length: text.length))
        text.yy_setColor(UIColor.ls_color("#999999"), range: NSRange(location: 0, length: text.length))
        text.yy_setTextHighlight(NSRange(location: 7, length: 8), color: UIColor.ls_color("#FE9C5B"), backgroundColor: nil) { containerView, text, range, rect in
            PageManager.shared.presentWebViewController(Agreement)
        }
        
        text.yy_setTextHighlight(NSRange(location: 16, length: 6), color: UIColor.ls_color("#FE9C5B"), backgroundColor: nil) { containerView, text, range, rect in
            PageManager.shared.presentWebViewController(Privacy)
        }

        // 设置文本
        label.attributedText = text
        label.numberOfLines = 0
        return label
    }()
}

extension LoginController {
    
    // 点击手机登录
    @objc func clickPhoneLoginBtn(_ sender:UIButton) {
        guard checkAgreement() else {
            return
        }
        LSLog("clickPhoneLoginBtn")
        PageManager.shared.pushToPhoneLogin(.ActionLogin)
    }
    
    // 点击微信登录
    @objc func clickWxLoginBtn(_ sender:UIButton) {
        guard checkAgreement() else {
            return
        }
        LSLog("clickWxLoginBtn")
        WXApiManager.shared.sendAuthRequest()
    }
    
    // 点击苹果登录
    @objc func clickAppleLoginBtn(_ sender:UIButton) {
        guard checkAgreement() else {
            return
        }
        LSLog("clickAppleLoginBtn")
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.performRequests()
    }
    
    func appleLogin(_ identityToken:String) {
        let source: String = "apple"
        let grantType: String = "authorization_code"
        //发起授权登录
        NetworkManager.shared.authorize("", smsCode: "", code: "", grantType: grantType, source: source, refreshToken: "", identityToken: identityToken) { (resp) in
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
    }
    
    @objc func tipDidClick() {
        LSLog("tipDidClick")
        tipIcon.isHighlighted = !tipIcon.isHighlighted
    }
    
    func checkAgreement() -> Bool {
        var result = tipIcon.isHighlighted
        if !result {
            LSHUD.showInfo("请阅读并同意《用户服务协议》和《隐私协议》")
        }
        return result
    }
}

extension LoginController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if authorization.credential is ASAuthorizationAppleIDCredential {
            // 这里可以使用用户的标识符进行身份验证，或者将其与你的用户系统进行关联
            switch authorization.credential {
                case let appleIDCredential as ASAuthorizationAppleIDCredential:
                    /**
                  - 首次注册 能够那去到的参数分别是：
                  1. user
                  2.state
                  3.authorizedScopes
                  4.authorizationCode
                  5.identityToken
                  6.email
                  7.fullName
                  8.realUserStatus
                    */
                    // Create an account in your system.
//                    let userIdentifier = appleIDCredential.user
//                    let fullName = appleIDCredential.fullName
//                    let email = appleIDCredential.email
//                    let code = appleIDCredential.authorizationCode
                    let token = appleIDCredential.identityToken
//                    // For the purpose of this demo app, store the `userIdentifier` in the keychain.
//                    self.saveUserInKeychain(userIdentifier)
//                    
//                    // For the purpose of this demo app, show the Apple ID credential information in the `ResultViewController`.
//                    self.showResultViewController(userIdentifier: userIdentifier, fullName: fullName, email: email)
//                    BPLog.lmhInfo("userID:\(userIdentifier),fullName:\(fullName),userEmail:\(email),code:\(code)")
                    if let tokenStr:String = String(data:token!, encoding: String.Encoding.utf8) {
                        appleLogin(tokenStr)
                    } else {
                        LSLog("didCompleteWithAuthorization error")
                    }
                    
                case let passwordCredential as ASPasswordCredential:
                    
                    // Sign in using an existing iCloud Keychain credential.
                    let username = passwordCredential.user
                    let password = passwordCredential.password
                    
                    // For the purpose of this demo app, show the password credential as an alert.
//                    DispatchQueue.main.async {
//                        self.showPasswordCredentialAlert(username: username, password: password)
//                    }
                    
                default:
                    break
                }
        } else {
            // 暂不处理
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        LSLog("苹果登录出错：\(error.localizedDescription)")
    }
}

extension LoginController {
    
    fileprivate func setupView(){
        
        view.addSubview(bgIv)
        view.addSubview(phoneLoginBtn)
        view.addSubview(wxLoginBtn)
        view.addSubview(appleLoginBtn)
        view.addSubview(tipIcon)
        view.addSubview(tipLabel)
        
        
        bgIv.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        phoneLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-(120+kSafeAreaHeight))
            make.size.equalTo(CGSize(width: 315, height: 54))
        }
        
        wxLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(-50)
            make.top.equalTo(phoneLoginBtn.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 42, height: 42))
        }
        
        appleLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(50)
            make.top.equalTo(phoneLoginBtn.snp.bottom).offset(30)
            make.size.equalTo(CGSize(width: 42, height: 42))
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(13)
            make.top.equalTo(wxLoginBtn.snp.bottom).offset(30)
        }
        
        tipIcon.snp.makeConstraints { (make) in
            make.right.equalTo(tipLabel.snp.left).offset(-6)
            make.centerY.equalTo(tipLabel)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
}
