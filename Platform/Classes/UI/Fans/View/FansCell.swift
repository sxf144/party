//
//  FansCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class FansCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16.0
    let avatarHeight: CGFloat = 54
    var item: FansItem = FansItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = avatarHeight/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        return imageView
    }()
    
    // 昵称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 简介
    fileprivate lazy var introLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = " "
        label.sizeToFit()
        return label
    }()
    
    // 选中标识
    fileprivate lazy var accessIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_cell_normal")
        return imageView
    }()
}

extension FansCell {
    
    func configure(with citem: FansItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 头像
        avatar.kf.setImage(with: URL(string: item.portrait), placeholder: PlaceHolderAvatar)
        
        // 昵称
        nameLabel.text = item.nick
        nameLabel.sizeToFit()
        
        // 简介
        introLabel.text = item.intro
        introLabel.sizeToFit()
        
        // 选中状态
        if item.needSelect {
            accessIcon.isHidden = false
            accessIcon.image = UIImage(named: item.selected ? "icon_cell_selected" : "icon_cell_normal")
        } else {
            accessIcon.isHidden = true
        }
        
    }
}

extension FansCell {
    
    fileprivate func setupUI(){
        
        contentView.addSubview(avatar)
        contentView.addSubview(nameLabel)
        contentView.addSubview(introLabel)
        contentView.addSubview(accessIcon)
        
        avatar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: avatarHeight, height: avatarHeight))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.top.equalTo(avatar).offset(5)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        
        introLabel.snp.makeConstraints { (make) in
            make.left.equalTo(avatar.snp.right).offset(10)
            make.top.equalTo(nameLabel.snp.bottom).offset(5)
        }
        
        accessIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
    }
}

