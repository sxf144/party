//
//  MyUserPageController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import swiftScan

class MyUserPageController: BaseController {
    
    let infoWidth = 80.0
    let infoHeight = 60.0
    var userInfo:UserInfoModel = LoginManager.shared.getUserInfo() ?? UserInfoModel()
    let leftMargin = 16.0
    let detailViewCornerRadius: CGFloat = 24
    let topHeight:CGFloat = 316.0
    var peopleId: String = ""
    var userPageData: UserPageModel = LoginManager.shared.getUserPageInfo() ?? UserPageModel()
    

    override func viewDidLoad() {
        showNavifationBar = false
        slideBackEnabled = false
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        
        super.viewDidLoad()
        setupUI()
        addObservers()
        
        // 获取个人主页信息
        LoginManager.shared.getUserPage()
    }
    
    // TopView
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderBig)
        return imageView
    }()
    
    // 扫码按钮
    fileprivate lazy var qrScanBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "icon_qrscan"), for: .normal)
        button.addTarget(self, action: #selector(clickQRScanBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 头像小
    fileprivate lazy var avatarSmall: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 39
        imageView.layer.borderWidth = 1
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 昵称
    fileprivate lazy var nickLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(22)
        label.textColor = UIColor.white
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    // 性别
    fileprivate lazy var sexIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_female")
        return imageView
    }()
    
    // 编辑资料
    fileprivate lazy var editBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = kFontRegualer14
        button.clipsToBounds = true
        button.setTitle("编辑资料 >", for: .normal)
        button.addTarget(self, action: #selector(clickEditBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 关注
    fileprivate lazy var followView: UIView = {
        let view = UIView()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(followTapAction(_:)))
        view.addGestureRecognizer(singleTap)
        return view
    }()
    
    fileprivate lazy var followNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = .white
        label.text = ""
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var followTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#ffffff", alpha: 0.5)
        label.text = "关注"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 粉丝
    fileprivate lazy var fansView: UIView = {
        let view = UIView()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(fansTapAction(_:)))
        view.addGestureRecognizer(singleTap)
        return view
    }()
    
    fileprivate lazy var fansNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = .white
        label.text = ""
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var fansTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#ffffff", alpha: 0.5)
        label.text = "粉丝"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 礼物
    fileprivate lazy var giftView: UIView = {
        let view = UIView()
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(giftTapAction(_:)))
        view.addGestureRecognizer(singleTap)
        return view
    }()
    
    fileprivate lazy var giftNumLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(18)
        label.textColor = .white
        label.text = " "
        label.textAlignment = .center
        return label
    }()
    
    fileprivate lazy var giftTipLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(12)
        label.textColor = UIColor.ls_color("#ffffff", alpha: 0.5)
        label.text = "礼物"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 详情view
    fileprivate lazy var detailView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = detailViewCornerRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    // 账户view
    fileprivate lazy var accountBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 14
        button.addTarget(self, action: #selector(clickAccountBtn(_:)), for: .touchUpInside)
        return button
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
        label.text = ""
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
    
    // 设置
    fileprivate lazy var settingBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickSettingBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var settingIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_setting")
        return imageView
    }()
    
    fileprivate lazy var settingTitleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = "设置"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var rightArrowIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_arrow_right_black")
        return imageView
    }()
}

extension MyUserPageController {
    
    func addObservers() {
        LSLog("addObservers")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPageInfoChange(_:)), name: NotificationName.userPageInfoChange, object: nil)
    }
    
    @objc func handleUserPageInfoChange(_ notification: Notification) {
        LSLog("MyUserPageController handleUserPageInfoChange")
        self.userInfo = LoginManager.shared.getUserInfo() ?? UserInfoModel()
        self.userPageData = LoginManager.shared.getUserPageInfo() ?? UserPageModel()
        self.refreshData()
    }
    
    // 刷新界面
    func refreshData() {
        // 头像
        avatar.kf.setImage(with: URL(string: userPageData.user.portrait), placeholder: PlaceHolderBig)
        
        // 头像小
        avatarSmall.kf.setImage(with: URL(string: userPageData.user.portrait), placeholder: PlaceHolderAvatar)
        
        // 昵称
        nickLabel.text = userPageData.user.nick
        nickLabel.sizeToFit()
        
        // 性别
        sexIcon.image = UIImage(named: userPageData.user.sex == 1 ? "icon_male" : "icon_female")
        
        // 关注
        followNumLabel.text = String(userPageData.relation.followCnt)
        
        // 粉丝
        fansNumLabel.text = String(userPageData.relation.fansCnt)
        
        // 礼物
        giftNumLabel.text = String(userPageData.gift.recvGiftCnt)
        
        // 余额
        accountNumLabel.text = String(userPageData.user.coinBalance)
    }
    
    // 编辑资料
    @objc func clickQRScanBtn(_ sender:UIButton) {
        LSLog("clickQRScanBtn")
        let vc = LBXScanViewController()
        vc.scanResultDelegate = self
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    // 编辑资料
    @objc func clickEditBtn(_ sender:UIButton) {
        LSLog("clickEditBtn")
        PageManager.shared.pushToEditUserController()
    }
    
    // 点击账户
    @objc func clickAccountBtn(_ sender:UIButton) {
        LSLog("clickAccountBtn")
        PageManager.shared.pushToMyBagController(userPageData)
    }
    
    // 充值
    @objc func clickPurchaseBtn(_ sender:UIButton) {
        LSLog("clickPurchaseBtn")
        // 拉起充值view
        RechargeView.shared.showInWindow()
    }
    
    // 设置
    @objc func clickSettingBtn(_ sender:UIButton) {
        LSLog("clickSettingBtn")
        PageManager.shared.pushToSettingController()
    }
    
    // 关注
    @objc private func followTapAction(_ tap: UITapGestureRecognizer) {
        PageManager.shared.pushToFollowListController()
    }
    
    // 粉丝
    @objc private func fansTapAction(_ tap: UITapGestureRecognizer) {
        PageManager.shared.pushToFansListController()
    }
    
    // 礼物
    @objc private func giftTapAction(_ tap: UITapGestureRecognizer) {
        PageManager.shared.pushToGiftLogController()
    }
}

