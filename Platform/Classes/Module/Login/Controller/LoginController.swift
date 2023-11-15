//
//  LoginController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

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
        button.setImage(UIImage(named: "tab_mine_selected"), for: .normal)
        button.ls_layout(.imageLeft, padding: 30)
        button.addTarget(self, action: #selector(clickPhoneLoginBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var wxLoginBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "tab_mine_selected"), for: .normal)
        return button
    }()
    
    fileprivate lazy var appleLoginBtn:UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "tab_mine_selected"), for: .normal)
        return button
    }()
}

extension LoginController {
    
    @objc func clickPhoneLoginBtn(_ sender:UIButton) {
        PageManager.shared.pushToPhoneLogin()
    }
}


extension LoginController{
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
            make.centerX.equalToSuperview().offset(-30)
            make.top.equalTo(phoneLoginBtn.snp.bottom).offset(30)
        }
        
        appleLoginBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview().offset(30)
            make.top.equalTo(phoneLoginBtn.snp.bottom).offset(30)
        }
    }
}
