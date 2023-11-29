//
//  MyBagController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class MyBagController: BaseController {
    
    let userInfo = LoginManager.shared.getUserInfo()
    let leftMargin = 16.0
    let detailViewCornerRadius: CGFloat = 24
    let topHeight:CGFloat = 216.0
    var userPageData: UserPageModel = UserPageModel()
    let options: [[String: String]] = [["icon": "icon_bag_transaction", "title": "收支记录"], ["icon": "icon_bag_gift", "title": "收到的礼物"], ["icon": "icon_bag_cashing", "title": "提现"]]
    let optionKey = "OptionKey"
    

    override func viewDidLoad() {
        title = "我的钱包"
        super.viewDidLoad()
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        // 重置Navigation
        resetNavigation()
        setupUI()
    }
    
    // TopView
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#FE9C5B", alpha: 0.1)
        return view
    }()
    
    // 账户view
    fileprivate lazy var accountView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#FE9C5B")
        view.layer.cornerRadius = 14
        return view
    }()
    
    fileprivate lazy var accountTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = .white
        label.text = "当前钱包余额"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var accountNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(30)
        label.textColor = .white
        label.text = String(userPageData.user.coinBalance)
        label.sizeToFit()
        return label
    }()
    
    // 充值
    fileprivate lazy var purchaseBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.clipsToBounds = true
        button.setTitle("充值", for: .normal)
        button.layer.cornerRadius = 16
        button.addTarget(self, action: #selector(clickPurchaseBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 详情view
    fileprivate lazy var detailView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = detailViewCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
}

extension MyBagController {
    
    func setData(_ userPageData:UserPageModel) {
        self.userPageData = userPageData
    }
    
    // 获取详情
    func getUserHomePage() {
        NetworkManager.shared.getUserPage  { resp in
            if resp.status == .success {
                LSLog("getUserPage data:\(resp.data)")
                self.userPageData = resp.data
                self.refreshData()
            } else {
                LSLog("getUserPage fail")
            }
        }
    }
    
    // 刷新界面
    func refreshData() {
        
        // 余额
        accountNumLabel.text = String(userPageData.user.coinBalance)
    }
    
    // 充值
    @objc func clickPurchaseBtn(_ sender:UIButton) {
        LSLog("clickPurchaseBtn")
        // 拉起充值view
        RechargeView.shared.showInWindow()
    }
    
    // options
    @objc func clickOptionBtn(_ sender:UIButton) {
        LSLog("clickOptionBtn")
        /**
         * optionValue
         * 1、收支记录
         * 2、收到的礼物
         * 3、提现
         */
        let optionValue:Int = sender.layer.value(forKey: optionKey) as! Int
        if optionValue == 1 {
            PageManager.shared.pushToCoinLogController()
        } else if optionValue == 2 {
            PageManager.shared.pushToGiftLogController()
        } else if optionValue == 3 {
            
        }
    }
}

extension MyBagController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.addSubview(accountView)
        accountView.addSubview(accountTipLabel)
        accountView.addSubview(accountNumLabel)
        accountView.addSubview(purchaseBtn)
        view.addSubview(detailView)
        
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(topHeight)
        }

        accountView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(120)
        }
        
        accountTipLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(leftMargin)
            make.left.equalToSuperview().offset(leftMargin)
        }
        
        accountNumLabel.snp.makeConstraints { (make) in
            make.top.equalTo(accountTipLabel.snp.bottom).offset(4)
            make.left.equalToSuperview().offset(leftMargin)
        }
        
        purchaseBtn.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-leftMargin)
            make.size.equalTo(CGSize(width: 60, height: 32))
        }
        
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-detailViewCornerRadius)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
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
            
            lazy var optionArrow: UIImageView = {
                let imageView = UIImageView()
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                imageView.image = UIImage(named: "icon_arrow_right_black")
                return imageView
            }()
            
            detailView.addSubview(optionBtn)
            optionBtn.addSubview(optionIcon)
            optionBtn.addSubview(optionTitleLabel)
            optionBtn.addSubview(optionArrow)
            
            optionBtn.snp.makeConstraints { (make) in
                make.top.equalToSuperview().offset(12+56*i)
                make.left.right.equalToSuperview()
                make.height.equalTo(56)
            }
            
            optionIcon.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalToSuperview().offset(leftMargin)
                make.size.equalTo(CGSize(width: 16, height: 16))
            }
            
            optionTitleLabel.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.left.equalTo(optionIcon.snp.right).offset(10)
            }
            
            optionArrow.snp.makeConstraints { (make) in
                make.centerY.equalToSuperview()
                make.right.equalToSuperview().offset(-leftMargin)
                make.size.equalTo(CGSize(width: 16, height: 16))
            }
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.backgroundColor = UIColor.clear
        navigationView.backView.backgroundColor = UIColor.clear
    }
}