extension MyUserPageController: LBXScanViewControllerDelegate  {
    
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        LSLog("scanFinished strScanned:\(scanResult.strScanned ?? "")")
        if let str = scanResult.strScanned {
            if let url = URL(string: scanResult.strScanned) {
                if let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                    if urlComponents.path.contains("detail") {
                        // 跳转到partyDetail
                        // 解析参数
                        if let queryItems = urlComponents.queryItems {
                            for queryItem in queryItems {
                                if queryItem.name == "code" {
                                    if let uniCode = queryItem.value {
                                        PageManager.shared.pushToPartyDetail(uniCode)
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

extension MyUserPageController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.addSubview(avatar)
        topView.addSubview(qrScanBtn)
        topView.addSubview(avatarSmall)
        topView.addSubview(nickLabel)
        topView.addSubview(sexIcon)
        topView.addSubview(editBtn)
        topView.addSubview(followView)
        followView.addSubview(followNumLabel)
        followView.addSubview(followTipLabel)
        topView.addSubview(fansView)
        fansView.addSubview(fansNumLabel)
        fansView.addSubview(fansTipLabel)
        topView.addSubview(giftView)
        giftView.addSubview(giftNumLabel)
        giftView.addSubview(giftTipLabel)
        view.addSubview(detailView)
        detailView.addSubview(accountBtn)
        accountBtn.addSubview(accountTipLabel)
        accountBtn.addSubview(accountNumLabel)
        accountBtn.addSubview(purchaseBtn)
        detailView.addSubview(settingBtn)
        settingBtn.addSubview(settingIcon)
        settingBtn.addSubview(settingTitleLabel)
        settingBtn.addSubview(rightArrowIcon)
        
        topView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(topHeight)
        }

        avatar.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        qrScanBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight-33)
            make.right.equalToSuperview().offset(-leftMargin)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
        
        avatarSmall.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(136)
            make.left.equalToSuperview().offset(leftMargin)
            make.size.equalTo(CGSize(width: 78, height: 78))
        }
        
        nickLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatarSmall.snp.right).offset(leftMargin)
            make.top.equalTo(avatarSmall).offset(12)
        }
        
        sexIcon.snp.makeConstraints { (make) in
            make.left.equalTo(nickLabel.snp.right).offset(5)
            make.centerY.equalTo(nickLabel)
            make.size.equalTo(CGSize(width: 18, height: 18))
        }
        
        editBtn.snp.makeConstraints { (make) in
            make.left.equalTo(avatarSmall.snp.right).offset(leftMargin)
            make.bottom.equalTo(avatarSmall).offset(-10)
        }
        
        followView.snp.makeConstraints { (make) in
            make.top.equalTo(avatarSmall.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(4)
            make.size.equalTo(CGSize(width: infoWidth, height: infoHeight))
        }
        
        followNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        followTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(followNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(followNumLabel)
        }
        
        fansView.snp.makeConstraints { (make) in
            make.top.equalTo(followView)
            make.left.equalTo(followView.snp.right)
            make.size.equalTo(CGSize(width: infoWidth, height: infoHeight))
        }
        
        fansNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        fansTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(fansNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(fansNumLabel)
        }
        
        giftView.snp.makeConstraints { (make) in
            make.top.equalTo(fansView)
            make.left.equalTo(fansView.snp.right)
            make.size.equalTo(CGSize(width: infoWidth, height: infoHeight))
        }
        
        giftNumLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
        }
        
        giftTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(giftNumLabel.snp.bottom).offset(8)
            make.centerX.equalTo(giftNumLabel)
        }
        
        detailView.snp.makeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom).offset(-detailViewCornerRadius)
            make.width.equalToSuperview()
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview()
        }
        
        accountBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(leftMargin)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(96)
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
        
        settingBtn.snp.makeConstraints { (make) in
            make.top.equalTo(accountBtn.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(56)
        }
        
        settingIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(leftMargin)
            make.size.equalTo(CGSize(width: 24, height: 24))
        }
        
        settingTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(settingIcon.snp.right).offset(10)
        }
        
        rightArrowIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview()
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
}
