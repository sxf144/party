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
    
    /// 回调闭包
    public var gameStoryConfirmBlock: (() -> ())?
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
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.sizeToFit()
        return label
    }()
    
    // 主持人确认按钮
    fileprivate lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("下一关", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.layer.cornerRadius = 16
        button.clipsToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(clickConfirmBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension GameStoryMessageCell {
    
    func configure(_ citem: LIMMessage) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 标题
        titleLabel.text = item.gameElem?.action.roundInfo.title
        titleLabel.sizeToFit()
        
        // 消息内容
        messageLabel.text = item.gameElem?.action.roundInfo.introduction
        messageLabel.sizeToFit()
        
        // 是否展示确认按钮
        if item.gameElem?.action.roundInfo.showSeconds == 0 {
            // 判断主持人是否自己
            let userInfo = LoginManager.shared.getUserInfo()
            if item.gameElem?.adminUserId == userInfo?.userId {
                // 展示时间为0，需要主持人确认，时间不为零，等待系统下发后续的消息
                if item.gameElem?.status == 1 {
                    confirmBtn.isHidden = true
                } else {
                    confirmBtn.isHidden = false
                }
            } else {
                confirmBtn.isHidden = true
            }
        } else {
            confirmBtn.isHidden = true
        }
        
        if confirmBtn.isHidden {
            
            // 先重置confirmBtn的约束，为先取消底部跟superview的约束，否则约束要报错
            confirmBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 114, height: 32))
            }
            
            messageLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(titleBg.snp.bottom).offset(xMargin)
                make.left.equalToSuperview().offset(xMargin)
                make.right.equalToSuperview().offset(-xMargin)
                make.bottom.equalToSuperview().offset(-yMargin)
            }
            
        } else {
            
            // 先重置messageLabel的约束，为先取消底部跟superview的约束，否则约束要报错
            messageLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(titleBg.snp.bottom).offset(xMargin)
                make.left.equalToSuperview().offset(xMargin)
                make.right.equalToSuperview().offset(-xMargin)
            }
            
            confirmBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(messageLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.size.equalTo(CGSize(width: 114, height: 32))
                make.bottom.equalToSuperview().offset(-yMargin)
            }
        }
    }
    
    // 主持人确认
    @objc func clickConfirmBtn(_ sender:UIButton) {
        LSLog("clickConfirmBtn")
        if let gameStoryConfirmBlock = gameStoryConfirmBlock {
            gameStoryConfirmBlock()
        }
    }
}

extension GameStoryMessageCell{
    
    fileprivate func setupUI(){
        
        contentView.addSubview(titleBg)
        titleBg.addSubview(titleLabel)
        contentView.addSubview(messageLabel)
        contentView.addSubview(confirmBtn)
        
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
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.bottom.equalToSuperview().offset(-yMargin)
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 114, height: 32))
        }
    }
}

