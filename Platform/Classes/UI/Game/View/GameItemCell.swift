//
//  GameItemCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation


class GameItemCell: UITableViewCell {
    
    let leftMargin: CGFloat = 16.0
    var item: GameItem = GameItem()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 游戏封面
    fileprivate lazy var cover: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderGameCover)
        return imageView
    }()
    
    // 游戏名称
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#333333")
        label.text = item.name
        label.sizeToFit()
        return label
    }()
    
    // 选中标识
    fileprivate lazy var accessIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_cell_selected")
        imageView.isHidden = false
        return imageView
    }()
    
    // 游戏人数
    fileprivate lazy var personCntView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#FE9C5B", alpha: 0.2)
        view.layer.cornerRadius = 8
        return view
    }()
    
    fileprivate lazy var personCntLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = item.introduction
        label.sizeToFit()
        return label
    }()
    
    // 游戏介绍
    fileprivate lazy var introductionLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#999999")
        label.text = item.introduction
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
}

extension GameItemCell {
    
    func configure(with citem: GameItem) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        backgroundColor = item.selected ? UIColor.ls_color("#FE9C5B", alpha: 0.08) : UIColor.white
        
        // 游戏封面
        cover.kf.setImage(with: URL(string: item.cover), placeholder: PlaceHolderGameCover)
        
        // 游戏名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
        
        // 游戏人数
        personCntLabel.text = "\(item.personCountMin)-\(item.personCountMax)人"
        personCntLabel.sizeToFit()
        
        // 游戏介绍
        introductionLabel.text = item.introduction
        introductionLabel.sizeToFit()
        
        // 选中标识
        accessIcon.isHidden = !item.selected
    }
}

extension GameItemCell{
    fileprivate func setupUI(){
        
        contentView.addSubview(cover)
        contentView.addSubview(nameLabel)
        contentView.addSubview(accessIcon)
        contentView.addSubview(personCntView)
        personCntView.addSubview(personCntLabel)
        contentView.addSubview(introductionLabel)
        
        cover.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(leftMargin)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSize(width: 75, height: 100))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(cover)
            make.right.equalToSuperview().offset(-leftMargin)
        }
        
        accessIcon.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-leftMargin)
            make.centerY.equalTo(nameLabel)
            make.size.equalTo(CGSize(width: 20, height: 20))
        }
        
        personCntView.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.width.equalTo(personCntLabel).offset(20)
            make.height.equalTo(20)
        }
        
        personCntLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        introductionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(personCntView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-leftMargin)
        }
    }
}

