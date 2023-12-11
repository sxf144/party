//
//  GameDetailController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class GameDetailController: BaseController {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 20.0
    var item: GameItem = GameItem()

    override func viewDidLoad() {
        title = "详情"
        super.viewDidLoad()
        setupUI()
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
        label.font = kFontMedium18
        label.textColor = UIColor.ls_color("#333333")
        label.text = item.name
        label.sizeToFit()
        return label
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
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = item.introduction
        label.sizeToFit()
        return label
    }()
    
    // 游戏介绍
    fileprivate lazy var introductionLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#999999")
        label.text = item.introduction
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
}

extension GameDetailController {
    
    func setData(_ item: GameItem) {
        
        self.item = item
        
        // 游戏封面
        cover.kf.setImage(with: URL(string: item.cover), placeholder: PlaceHolderGameCover)
        
        // 游戏名称
        nameLabel.text = item.name
        nameLabel.sizeToFit()
        
        // 游戏人数
        personCntLabel.text = "\(item.personCountMin)-\(item.personCountMax)"
        personCntLabel.sizeToFit()
        
        // 游戏介绍
        introductionLabel.text = item.introduction
        introductionLabel.sizeToFit()
    }
}

extension GameDetailController {
    
    fileprivate func setupUI() {
        
        view.addSubview(cover)
        view.addSubview(nameLabel)
        view.addSubview(personCntView)
        personCntView.addSubview(personCntLabel)
        view.addSubview(introductionLabel)
        
        cover.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.top.equalToSuperview().offset(kNavBarHeight + yMargin)
            make.size.equalTo(CGSize(width: 120, height: 160))
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(cover)
            make.right.equalToSuperview().offset(-xMargin)
        }
        
        personCntView.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(nameLabel.snp.bottom).offset(8)
            make.width.equalTo(personCntLabel).offset(20)
            make.height.equalTo(24)
        }
        
        personCntLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        introductionLabel.snp.makeConstraints { (make) in
            make.left.equalTo(cover.snp.right).offset(12)
            make.top.equalTo(personCntView.snp.bottom).offset(10)
            make.right.equalToSuperview().offset(-xMargin)
        }
    }
}
