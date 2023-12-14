//
//  StoryTaskView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

class StoryTaskView: UIView {
    
    static let shared = StoryTaskView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    /// 回调闭包
    public var storyTaskBlock: ((_ limMsg:LIMMessage) -> ())?
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    var limMsg: LIMMessage?
    var timer: Timer?
    var counter = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    /// 背景
    fileprivate lazy var bgView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.0
        view.backgroundColor = .black
        return view
    }()
    
    /// 主体
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.0
        view.backgroundColor = .clear
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelDidClick))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    // 封面图
    fileprivate lazy var cover: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_boldFont(28)
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        label.ls_shadow()
        return label
    }()
    
    // 内容
    fileprivate lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = .white
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.ls_shadow()
        return label
    }()
    
    // 主持人操作按钮，下一关
    fileprivate lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("下一关", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickNextBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 非主持人提示
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = .white
        label.text = "等待主持人操作..."
        label.sizeToFit()
        return label
    }()
}


extension StoryTaskView {
    
    // 下一关
    @objc fileprivate func clickNextBtn(_ sender:UIButton) {
        LSLog("clickNextBtn")
        
        if let storyTaskBlock = storyTaskBlock, let limMsg = limMsg {
            storyTaskBlock(limMsg)
            removeTaskView()
        }
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeTaskView()
    }
    
    func startTimer() {
        stopTimer()
        // 创建计时器，每秒触发一次
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateCounter), userInfo: nil, repeats: true)
    }
    
    // 如果需要停止计时器，可以在适当的时候调用下面的方法
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        counter = 0
    }
    
    @objc func updateCounter() {
        // 更新计数器
        counter += 1
        print("Counter: \(counter)")

        // 关闭本界面
        if counter >= self.limMsg?.gameElem?.action.roundInfo.showSeconds ?? 0 {
            stopTimer()
            removeTaskView()
        }
    }
    
    /// 显示 view
    func showInWindow(_ limMsg:LIMMessage) {
        
        // 赋值
        self.limMsg = limMsg
        
        // 封面
        cover.kf.setImage(with: URL(string: limMsg.gameElem?.action.roundInfo.introductionMedia ?? ""))
        
        // 标题
        titleLabel.text = limMsg.gameElem?.action.roundInfo.title
        titleLabel.sizeToFit()
        
        // 内容
        contentLabel.text = limMsg.gameElem?.action.roundInfo.introduction
        contentLabel.sizeToFit()
        
        // 是否展示下一关按钮，展示时间为0，需要主持人确认，时间不为零，等待系统下发后续的消息
        if limMsg.gameElem?.action.roundInfo.showSeconds == 0 {
            // 判断主持人是否自己
            let userInfo = LoginManager.shared.getUserInfo()
            if limMsg.gameElem?.adminUserId == userInfo?.userId {
                // 状态为1，已经完成过的任务，无需再提示
                if limMsg.gameElem?.status == 1 {
                    nextBtn.isHidden = true
                } else {
                    nextBtn.isHidden = false
                }
                tipLabel.isHidden = true
            } else {
                if limMsg.gameElem?.status == 1 {
                    tipLabel.isHidden = true
                } else {
                    tipLabel.isHidden = false
                }
                nextBtn.isHidden = true
            }
        } else {
            nextBtn.isHidden = true
            tipLabel.isHidden = true
            startTimer()
        }
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.bgView.alpha = 0.6
            self.contentView.alpha = 1.0
        }
        
        // 创建一个震动反馈生成器
        let generator = UIImpactFeedbackGenerator(style: .heavy)
        generator.impactOccurred()
    }
    
    /// 移除 view
    func removeTaskView() {
        stopTimer()
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.alpha = 0.0
            self.contentView.alpha = 0.0
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
}


extension StoryTaskView {
    
    fileprivate func setupUI() {
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(cover)
        contentView.addSubview(titleLabel)
        contentView.addSubview(contentLabel)
        contentView.addSubview(nextBtn)
        contentView.addSubview(tipLabel)
        
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        cover.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
        }
        
        contentLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.top.equalToSuperview().offset(kNavBarHeight+80)
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 260, height: 46))
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.centerX.equalToSuperview()
        }
    }
}
