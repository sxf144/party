//
//  GameStoryMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class GameStoryMessageCell: UITableViewCell {
    
    let xMargin: CGFloat = 16.0
    let yMargin: CGFloat = 10.0
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
    
    fileprivate lazy var titleBg: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.ls_color("#FE9C5B", alpha: 0.24)
        return view
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = ""
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#A1826E")
        label.text = ""
        label.textAlignment = .left
        label.sizeToFit()
        return label
    }()
}

extension GameStoryMessageCell {
    
    func configure(with citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 标题
        titleLabel.text = item.gameElem?.action.roundInfo.title
        titleLabel.sizeToFit()
        
        // 消息内容
        messageLabel.text = item.gameElem?.action.roundInfo.introduction
        messageLabel.sizeToFit()
    }
}

extension GameStoryMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(titleBg)
        titleBg.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        
        titleBg.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.height.equalTo(36)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleBg.snp.bottom).offset(xMargin)
            make.bottom.equalToSuperview().offset(-yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
        }
    }
}

