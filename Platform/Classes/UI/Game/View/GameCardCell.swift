//
//  GameCardCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher


class GameCardCell: UICollectionViewCell {
    
    let leftMargin: CGFloat = 16.0
    let normalBg: UIImage = UIImage(named: "card_item_bg")!
    let grayBg: UIImage = UIImage.convertToGrayScale(UIImage(named: "card_item_bg")!)!
    var item: GameCardItem = GameCardItem()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 卡牌背景
    fileprivate lazy var cardBg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.image = grayBg
        return imageView
    }()
    
    // 卡牌名字
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.white
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        return label
    }()
}

extension GameCardCell {
    
    func configure(with citem: GameCardItem) {
        LSLog("configure citem:\(String(describing: citem))")
        
        // 赋值
        item = citem
        
        // 根据字段改变整体状态
        contentView.alpha = item.selected ? 1 : 0.5
        
        // 卡牌背景
        cardBg.kf.setImage(with: URL(string: item.introductionMedia), placeholder: normalBg)
        
        // 卡牌名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
    }
}

extension GameCardCell {
    
    fileprivate func setupUI() {
        
        contentView.addSubview(cardBg)
        contentView.addSubview(nameLabel)
        
        
        cardBg.snp.makeConstraints { (make) in
            make.size.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}

