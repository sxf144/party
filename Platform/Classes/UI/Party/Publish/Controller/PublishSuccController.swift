//
//  PublishSuccController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class PublishSuccController: BaseController {
    
    let qrPlaceHolder = UIImage(named: "default_big")
    var sTime: String = ""
    var eTime: String = ""
    var uniCode: String = ""
    
    override func viewDidLoad() {
        self.title = "发布成功"
        super.viewDidLoad()
        setupUI()
    }
    
    // 创建UITableView
    fileprivate lazy var qrCode: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: qrPlaceHolder)
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
    fileprivate lazy var inviteIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "invite")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        return imageView
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
    fileprivate lazy var shareIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "share_weixin")
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 28
        return imageView
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
    
    func setData(startTime: String, endTime: String, uniqueCode: String) {
        sTime = startTime
        eTime = endTime
        uniCode = uniqueCode
//        let qrCodeUrl = "juzitang://detail?code=\(uniCode)"
//        qrCode.kf.setImage(with: URL(string: qrCodeUrl), placeholder: qrPlaceHolder)
        timeLabel.text = "时间：\(sTime)-\(eTime)"
        timeLabel.sizeToFit()
    }
}


extension PublishSuccController{
    fileprivate func setupUI(){
        
        view.addSubview(qrCode)
        view.addSubview(tipLabel)
        view.addSubview(timeLabel)
        view.addSubview(inviteIV)
        view.addSubview(inviteLabel)
        view.addSubview(shareIV)
        view.addSubview(shareLabel)
        
        
        qrCode.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight + 40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 188, height: 188))
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(qrCode.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        timeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(tipLabel.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        inviteIV.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview().offset(-60)
        }
        
        inviteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(inviteIV.snp.bottom).offset(8)
            make.centerX.equalTo(inviteIV)
        }
        
        shareIV.snp.makeConstraints { (make) in
            make.top.equalTo(timeLabel.snp.bottom).offset(40)
            make.centerX.equalToSuperview().offset(60)
        }
        
        shareLabel.snp.makeConstraints { (make) in
            make.top.equalTo(shareIV.snp.bottom).offset(8)
            make.centerX.equalTo(shareIV)
        }
    }
}
