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
    
    /// 回调闭包
    public var imageClickBlock: ((_ image: UIImage?) -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentImageWidth: CGFloat = 140.0
    var item: LIMMessage = LIMMessage()
    var party: PartyDetailModel = PartyDetailModel()
    var image: UIImage?
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
    
    // 图片
    fileprivate lazy var ivContent: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderSmall)
        let imageTap = UITapGestureRecognizer(target: self, action: #selector(imageTaped(_:)))
        imageView.addGestureRecognizer(imageTap)
        imageView.isUserInteractionEnabled = true
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
    
    func configure(_ citem: LIMMessage, party:PartyDetailModel) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        self.party = party
        
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            hostLabel.isHidden = true
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
            // 判断消息发送者是否主持人
            hostLabel.isHidden = self.party.userId != item.sender
            reSendBtn.isHidden = true
            
            ivContent.snp.remakeConstraints { (make) in
                make.left.equalTo(avatar.snp.right).offset(12)
                make.top.equalToSuperview().offset(yMargin + 22)
                make.bottom.equalToSuperview().offset(-yMargin)
                make.size.equalTo(CGSize(width: ContentImageWidth, height: ContentImageWidth))
            }
            
            // 用户头像
            avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

            // 用户昵称
            nameLabel.text = item.nickName
            nameLabel.sizeToFit()
        }
        
        // 图片消息
        if let imageElem = item.imageElem {
            if let imagePath = imageElem.path, !imagePath.isEmpty {
                ivContent.image = UIImage(contentsOfFile: imagePath)
            } else if (imageElem.imageList.count > 0) {
                let url = imageElem.imageList.count >= 2 ? imageElem.imageList[1].url :imageElem.imageList[0].url
//                ivContent.kf.setImage(with: URL(string: url), placeholder: PlaceHolderSmall)
                ivContent.kf.setImage(with: URL(string: url ), placeholder: PlaceHolderSmall) { result in
                    switch result {
                    case .success(let value):
                        LSLog("ivContent load succ")
                        self.image = value.image
                    case .failure(let error):
                        LSLog("ivContent load error:\(error)")
                    }
                }
            }
        }
    }
    
    // 点击重新发送
    @objc fileprivate func clickReSendBtn(_ sender:UIButton) {
        LSLog("clickReSendBtn")
        if let delegate = delegate {
            delegate.reSend(item)
        }
    }
    
    // 点击用户头像
    @objc private func avatarTaped(_ tap: UITapGestureRecognizer) {
        if let pid = item.sender {
            PageManager.shared.pushToUserPage(pid)
        }
    }
    
    // 点击图片
    @objc private func imageTaped(_ tap: UITapGestureRecognizer) {
        if let imageClickBlock = imageClickBlock {
            imageClickBlock(image ?? nil)
        }
    }
}

extension ImageMessageCell {
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(hostLabel)
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
        }
        
        hostLabel.snp.makeConstraints { (make) in
            make.left.equalTo(nameLabel.snp.right).offset(6)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(CGSize(width: 46, height: 18))
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

