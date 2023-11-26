//
//  SettingController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class SettingController: BaseController {
    
    let leftMargin = 16
    let OptionHeight: CGFloat = 54.0
    let options: [[String: String]] = [["title": "账号管理"], ["title": "用户协议"], ["title": "隐私政策"]]
    let optionKey = "OptionKey"

    override func viewDidLoad() {
        self.title = "设置"
        super.viewDidLoad()
        setupUI()
    }
    
    // 详情view
    fileprivate lazy var optionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // 版本号
    fileprivate lazy var versionLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "V \(kAppVersion)"
        label.sizeToFit()
        return label
    }()
    
    // 退出登录
    fileprivate lazy var logoutBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(UIColor.ls_color("#999999"), for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.clipsToBounds = true
        button.setTitle("退出登录", for: .normal)
        button.layer.cornerRadius = 20
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.ls_color("#ededed").cgColor
        button.addTarget(self, action: #selector(clickLogoutBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension SettingController {
    
    // options
    @objc func clickOptionBtn(_ sender:UIButton) {
        LSLog("clickOptionBtn")
        /**
         * optionValue
         * 1、账号管理
         * 2、用户协议
         * 3、隐私政策
         */
        let optionValue:Int = sender.layer.value(forKey: optionKey) as! Int
        if optionValue == 1 {
            PageManager.shared.pushToAccountManagerController()
        } else if optionValue == 2 {
            PageManager.shared.presentWebViewController(Agreement)
        } else if optionValue == 3 {
            PageManager.shared.presentWebViewController(Privacy)
        }
    }
    
    // 退出登录
    @objc func clickLogoutBtn(_ sender:UIButton) {
        LSLog("clickLogoutBtn")
        LoginManager.shared.logout()
    }
    
}

extension SettingController {
    
    fileprivate func setupUI(){
        
        view.addSubview(optionView)
        view.addSubview(versionLabel)
        view.addSubview(logoutBtn)
        
        
        optionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(OptionHeight*CGFloat(options.count))
        }
        
        versionLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(logoutBtn.snp.top).offset(-20)
            make.centerX.equalToSuperview()
        }
        
        logoutBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(40)
        }
        
        setupOptions()
    }
    
    fileprivate func setupOptions() {
        
        for i in 0 ..< options.count {
            
            let option = options[i]
            
            lazy var optionBtn: UIButton = {
                let button = UIButton()
                button.clipsToBounds = true
                button.layer.setValue(i+1, forKey: optionKey)
                button.addTarget(self, action: #selector(clickOptionBtn(_:)), for: .touchUpInside)
                return button
            }()
            
            lazy var optionTitleLabel: UILabel = {
                let label = UILabel()
                label.font = kFontRegualer14
                label.textColor = UIColor.ls_color("#333333")
                label.text = option["title"]
                label.sizeToFit()
                return label
            }()
            
            lazy var optionArrow: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = UIImage(named: "icon_arrow_right_black")
                return imageView
            }()
            
            optionView.addSubview(optionBtn)
            optionBtn.addSubview(optionTitleLabel)
            optionBtn.addSubview(optionArrow)
            
            optionBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(OptionHeight*CGFloat(i))
                make.left.right.equalToSuperview()
                make.height.equalTo(OptionHeight)
            }
            
            optionTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(leftMargin)
            }
            
            optionArrow.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-leftMargin)
                make.size.equalTo(CGSize(width: 16, height: 16))
            }
        }
    }
}
