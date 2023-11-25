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
    public var confirmBlock: (() -> ())?
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
    let HeadWidth: CGFloat = 44.0
    let ContentWidth: CGFloat = 240.0
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
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
    
    func configure(with citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 判断是否是自己
        if item.isSelf ?? false {
            avatar.isHidden = true
            nameLabel.isHidden = true
            contentBtn.backgroundColor = UIColor.ls_color("#4974FD")
            contentBtn.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner, .layerMaxXMaxYCorner]
            titleLabel.textColor = UIColor.white
            
        } else {
            avatar.isHidden = false
            nameLabel.isHidden = false
            contentBtn.backgroundColor = UIColor.white
            contentBtn.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner, .layerMinXMaxYCorner]
            titleLabel.textColor = UIColor.ls_color("#333333")
            
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
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                    make.bottom.equalToSuperview().offset(-yMargin)
                }
            } else {
                contentBtn.snp.remakeConstraints { (make) in
                    make.left.equalTo(avatar.snp.right).offset(12)
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                    make.bottom.equalToSuperview().offset(-yMargin)
                }
            }
            
        } else {
            
            // 先重置contentBtn的约束，为先取消底部跟superview的约束，否则约束要报错
            if item.isSelf ?? false {
                contentBtn.snp.remakeConstraints { (make) in
                    make.right.equalToSuperview().offset(-xMargin)
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                }
            } else {
                contentBtn.snp.remakeConstraints { (make) in
                    make.left.equalTo(avatar.snp.right).offset(12)
                    make.top.equalToSuperview().offset(yMargin + 22)
                    make.size.equalTo(CGSize(width: ContentWidth, height: 74))
                }
            }
            
            confirmBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(contentBtn.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 114, height: 32))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
        
        LSLog("card faceURL:\(item.faceURL ?? "")")
        // 用户头像
        avatar.kf.setImage(with: URL(string: item.faceURL ?? ""), placeholder: PlaceHolderAvatar)

        // 用户昵称
        nameLabel.text = item.nickName
        nameLabel.sizeToFit()
        
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
    }
    
    // 主持人确认
    @objc func clickConfirmBtn(_ sender:UIButton) {
        LSLog("clickConfirmBtn")
        if let confirmBlock = confirmBlock {
            confirmBlock()
        }
    }
}

extension GameCardMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
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
            make.right.equalToSuperview().offset(-65)
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

