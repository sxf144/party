//
//  GameCardMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class GameCardMessageCell: UITableViewCell {
    
    /// 回调闭包
    public var gameCardConfirmBlock: (() -> ())?
    public var gameCardBlock: (() -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentWidth: CGFloat = 240.0
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
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
        imageView.kf.setImage(with: URL(string: ""), placeholder: CardImageDefault)
        return imageView
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = "抽到了"
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    // 主持人确认按钮
    fileprivate lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("确认完成", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(clickConfirmBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension GameCardMessageCell {
    
    func configure(_ citem: LIMMessage, party:PartyDetailModel) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        self.party = party
        
        // 判断是否是自己
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            hostLabel.isHidden = true
            contentBtn.backgroundColor = UIColor.ls_color("#4974FD")
            contentBtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            titleLabel.textColor = UIColor.white
            
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            // 判断消息发送者是否主持人
            if let userIds = item.gameElem?.action.teamUserIds {
                if userIds.count > 0 {
                    hostLabel.isHidden = self.party.userId != userIds[0]
                } else {
                    hostLabel.isHidden = true
                }
            } else {
                hostLabel.isHidden = true
            }
            
            contentBtn.backgroundColor = UIColor.white
            contentBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            titleLabel.textColor = UIColor.ls_color("#333333")
            
            // 用户头像
            avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

            // 用户昵称
            nameLabel.text = item.nickName
            nameLabel.sizeToFit()
        }
        
        
        // 主持人是自己
        let userInfo = LoginManager.shared.getUserInfo()
        if item.gameElem?.adminUserId == userInfo?.userId {
            // 判断任务是否已完成
            if item.gameElem?.status == 1 {
                confirmBtn.isHidden = true
            } else {
                confirmBtn.isHidden = false
            }
        } else {
            confirmBtn.isHidden = true
        }
        
        if confirmBtn.isHidden {
            
            // 先重置confirmBtn的约束，为先取消底部跟superview的约束，否则约束要报错
            confirmBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(contentBtn.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 114, height: 32))
            }
            
            if item.isSelf ?? false {
                contentBtn.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview().offset(-xMargin)
                    make.top.equalToSuperview().offset(yMargin)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                    make.bottom.equalToSuperview().offset(-yMargin)
                }
                
                iconIV.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 74, height: 74))
                }
                
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconIV.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-20)
                    make.centerY.equalToSuperview()
                }
            } else {
                contentBtn.snp.remakeConstraints { (make) in
                    make.left.equalTo(avatar.snp.right).offset(12)
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                    make.bottom.equalToSuperview().offset(-yMargin)
                }
                
                iconIV.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 74, height: 74))
                }
                
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(20)
                    make.right.equalTo(iconIV.snp.left).offset(-16)
                    make.centerY.equalToSuperview()
                }
            }
        } else {
            
            // 先重置contentBtn的约束，为先取消底部跟superview的约束，否则约束要报错
            if item.isSelf ?? false {
                contentBtn.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview().offset(-xMargin)
                    make.top.equalToSuperview().offset(yMargin)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                }
                
                iconIV.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 74, height: 74))
                }
                
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalTo(iconIV.snp.right).offset(16)
                    make.right.equalToSuperview().offset(-20)
                    make.centerY.equalToSuperview()
                }
            } else {
                contentBtn.snp.remakeConstraints { (make) in
                    make.left.equalTo(avatar.snp.right).offset(12)
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                }
                
                iconIV.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview()
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: 74, height: 74))
                }
                
                titleLabel.snp.remakeConstraints { (make) in
                    make.left.equalToSuperview().offset(20)
                    make.right.equalTo(iconIV.snp.left).offset(-16)
                    make.centerY.equalToSuperview()
                }
            }
            
            confirmBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(contentBtn.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 114, height: 32))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
        
        // 封面图
        iconIV.kf.setImage(with: URL(string: item.gameElem?.action.cardInfo.introductionThumbnail ?? ""), placeholder: CardImageDefault)
        
        // 名称
        // 创建一个富文本字符串
        let nameString = item.gameElem?.action.cardInfo.name ?? ""
        let attributedText = NSMutableAttributedString(string: "抽到了「\(nameString)」")
        attributedText.addAttributes([.foregroundColor: UIColor.ls_color("#FE9C5B")], range: NSRange(location: 3, length: nameString.count + 2))
        titleLabel.attributedText = attributedText
    }
    
    // 点击内容
    @objc func clickContentBtn(_ sender:UIButton) {
        LSLog("clickContentBtn")
        if let gameCardBlock = gameCardBlock {
            gameCardBlock()
        }
        
    }
    
    // 主持人确认
    @objc func clickConfirmBtn(_ sender:UIButton) {
        LSLog("clickConfirmBtn")
        if let gameCardConfirmBlock = gameCardConfirmBlock {
            gameCardConfirmBlock()
        }
    }
    
    // 点击用户头像
    @objc private func avatarTaped(_ tap: UITapGestureRecognizer) {
        if let userIds = item.gameElem?.action.teamUserIds {
            if userIds.count > 0 {
                let pid = userIds[0]
                PageManager.shared.pushToUserPage(pid)
            }
        }
    }
}

extension GameCardMessageCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(hostLabel)
        contentView.addSubview(contentBtn)
        contentBtn.addSubview(iconIV)
        contentBtn.addSubview(titleLabel)
        contentView.addSubview(confirmBtn)
        
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
            make.size.equalTo(CGSize(width: ContentWidth, height: 74))
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        iconIV.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 74, height: 74))
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(iconIV.snp.left).offset(-16)
            make.centerY.equalToSuperview()
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(contentBtn.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 32))
        }
    }
}

