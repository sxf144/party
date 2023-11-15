//
//  GameUserCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit


class GameUserCell: UICollectionViewCell {
    
    let HeadWidth: CGFloat = 44
    let leftMargin: CGFloat = 16
    var item: SimpleUserInfo = SimpleUserInfo()
    var personCount: Int = 1
    
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
}

extension GameUserCell {
    
    func configure(with items: [SimpleUserInfo]) {
        LSLog("configure items:\(String(describing: items))")
        self.item = items.count > 0 ? items[0] : SimpleUserInfo()
        
        // 卡牌背景
        avatar.kf.setImage(with: URL(string: item.portrait), placeholder: PlaceHolderAvatar)
        
        // 卡牌名称
        nameLabel.text = item.nick
        nameLabel.sizeToFit()
    }
}

extension GameUserCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        
        avatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(12)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: HeadWidth, height: HeadWidth))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
    }
}

