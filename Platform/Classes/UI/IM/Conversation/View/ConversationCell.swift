//
//  ConversationCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class ConversationCell: UITableViewCell {
    
    let itemHeight = 80
    let leftMargin: CGFloat = 16.0
    var item: LIMConversation = LIMConversation()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = UIColor.ls_color("#F8F8F8")
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 会话头像
    fileprivate lazy var cover: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 27
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 会话名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 会话时间
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = " "
        label.sizeToFit()
        return label
    }()

    // 最后一条消息
    fileprivate lazy var lastMessageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = " "
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()

    // 未读消息
    fileprivate lazy var unReadLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.ls_color("#FE5B5B")
        label.layer.cornerRadius = 11
        label.clipsToBounds = true
        label.font = kFontRegualer14
        label.textColor = UIColor.white
        label.text = "0"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
}

extension ConversationCell {
    
    func configure(with citem: LIMConversation) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 会话头像
        cover.kf.setImage(with: URL(string: item.faceUrl ?? ""), placeholder: PlaceHolderAvatar)

        // 会话名称
        nameLabel.text = item.showName
        nameLabel.sizeToFit()
        
        // 最后一条消息
        if (item.draftText != nil && item.draftText != "") {
            LSLog("draftText:\(item.draftText ?? "")")
            lastMessageLabel.text = item.draftText
            
            // 最后一条消息时间
            timeLabel.text = item.draftTimestamp?.ls_formatStr()
            timeLabel.sizeToFit()
        } else {
            lastMessageLabel.text = LIMModel.getContentByElem(item.lastMessage )
            
            // 最后一条消息时间
            timeLabel.text = item.lastMessage.timestamp?.ls_formatStr()
            timeLabel.sizeToFit()
        }
        lastMessageLabel.sizeToFit()
        
        // 未读消息
        if let unreadCount = item.originConversation?.unreadCount, unreadCount > 0  {
            unReadLabel.isHidden = false
            unReadLabel.text = unreadCount > 99 ? "+99" : "\(String(unreadCount))"
            unReadLabel.sizeToFit()
        } else {
            unReadLabel.isHidden = true
        }
    }
}

extension ConversationCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(cover)
        contentView.addSubview(nameLabel)
        contentView.addSubview(timeLabel)
        contentView.addSubview(lastMessageLabel)
        contentView.addSubview(unReadLabel)
        
        cover.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.size.equalTo(CGSizeMake(54, 54))
            make.top.equalToSuperview().offset(13)
            make.bottom.equalToSuperview().offset(-13)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(14)
            make.top.equalTo(cover).offset(4)
            make.right.equalTo(timeLabel.snp.left).offset(-10)
        }

        timeLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(nameLabel)
        }

        lastMessageLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
            make.right.equalTo(unReadLabel.snp.left).offset(-10)
        }

        unReadLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(lastMessageLabel)
            make.size.equalTo(CGSize(width: 22, height: 22))
        }
    }
}

