//
//  GameEndMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class GameEndMessageCell: UITableViewCell {
    
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
    
    
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#cfcfcf")
        label.text = "游戏已结束"
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
}

extension GameEndMessageCell {
    
    func configure(_ citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
    }
}

extension GameEndMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(messageLabel)
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.bottom.equalToSuperview().offset(-yMargin)
            make.left.greaterThanOrEqualToSuperview().offset(xMargin)
            make.right.lessThanOrEqualToSuperview().offset(-xMargin)
            make.centerX.equalToSuperview()
        }
    }
}

