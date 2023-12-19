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
    var bindInfo: BindInfo = BindInfo()
    
    let btnTagStart: Int = 1001
    let titleTag: Int = 1011

    override func viewDidLoad() {
        title = "账号管理"
        super.viewDidLoad()
        setupUI()
        addObservers()
        
        // 获取账号绑定信息
        getBindInfo()
    }
    
    // 详情view
    fileprivate lazy var optionView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        return view
    }()
    
    // 注销账号
    fileprivate lazy var deleteBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitleColor(UIColor.ls_color("#666666"), for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.clipsToBounds = true
        let str = "注销账号"
        // 创建一个带有下划线的AttributedString
        let attributedString = NSAttributedString(string: str, attributes: [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue])
        // 将AttributedString设置为按钮的标题
        button.setAttributedTitle(attributedString, for: .normal)
        button.addTarget(self, action: #selector(clickDeleteBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension AccountManagerController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleAccountBindStatusChange(_:)), name: NotificationName.accountBindStatusChange, object: nil)
    }
    
    func getBindInfo() {
        NetworkManager.shared.getExternalBind() { resp in
            LSLog("getExternalBind data:\(String(describing: resp.data))")
            if resp.status == .success {
                LSLog("getExternalBind succ")
                if let bInfo = resp.data?.bindInfo {
                    self.bindInfo = bInfo
                    self.refreshData()
                }
            } else {
                LSLog("getReportReasonList fail")
            }
        }
    }
    
    func refreshData() {
        if !bindInfo.mobile.account.isEmpty {
            let optionBtn1:UIButton = self.view.viewWithTag(self.btnTagStart) as! UIButton
            let titleLabe1:UILabel = optionBtn1.viewWithTag(self.titleTag) as! UILabel
            titleLabe1.text = bindInfo.mobile.account
            titleLabe1.sizeToFit()
        }
        
        if !bindInfo.wx.account.isEmpty {
            let optionBtn2:UIButton = self.view.viewWithTag(self.btnTagStart+1) as! UIButton
            let titleLabe2:UILabel = optionBtn2.viewWithTag(self.titleTag) as! UILabel
            titleLabe2.text = bindInfo.wx.account
            titleLabe2.sizeToFit()
        }
    }
    
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
            // 没有绑定手机，去绑定
            if bindInfo.mobile.account.isEmpty {
                PageManager.shared.pushToPhoneLogin(.ActionBind)
            } else {
                LSHUD.showInfo("暂不支持解绑")
            }
        } else if optionValue == 2 {
            // 没有绑定微信，去绑定
            if bindInfo.wx.account.isEmpty {
                WXApiManager.shared.sendBindRequest()
            } else {
                LSHUD.showInfo("暂不支持解绑")
            }
        }
    }
    
    @objc func handleAccountBindStatusChange(_ notification: Notification) {
        LSLog("handleAccountBindStatusChange")
        self.getBindInfo()
    }
    
    @objc func clickDeleteBtn(_ sender: UIButton) {
        LSLog("clickDeleteBtn")
        // 二次确认
        showDeleteAlert()
    }
    
    func showDeleteAlert() {
        // 二次确认是否要退出
        let alertController = BaseAlertController(title: "确定要注销账号吗？", message: "注销后账号内所有数据都会被清空，且无法恢复账号，请谨慎操作。")
                
        let cancelAction = BaseAlertAction(title: "取消", style: .default) { (action) in
            // 处理取消按钮点击后的操作
        }
        
        let okAction = BaseAlertAction(title: "继续注销", style: .destructive) {(action) in
            self.deleteAccount()
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func deleteAccount() {
        LSHUD.showLoading()
        NetworkManager.shared.deleteAccount() { resp in
            LSHUD.hide()
            if resp.status == .success {
                LSLog("deleteAccount succ")
                // 删除成功，调用退出登录
                LSHUD.showInfo("注销成功")
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    LoginManager.shared.loginExpird()
                }
            } else {
                LSLog("deleteAccount fail")
                LSHUD.showInfo(resp.msg)
            }
        }
    }
}

extension AccountManagerController {
    
    fileprivate func setupUI() {
        
        view.addSubview(optionView)
        view.addSubview(deleteBtn)
        
        
        optionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(OptionHeight*CGFloat(options.count))
        }
        
        deleteBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 66, height: 24))
        }
        
        setupOptions()
    }
    
    fileprivate func setupOptions() {
        
        for i in 0 ..< options.count {
            
            let option = options[i]
            
            lazy var optionBtn: UIButton = {
                let button = UIButton()
                button.tag = btnTagStart + i
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
                label.tag = titleTag
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
