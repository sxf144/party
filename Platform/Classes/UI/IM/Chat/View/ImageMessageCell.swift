//
//  ImageMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class ImageMessageCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentImageWidth: CGFloat = 140.0
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
        label.text = " "
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 图片
    fileprivate lazy var ivContent: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        return imageView
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

extension ImageMessageCell {
    
    func configure(with citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            // 重新发送按钮
            reSendBtn.isHidden = !(item.originMessage?.status == .V2TIM_MSG_STATUS_SEND_FAIL)
            
            ivContent.snp.remakeConstraints { (make) in
                make.right.equalToSuperview().offset(-xMargin)
                make.top.equalToSuperview().offset(yMargin)
                make.bottom.equalToSuperview().offset(-yMargin)
                make.size.equalTo(CGSize(width: ContentImageWidth, height: ContentImageWidth))
            }
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            reSendBtn.isHidden = true
            
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
            
            ivContent.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.bottom.equalToSuperview().offset(-yMargin)
                make.size.equalTo(CGSize(width: ContentImageWidth, height: ContentImageWidth))
            }
        }
        
        // 用户头像
        avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

        // 用户昵称
        nameLabel.text = item.nickName
        nameLabel.sizeToFit()
        
        // 图片消息
        if let imagePath = item.imageElem?.path, !imagePath.isEmpty {
            ivContent.image = UIImage(contentsOfFile: imagePath)
        } else if (item.imageElem?.imageList.count ?? 0 > 0) {
            ivContent.kf.setImage(with: URL(string: item.imageElem?.imageList[0].url ?? ""), placeholder: PlaceHolderSmall)
        }
    }
    
    // 点击重新发送
    @objc fileprivate func clickReSendBtn(_ sender:UIButton) {
        LSLog("clickReSendBtn")
        delegate?.reSend(item)
    }
}

extension ImageMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(ivContent)
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
        
        ivContent.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(12)
            make.top.equalToSuperview().offset(22)
            make.right.equalToSuperview().offset(-65)
            make.bottom.equalToSuperview().offset(-yMargin)
            make.size.equalTo(CGSize(width: ContentImageWidth, height: ContentImageWidth))
        }
        
        reSendBtn.snp.makeConstraints { (make) in
            make.right.equalTo(ivContent.snp.left).offset(-8)
            make.centerY.equalTo(ivContent)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
    }
}

