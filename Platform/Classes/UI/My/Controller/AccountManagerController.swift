//
//  AccountManagerController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class AccountManagerController: BaseController {
    
    let leftMargin = 16
    let OptionHeight: CGFloat = 54.0
    
    let options: [[String: String]] = [["icon": "icon_account_mobile", "title": "手机号码", "content": "未绑定"], ["icon": "icon_account_weixin", "title": "微信", "content": "未绑定"]]
    let optionKey = "OptionKey"

    override func viewDidLoad() {
        title = "账号管理"
        super.viewDidLoad()
        setupUI()
    }
    
    // 详情view
    fileprivate lazy var optionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
}

extension AccountManagerController {
    
    // options
    @objc func clickOptionBtn(_ sender:UIButton) {
        LSLog("clickOptionBtn")
        /**
         * optionValue
         * 1、手机号码
         * 2、微信
         */
        let optionValue:Int = sender.layer.value(forKey: optionKey) as! Int
        if optionValue == 1 {
            PageManager.shared.pushToPhoneLogin(.ActionBind)
        } else if optionValue == 2 {
            
        }
    }
}

extension AccountManagerController {
    
    fileprivate func setupUI() {
        
        view.addSubview(optionView)
        
        
        optionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(OptionHeight*CGFloat(options.count))
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
            
            lazy var optionIcon: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = UIImage(named: option["icon"] ?? "")
                return imageView
            }()
            
            lazy var optionTitleLabel: UILabel = {
                let label = UILabel()
                label.font = kFontRegualer14
                label.textColor = UIColor.ls_color("#333333")
                label.text = option["title"]
                label.sizeToFit()
                return label
            }()
            
            lazy var optionContentLabel: UILabel = {
                let label = UILabel()
                label.font = kFontRegualer14
                label.textColor = UIColor.ls_color("#999999")
                label.text = option["content"]
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
            optionBtn.addSubview(optionIcon)
            optionBtn.addSubview(optionTitleLabel)
            optionBtn.addSubview(optionContentLabel)
            optionBtn.addSubview(optionArrow)
            
            optionBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(OptionHeight*CGFloat(i))
                make.left.right.equalToSuperview()
                make.height.equalTo(OptionHeight)
            }
            
            optionIcon.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(leftMargin)
                make.size.equalTo(CGSize(width: 18, height: 18))
            }
            
            optionTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(optionIcon.snp.right).offset(10)
            }
            
            optionContentLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalTo(optionArrow.snp.left).offset(-6)
            }
            
            optionArrow.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-leftMargin)
                make.size.equalTo(CGSize(width: 16, height: 16))
            }
        }
    }
}
