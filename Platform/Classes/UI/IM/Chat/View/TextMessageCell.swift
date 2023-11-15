//
//  TextMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class TextMessageCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentWidth: CGFloat = 240.0
    var item: LIMMessage = LIMMessage()
    weak var delegate: ChatDelegate?
    
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
        label.text = ""
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 消息内容
    fileprivate lazy var messageView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 8
        return view
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer14
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.numberOfLines = 0
        label.sizeToFit()
        return label
    }()
    
    // 失败后，重新发送按钮
    fileprivate lazy var reSendBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#F95A65")
        button.setTitle("!", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontRegualer12
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickReSendBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension TextMessageCell {
    
    func configure(with citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            // 重新发送按钮
            reSendBtn.isHidden = !(item.originMessage?.status == .V2TIM_MSG_STATUS_SEND_FAIL)
            messageView.backgroundColor = UIColor.ls_color("#4974FD")
            messageLabel.textColor = UIColor.white
            messageView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            
            
            messageView.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-xMargin)
                make.width.lessThanOrEqualTo(ContentWidth)
                make.top.equalToSuperview().offset(yMargin)
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            reSendBtn.isHidden = true
            messageView.backgroundColor = UIColor.white
            messageLabel.textColor = UIColor.ls_color("#333333")
            messageView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            
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
            
            messageView.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.width.lessThanOrEqualTo(ContentWidth)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
        
        // 用户头像
        avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

        // 用户昵称
        nameLabel.text = item.nickName
        nameLabel.sizeToFit()
        
        // 消息内容
        messageLabel.text = item.textElem?.text == "" ? " " : item.textElem?.text
        messageLabel.sizeToFit()
    }
    
    // 点击重新发送
    @objc fileprivate func clickReSendBtn(_ sender:UIButton) {
        LSLog("clickReSendBtn")
        delegate?.reSend(item)
    }
}

extension TextMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(messageView)
        messageView.addSubview(messageLabel)
        contentView.addSubview(reSendBtn)
        
        
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
        
        messageView.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.width.lessThanOrEqualTo(ContentWidth)
            make.top.equalToSuperview().offset(yMargin + 22)
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.bottom.equalToSuperview().offset(-yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
        }
        
        reSendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(messageView.snp.left).offset(-8)
            make.centerY.equalTo(messageView)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
}

