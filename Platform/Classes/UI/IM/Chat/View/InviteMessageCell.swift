//
//  InviteMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class InviteMessageCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentWidth: CGFloat = 240.0
    var item: LIMMessage = LIMMessage()
    
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
    
    // 消息内容
    fileprivate lazy var contentBtn: UIButton = {
        let button = UIButton()
        button.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.backgroundColor = UIColor.white
        button.addTarget(self, action: #selector(clickContentBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var iconIV: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.numberOfLines = 2
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer10
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
}

extension InviteMessageCell {
    
    func configure(with citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            contentBtn.backgroundColor = UIColor.ls_color("#4974FD")
            contentBtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            titleLabel.textColor = UIColor.white
            tipLabel.textColor = UIColor.white
            
            contentBtn.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-xMargin)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
            
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            contentBtn.backgroundColor = UIColor.white
            contentBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            titleLabel.textColor = UIColor.ls_color("#333333")
            tipLabel.textColor = UIColor.ls_color("#333333")
            
            avatar.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(xMargin)
                make.size.equalTo(CGSizeMake(HeadWidth, HeadWidth))
                make.top.equalToSuperview().offset(yMargin)
            }
            
            nameLabel.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalTo(avatar)
                make.right.equalToSuperview().offset(-65)
            }
            
            contentBtn.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
        
        // 用户头像
        avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

        // 用户昵称
        nameLabel.text = item.nickName
        nameLabel.sizeToFit()
        
        // 封面图
        iconIV.kf.setImage(with: URL(string: item.inviteElem?.coverThumbnail ?? ""), placeholder: PlaceHolderSmall)

        // 邀请标题
        var fromName = item.inviteElem?.userName ?? ""
        var toName = item.inviteElem?.toUserName ?? ""
        let userInfo = LoginManager.shared.getUserInfo()
        if (userInfo?.userId == item.inviteElem?.userId) {
            fromName = "你"
        }
        if (userInfo?.userId == item.inviteElem?.toUserId) {
            toName = "你"
        }
        titleLabel.text = "邀请" + toName + "加入" + fromName + "的桔，快来～"
        titleLabel.sizeToFit()

        // 邀请时间
        tipLabel.text = Date.formatDate(startTime: item.inviteElem?.startTime, endTime: item.inviteElem?.endTime)
        tipLabel.sizeToFit()
    }
    
    // 点击内容
    @objc func clickContentBtn(_ sender:UIButton) {
        LSLog("clickContentBtn")
    }
}

extension InviteMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
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
            make.right.equalToSuperview().offset(-65)
        }
        
        contentBtn.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalToSuperview().offset(yMargin + 22)
            make.size.equalTo(CGSize(width: ContentWidth, height: 74))
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        iconIV.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 74, height: 74))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.top.equalToSuperview().offset(10)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(iconIV.snp.right).offset(12)
            make.right.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-5)
        }
    }
}

