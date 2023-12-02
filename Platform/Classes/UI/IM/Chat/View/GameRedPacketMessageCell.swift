//
//  GameRedPacketMessageCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import ImSDK_Plus_Swift

class GameRedPacketMessageCell: UITableViewCell {
    
    /// 回调闭包
    public var actionBlock: (() -> ())?
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
    
    // 消息内容
    fileprivate lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#cfcfcf")
        label.text = ""
        label.textAlignment = .center
        label.sizeToFit()
        return label
    }()
    
    // 操作按钮
    fileprivate lazy var actionBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.setTitle("发红包", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontRegualer14
        button.addTarget(self, action: #selector(clickActionBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension GameRedPacketMessageCell {
    
    func configure(_ citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 消息内容
        messageLabel.text = "请\"" + (item.nickName ?? "") + "\"发红包"
        messageLabel.sizeToFit()
        
        // 需要自己发红包
        let userInfo = LoginManager.shared.getUserInfo()
        if let teamUserIds = item.gameElem?.action.teamUserIds, let userId = userInfo?.userId {
            if (teamUserIds.contains(userId)) {
                // 判断任务是否已完成
                if item.gameElem?.status == 1 {
                    actionBtn.isHidden = true
                } else {
                    actionBtn.isHidden = false
                }
            } else {
                actionBtn.isHidden = true
            }
        } else {
            actionBtn.isHidden = true
        }
        
        
        if actionBtn.isHidden {
            // 先重置actionBtn的约束，为先取消底部跟superview的约束，否则约束要报错
            actionBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.size.equalTo(CGSize(width: 180, height: 32))
                make.centerX.equalToSuperview()
            }
            
            messageLabel.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(yMargin)
                make.left.greaterThanOrEqualToSuperview().offset(xMargin)
                make.right.lessThanOrEqualToSuperview().offset(-xMargin)
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-yMargin)
            }
            
        } else {
            // 先重置messageLabel的约束，为先取消底部跟superview的约束，否则约束要报错
            messageLabel.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(yMargin)
                make.left.greaterThanOrEqualToSuperview().offset(xMargin)
                make.right.lessThanOrEqualToSuperview().offset(-xMargin)
                make.centerX.equalToSuperview()
            }
            
            actionBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.size.equalTo(CGSize(width: 180, height: 32))
                make.centerX.equalToSuperview()
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
    }
    
    // 点击操作
    @objc func clickActionBtn(_ sender:UIButton) {
        LSLog("clickActionBtn")
        if let actionBlock = actionBlock {
            actionBlock()
        }
    }
}

extension GameRedPacketMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(messageLabel)
        contentView.addSubview(actionBtn)
        
        messageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.left.greaterThanOrEqualToSuperview().offset(xMargin)
            make.right.lessThanOrEqualToSuperview().offset(-xMargin)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        actionBtn.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.size.equalTo(CGSize(width: 180, height: 32))
            make.centerX.equalToSuperview()
        }
    }
}

