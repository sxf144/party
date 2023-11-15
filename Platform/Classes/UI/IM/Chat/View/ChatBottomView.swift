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
    let yMargin: CGFloat = 10.0
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
        resetGameBtn()
    }
    
    public func setUniCode(_ uniCode:String) {
        uniqueCode = uniCode
        resetGameBtn()
    }
    
    public func setPartyDetail(_ detail:PartyDetailModel?) {
        partyDetail = detail
    }
    
    public func resetGameBtn() {
        // 判断是否群组，群组可以开启游戏，私聊隐藏游戏按钮
        if userId.isEmpty {
            gameBtn.isHidden = false
        } else {
            gameBtn.isHidden = true
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
        
        self.addSubview(inputBtn)
        inputBtn.addSubview(imageBtn)
        inputBtn.addSubview(placeLabel)
        self.addSubview(gameBtn)
        self.addSubview(redPacketBtn)
        self.addSubview(giftBtn)
        
        inputBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.top.equalToSuperview().offset(yMargin)
            make.height.equalTo(inputHeight)
            make.width.equalTo(230)
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
        
        gameBtn.snp.makeConstraints { (make) in
            make.left.equalTo(inputBtn.snp.right).offset(10)
            make.centerY.equalTo(inputBtn)
        }
        
        redPacketBtn.snp.makeConstraints { (make) in
            make.left.equalTo(gameBtn.snp.right).offset(8)
            make.centerY.equalTo(inputBtn)
        }
        
        giftBtn.snp.makeConstraints { (make) in
            make.left.equalTo(redPacketBtn.snp.right).offset(8)
            make.centerY.equalTo(inputBtn)
        }
    }
}
