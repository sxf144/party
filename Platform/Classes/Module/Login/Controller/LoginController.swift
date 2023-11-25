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
}

extension LoginController {
    
    @objc func clickPhoneLoginBtn(_ sender:UIButton) {
        LSLog("clickPhoneLoginBtn")
        PageManager.shared.pushToPhoneLogin()
    }
    
    @objc func clickWxLoginBtn(_ sender:UIButton) {
        LSLog("clickWxLoginBtn")
        sendAuthRequest()
    }
    
    func sendAuthRequest() {
        //构造SendAuthReq结构体
        let req: SendAuthReq = SendAuthReq()
        req.scope = "snsapi_userinfo"
        req.state = "123"
        //第三方向微信终端发送一个SendAuthReq消息结构
        WXApi.send(req)
//        //构造SendAuthReq结构体
//        SendAuthReq* req =[[[SendAuthReq alloc]init]autorelease];
//        req.scope = @"snsapi_userinfo"; // 只能填 snsapi_userinfo
//        req.state = @"123";
//        //第三方向微信终端发送一个SendAuthReq消息结构
//        [WXApi sendReq:req];
    }
    
    @objc func clickAppleLoginBtn(_ sender:UIButton) {
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
}

extension LoginController: ASAuthorizationControllerDelegate {

    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
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
                    let userIdentifier = appleIDCredential.user
                    let fullName = appleIDCredential.fullName
                    let email = appleIDCredential.email
                    let code = appleIDCredential.authorizationCode
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
        
        
        bgIv.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        phoneLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalTo(-(94+kSafeAreaHeight))
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
    }
}
