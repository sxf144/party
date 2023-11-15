//
//  GameUserTwoCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class GameUserTwoCell: UICollectionViewCell {
    
    let HeadWidth: CGFloat = 44
    let leftMargin: CGFloat = 16
    var item1: SimpleUserInfo = SimpleUserInfo()
    var item2: SimpleUserInfo = SimpleUserInfo()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.ls_color("#F6F6F6")
        layer.cornerRadius = 4
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
    
    // 用户名字
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    // 用户头像2
    fileprivate lazy var avatar2: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HeadWidth/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 用户名字2
    fileprivate lazy var nameLabel2: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#333333")
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 1
        label.lineBreakMode = .byWordWrapping
        return label
    }()
}

extension GameUserTwoCell {
    
    func configure(with items: [SimpleUserInfo]) {
        LSLog("configure items:\(String(describing: items))")
        item1 = items.count > 0 ? items[0] : SimpleUserInfo()
        item2 = items.count > 1 ? items[1] : SimpleUserInfo()
        
        // 判断数据是否为空
        avatar.isHidden = item1.userId.isEmpty
        nameLabel.isHidden = item1.userId.isEmpty
        
        // 卡牌背景
        avatar.kf.setImage(with: URL(string: item1.portrait), placeholder: PlaceHolderAvatar)
        
        // 卡牌名称
        nameLabel.text = item1.nick
        nameLabel.sizeToFit()
        
        // 判断数据是否为空
        avatar2.isHidden = item2.userId.isEmpty
        nameLabel2.isHidden = item2.userId.isEmpty
        
        // 卡牌背景
        avatar2.kf.setImage(with: URL(string: item2.portrait), placeholder: PlaceHolderAvatar)
        
        // 卡牌名称
        nameLabel2.text = item2.nick
        nameLabel2.sizeToFit()
    }
}

extension GameUserTwoCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(avatar2)
        contentView.addSubview(nameLabel2)
        
        avatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview().multipliedBy(0.5)
            make.size.equalTo(CGSize(width: HeadWidth, height: HeadWidth))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(12)
            make.centerX.equalTo(avatar)
        }
        
        avatar2.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview().multipliedBy(1.5)
            make.size.equalTo(CGSize(width: HeadWidth, height: HeadWidth))
        }
        
        nameLabel2.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(12)
            make.centerX.equalTo(avatar2)
        }
    }
}

