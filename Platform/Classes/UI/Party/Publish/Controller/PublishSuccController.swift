//
//  PublishSuccController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import swiftScan

class PublishSuccController: BaseController {
    
    let qrSize: CGSize = CGSize(width: 188, height: 188)
    var sTime: String = ""
    var eTime: String = ""
    var uniCode: String = ""
    var name: String = ""
    var cover: UIImage?
    var qrCodeImage: UIImage?
    
    override func viewDidLoad() {
        title = "发布成功"
        super.viewDidLoad()
        setupUI()
        resetNavigation()
    }
    
    override func pop() {
        LSLog("PublishSuccController pop")
        // 返回到堆栈中的某个特定视图控制器
        if let targetViewController = PageManager.shared.currentNav()?.viewControllers.first(where: { $0 is BaseController }) {
            PageManager.shared.currentNav()?.popToViewController(targetViewController, animated: true)
        }
    }
    
    // 二维码图片
    fileprivate lazy var qrCode: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderBig)
        return imageView
    }()
    
    // tip
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.text = "扫描二维码加入"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.sizeToFit()
        return label
    }()
    
    // time
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.sizeToFit()
        return label
    }()
    
    // 邀请好友
    fileprivate lazy var inviteBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_invite"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(clickInviteBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var inviteLabel: UILabel = {
        let label = UILabel()
        label.text = "邀请好友加入"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.sizeToFit()
        return label
    }()
    
    // 分享到微信
    fileprivate lazy var shareBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "share_weixin"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 28
        button.addTarget(self, action: #selector(clickShareBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var shareLabel: UILabel = {
        let label = UILabel()
        label.text = "分享到微信"
        label.textColor = UIColor.ls_color("#333333")
        label.font = UIFont.ls_font(14)
        label.sizeToFit()
        return label
    }()
}

extension PublishSuccController {
    
    func setData(startTime: String, endTime: String, uniqueCode: String, name:String, cover:UIImage?) {
        sTime = startTime
        eTime = endTime
        uniCode = uniqueCode
        self.name = name
        self.cover = cover
        
        let qrCodeUrl = "\(UNIVERSAL_LINK)/detail?code=\(uniCode)"
        // 调用生成二维码的方法
        if let qrCodeImage = LBXScanWrapper.createCode(codeType: "CIQRCodeGenerator", codeString: qrCodeUrl, size: qrSize, qrColor: .black, bkColor: .white) {
            qrCode.image = qrCodeImage
        }

        timeLabel.text = Date.formatDate(startTime: sTime, endTime: eTime)
        timeLabel.sizeToFit()
    }
    
    override func rightAction() {
        pop()
    }
    
    // 邀请好友
    @objc func clickInviteBtn(_ sender:UIButton) {
        let vc = FollowListController()
        vc.setData(true)
        vc.followSelectedBlock = { [weak self] followItems in
            LSLog("followSelectedBlock followItems:\(followItems)")
            var peopleIds:[String] = []
            for i in 0 ..< followItems.count {
                let fItem = followItems[i]
                peopleIds.append(fItem.userId)
            }
            // 邀请加入局
            self?.inviteJoinParty(peopleIds)
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    // 分享到微信
    @objc func clickShareBtn(_ sender:UIButton) {
        // 分享
        let title = "邀请你加入\(name)"
        let desc = timeLabel.text!
        let pageUrl = "\(UNIVERSAL_LINK)/detail?code=\(uniCode)"
        WXApiManager.shared.shareToWX(title, description: desc, pageUrl: pageUrl, image: cover)
    }
    
    // 邀请加入组局
    func inviteJoinParty(_ peopleIds:[String]) {
        NetworkManager.shared.inviteJoinParty(uniCode, peopleIds: peopleIds) { resp in
            
            if resp.status == .success {
                LSLog("inviteJoinParty:\(resp)")
                LSHUD.showSuccess("邀请已发出")
            } else {
                LSLog("inviteJoinParty fail")
            }
        }
    }
}


extension PublishSuccController {
    
    fileprivate func setupUI() {
        
        view.addSubview(qrCode)
        view.addSubview(tipLabel)
        view.addSubview(timeLabel)
        view.addSubview(inviteBtn)
        view.addSubview(inviteLabel)
        view.addSubview(shareBtn)
        view.addSubview(shareLabel)
        
        qrCode.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight + 40)
            make.centerX.equalToSuperview()
            make.size.equalTo(qrSize)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrCode.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        inviteBtn.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview().offset(-60)
        }
        
        inviteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inviteBtn.snp.bottom).offset(8)
            make.centerX.equalTo(inviteBtn)
        }
        
        shareBtn.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview().offset(60)
        }
        
        shareLabel.snp.makeConstraints { (make) in
            make.top.equalTo(shareBtn.snp.bottom).offset(8)
            make.centerX.equalTo(shareBtn)
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.rightButton.setImage(nil, for: .normal)
        navigationView.rightButton.setTitle("完成", for: .normal)
        navigationView.rightButton.setTitleColor(UIColor.ls_color("#ffffff"), for: .normal)
        navigationView.rightButton.titleLabel?.font = UIFont.ls_mediumFont(15)
        navigationView.rightButton.layer.cornerRadius = 8
        navigationView.rightButton.backgroundColor = UIColor.ls_color("#FE9C5B")
        
        navigationView.rightButton.snp.updateConstraints { (make) in
            make.right.equalTo(-16)
            make.bottom.equalToSuperview().offset(-6)
            make.width.greaterThanOrEqualTo(56)
            make.height.equalTo(32)
        }
    }
}
