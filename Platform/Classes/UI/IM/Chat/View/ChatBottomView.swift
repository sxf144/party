//
//  ChooseLocationView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class ChatBottomView: UIView {
    
    let xMargin: CGFloat = 16.0
    let inputHeight: CGFloat = 40.0
    var uniqueCode: String = ""
    var userId: String = ""
    var partyDetail: PartyDetailModel?
    
    /// 回调闭包
    public var inputBtnBlock: (() -> ())?
    public var imageBtnBlock: (() -> ())?
    public var redPacketBtnBlock: (() -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate lazy var statusLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer16
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "此群已解散"
        label.sizeToFit()
        label.isHidden = true
        return label
    }()
    
    // inputBtn
    fileprivate lazy var inputBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#F4F4F4")
        button.layer.cornerRadius = inputHeight/2
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickInputBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // imageBtn
    fileprivate lazy var imageBtn: UIButton = {
        let button = UIButton()
        button.layer.cornerRadius = inputHeight/2
        button.clipsToBounds = true
        button.setImage(UIImage(named: "chat_btn_image"), for: .normal)
        button.addTarget(self, action: #selector(clickImageBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var placeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer15
        label.textColor = UIColor.ls_color("#CFCFCF")
        label.text = "请输入聊天内容"
        label.sizeToFit()
        return label
    }()
    
    // gameBtn
    fileprivate lazy var gameBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "chat_btn_game"), for: .normal)
        button.addTarget(self, action: #selector(clickGameBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // redPacketBtn
    fileprivate lazy var redPacketBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "chat_btn_redpacket"), for: .normal)
        button.addTarget(self, action: #selector(clickRedPacketBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // giftBtn
    fileprivate lazy var giftBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "chat_btn_gift"), for: .normal)
        button.addTarget(self, action: #selector(clickGiftBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension ChatBottomView {
    
    public func setUserId(_ userId:String) {
        self.userId = userId
        resetUI()
    }
    
    public func setUniCode(_ uniCode:String) {
        uniqueCode = uniCode
        resetUI()
    }
    
    public func setPartyDetail(_ detail:PartyDetailModel?) {
        partyDetail = detail
        
        //
        resetUI()
    }
    
    public func resetUI() {
        
        if let party = partyDetail {
            // 已经解散或者已经结束
            if party.state == 2 || party.state == 3 {
                statusLabel.isHidden = false
                statusLabel.text = party.state == 2 ? "此群已解散" : "此群已结束"
                statusLabel.sizeToFit()
                
                inputBtn.isHidden = true
                gameBtn.isHidden = true
                redPacketBtn.isHidden = true
                giftBtn.isHidden = true
                return
            } else {
                statusLabel.isHidden = true
                
                inputBtn.isHidden = false
                gameBtn.isHidden = false
                redPacketBtn.isHidden = false
                giftBtn.isHidden = false
            }
        }
        
        // 判断是否群组，群组可以开启游戏，私聊隐藏游戏按钮
        if userId.isEmpty {
            gameBtn.isHidden = false
            
            inputBtn.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(xMargin)
                make.centerY.equalTo(giftBtn)
                make.height.equalTo(inputHeight)
                make.right.equalTo(gameBtn.snp.left).offset(-10)
            }
        } else {
            gameBtn.isHidden = true
            
            inputBtn.snp.remakeConstraints { (make) in
                make.left.equalToSuperview().offset(xMargin)
                make.centerY.equalTo(giftBtn)
                make.height.equalTo(inputHeight)
                make.right.equalTo(redPacketBtn.snp.left).offset(-10)
            }
        }
    }
    
    // 点击输入
    @objc func clickInputBtn(_ sender:UIButton) {
        LSLog("clickInputBtn")
        if let inputBtnBlock = inputBtnBlock {
            inputBtnBlock()
        }
    }
    
    // 点击发送图片
    @objc func clickImageBtn(_ sender:UIButton) {
        LSLog("clickImageBtn")
        if let imageBtnBlock = imageBtnBlock {
            imageBtnBlock()
        }
    }
    
    // 点击游戏按钮
    @objc func clickGameBtn(_ sender:UIButton) {
        LSLog("clickGameBtn")
        // 判断自己是否创建者，只有创建者可以开启游戏
        if uniqueCode.isEmpty {
            // uniqueCode为空，不会到此，容错处理
            return
        }
        
        // 判断创建者是否是自己
        let userInfo = LoginManager.shared.getUserInfo()
        if partyDetail?.userId == userInfo?.userId {
            // 选择游戏类型
            let vc = GameListController()
            vc.setData(false, uniCode: uniqueCode)
            vc.hidesBottomBarWhenPushed = true
            PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
        } else {
            LSHUD.showInfo("只有主持人可以开启游戏")
        }
    }
    
    // 点击红包
    @objc func clickRedPacketBtn(_ sender:UIButton) {
        LSLog("clickRedPacketBtn")
        if let redPacketBtnBlock = redPacketBtnBlock {
            redPacketBtnBlock()
        }
    }
    
    // 点击礼物
    @objc func clickGiftBtn(_ sender:UIButton) {
        LSLog("clickGiftBtn")
        
        GiftView.shared.showInWindow(userId: userId, uniqueCode: uniqueCode)
    }
}

extension ChatBottomView {
    
    fileprivate func setupUI() {
        
        self.addSubview(statusLabel)
        self.addSubview(giftBtn)
        self.addSubview(redPacketBtn)
        self.addSubview(gameBtn)
        self.addSubview(inputBtn)
        inputBtn.addSubview(imageBtn)
        inputBtn.addSubview(placeLabel)
        
        
        statusLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.centerX.equalToSuperview()
        }
        
        giftBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-xMargin)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        redPacketBtn.snp.makeConstraints { (make) in
            make.right.equalTo(giftBtn.snp.left).offset(-8)
            make.centerY.equalTo(giftBtn)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        gameBtn.snp.makeConstraints { (make) in
            make.right.equalTo(redPacketBtn.snp.left).offset(-8)
            make.centerY.equalTo(giftBtn)
            make.size.equalTo(CGSize(width: 28, height: 28))
        }
        
        inputBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.centerY.equalTo(giftBtn)
            make.height.equalTo(inputHeight)
            make.right.equalTo(gameBtn.snp.left).offset(-10)
        }
        
        imageBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalToSuperview()
            make.size.equalTo(CGSize(width: inputHeight, height: inputHeight))
        }
        
        placeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(imageBtn.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
    }
}
