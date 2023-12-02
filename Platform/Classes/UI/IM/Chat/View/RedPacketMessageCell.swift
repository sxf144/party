//
//  RedPacketMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class RedPacketMessageCell: UITableViewCell {
    
    /// 回调闭包
    public var fetchBlock: (() -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentWidth: CGFloat = 240.0
    var item: LIMMessage = LIMMessage()
    var party: PartyDetailModel = PartyDetailModel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = UIColor.clear
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 用户头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HeadWidth/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        let avatarTap = UITapGestureRecognizer(target: self, action: #selector(avatarTaped(_:)))
        imageView.addGestureRecognizer(avatarTap)
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    // 用户昵称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 主持人
    fileprivate lazy var hostLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.ls_color("#FE9C5B")
        label.font = kFontRegualer10
        label.textColor = .white
        label.text = "主持人"
        label.layer.cornerRadius = 9
        label.clipsToBounds = true
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 消息内容
    fileprivate lazy var contentBtn: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FF4A4A")
        button.addTarget(self, action: #selector(clickRedPacketBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var iconIV: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_red_packet")
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.white
        label.text = "大吉大利恭喜发财"
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.white
        label.text = "桔子糖红包"
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
}

extension RedPacketMessageCell {
    
    func configure(_ citem: LIMMessage, party:PartyDetailModel) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        self.party = party
        
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            hostLabel.isHidden = true
            
            contentBtn.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-xMargin)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.size.equalTo(CGSize(width: ContentWidth, height: 70))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
            
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            // 判断消息发送者是否主持人
            hostLabel.isHidden = self.party.userId != item.sender
            
            contentBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.size.equalTo(CGSize(width: ContentWidth, height: 70))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
            
            // 用户头像
            avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)
            
            // 用户昵称
            nameLabel.text = item.nickName
            nameLabel.sizeToFit()
        }
        
        // 红包状态
        contentBtn.alpha = item.redPacketElem?.status == 1 ? 0.5 : 1
    }
    
    // 点击红包
    @objc func clickRedPacketBtn(_ sender:UIButton) {
        LSLog("clickRedPacketBtn")
        if let fetchBlock = fetchBlock {
            fetchBlock()
        }
    }
    
    // 点击用户头像
    @objc private func avatarTaped(_ tap: UITapGestureRecognizer) {
        if let pid = item.sender {
            PageManager.shared.pushToUserPage(pid)
        }
    }
}

extension RedPacketMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(hostLabel)
        contentView.addSubview(contentBtn)
        contentBtn.addSubview(iconIV)
        contentBtn.addSubview(titleLabel)
        contentBtn.addSubview(tipLabel)
        
        avatar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.size.equalTo(CGSizeMake(HeadWidth, HeadWidth))
            make.top.equalToSuperview().offset(yMargin)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalToSuperview().offset(yMargin)
        }
        
        hostLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(6)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(CGSize(width: 46, height: 18))
        }
        
        contentBtn.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalToSuperview().offset(yMargin + 22)
            make.size.equalTo(CGSize(width: ContentWidth, height: 70))
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        iconIV.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 32, height: 38))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV.snp.right).offset(25)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(16)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV.snp.right).offset(25)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(40)
        }
    }
}

