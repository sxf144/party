//
//  CardTaskView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import AVFoundation

class CardTaskView: UIView {
    
    static let shared = CardTaskView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    /// 回调闭包
    public var cardTaskBlock: (() -> ())?
    let CardImageDefault: UIImage = UIImage(named: "card_item_bg")!
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    var limMsg: LIMMessage?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        // 移除所有状态观察者
        avPlayer.currentItem?.removeObserver(self, forKeyPath: "status")
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
    
    // 标题
    fileprivate lazy var titleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "task_title")
        return imageView
    }()
    
    // 内容区域
    fileprivate lazy var cardContentView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        return view
    }()
    
    // 卡牌背景图
    fileprivate lazy var cardContentBg: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = CardImageDefault
        return imageView
    }()
    
    // 卡牌名字
    fileprivate lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = UIColor.white
        label.text = ""
        label.sizeToFit()
        label.numberOfLines = 4
        label.lineBreakMode = .byWordWrapping
        label.ls_shadow()
        return label
    }()
    
    // 媒体资源
    fileprivate lazy var mediaView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(mediaViewClicked))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    // 卡牌图片
    fileprivate lazy var cardImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 创建视频播放器并将其添加到videoPlayerView上
    fileprivate lazy var avPlayer: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    fileprivate lazy var avPlayerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = mediaView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    fileprivate lazy var activityView: UIActivityIndicatorView = {
        let view = UIActivityIndicatorView(style: .medium)
        view.color = .gray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // 播放按钮
    fileprivate lazy var playBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "icon_play"), for: .normal)
        button.layer.cornerRadius = 27
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickPlayBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 红包按钮
    fileprivate lazy var redPacketBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE5B5B")
        button.setTitle("发红包逃避此任务", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickRedPacketBtn(_:)), for: .touchUpInside)
        return button
    }()
}


extension CardTaskView {
    
    // 发红包逃避任务
    @objc fileprivate func clickRedPacketBtn(_ sender:UIButton) {
        LSLog("clickRedPacketBtn")
        if let cardTaskBlock = cardTaskBlock {
            cardTaskBlock()
            removeTaskView()
        }
    }
    
    // 播放/暂停
    @objc fileprivate func clickPlayBtn(_ sender:UIButton) {
        playOrPause()
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeTaskView()
    }
    
    // 媒体资源被惦记
    @objc fileprivate func mediaViewClicked(){
        LSLog("mediaViewClicked")
        if let limMsg = limMsg, limMsg.gameElem?.action.cardInfo.introductionMediaType == 2 {
            playOrPause()
        }
    }
    
    func playOrPause() {
        // 检查播放状态
        if avPlayer.rate > 0 && avPlayer.error == nil {
            // 正在播放，停止
            avPlayer.pause()
            playBtn.isHidden = false
        } else {
            // 没有播放，播放
            avPlayer.play()
            playBtn.isHidden = true
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerDidFinishPlaying() {
        // 将播放头重置到视频的开始位置，不播放，展示播放按钮
        avPlayer.seek(to: CMTime.zero)
        playBtn.isHidden = false
    }
    
    /// 显示 view
    func showInWindow(_ limMsg:LIMMessage) {
        
        // 赋值
        self.limMsg = limMsg
        
        // 是自己抽到，才展示发红包逃避按钮
        if limMsg.isSelf ?? false {
            // 判断任务已经完成过，不展示发红包逃避按钮
            if limMsg.gameElem?.status == 1 {
                redPacketBtn.isHidden = true
            } else {
                redPacketBtn.isHidden = false
            }
        } else {
            redPacketBtn.isHidden = true
        }
        
        // 先移除老的监听，有时会移除没有添加过监听的，导致crash，先去掉
//        if let playerItem = avPlayer.currentItem {
//            playerItem.removeObserver(self, forKeyPath: "status")
//        }
        
        // 判断是否有媒体资源
        if let mediaUrl = limMsg.gameElem?.action.cardInfo.introductionMedia, !mediaUrl.isEmpty {
            
            mediaView.isHidden = false
            
            nameLabel.snp.remakeConstraints { (make) in
                make.width.lessThanOrEqualToSuperview().offset(-xMargin*2)
                make.centerX.equalToSuperview()
                make.centerY.equalTo(41)
            }
            
            // introductionMediaType 1图片，2视频
            if limMsg.gameElem?.action.cardInfo.introductionMediaType == 1 {
                cardImageView.isHidden = false
                avPlayerLayer.isHidden = true
                activityView.isHidden = true
                playBtn.isHidden = true
                // 卡牌图片
                cardImageView.kf.setImage(with: URL(string: mediaUrl))
            } else if limMsg.gameElem?.action.cardInfo.introductionMediaType == 2 {
                cardImageView.isHidden = true
                avPlayerLayer.isHidden = false
                activityView.isHidden = false
                // 播放按钮先隐藏，视频已准备好播放时再显示
                playBtn.isHidden = true
                // 卡牌视频
                // 加入 layoutIfNeeded以确保mediaView.bounds不为0
                self.layoutIfNeeded()
                avPlayerLayer.frame = mediaView.bounds
                if let videoURL = URL(string: mediaUrl) {
                    // 创建AVPlayerItem，加载视频，但此处不播放
                    let playerItem = AVPlayerItem(url: videoURL)
                    avPlayer.replaceCurrentItem(with: playerItem)
                    if let playerItem = avPlayer.currentItem {
                        activityView.startAnimating()
                        // 添加新的观察者
                        playerItem.addObserver(self, forKeyPath: "status", options: .new, context: nil)
                    }
                }
            }
            
        } else {
            //
            mediaView.isHidden = true
            
            nameLabel.snp.remakeConstraints { (make) in
                make.width.lessThanOrEqualToSuperview().offset(-xMargin*2)
                make.center.equalToSuperview()
            }
        }
        
        // 卡牌名称
        nameLabel.text = limMsg.gameElem?.action.cardInfo.name
        nameLabel.sizeToFit()
        
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
        avPlayer.pause()
        UIView.animate(withDuration: 0.3, animations: {
            self.bgView.alpha = 0.0
            self.contentView.alpha = 0.0
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    // 观察者回调
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "status" {
            if let playerItem = object as? AVPlayerItem {
                activityView.stopAnimating()
                if playerItem.status == .readyToPlay {
                    // 视频已准备好播放
                    LSLog("视频已准备好播放")
                    playBtn.isHidden = false
                } else if playerItem.status == .failed {
                    // 播放失败
                    LSLog("播放失败")
                } else if playerItem.status == .unknown {
                    // 未知状态
                    LSLog("未知状态")
                }
            }
        }
    }
}

extension CardTaskView {
    
    fileprivate func setupUI() {
        
        addSubview(bgView)
        addSubview(contentView)
        contentView.addSubview(titleImageView)
        contentView.addSubview(cardContentView)
        cardContentView.addSubview(cardContentBg)
        cardContentView.addSubview(nameLabel)
        cardContentView.addSubview(mediaView)
        mediaView.addSubview(cardImageView)
        mediaView.layer.addSublayer(avPlayerLayer)
        mediaView.addSubview(activityView)
        mediaView.addSubview(playBtn)
        contentView.addSubview(redPacketBtn)
        
        bgView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        titleImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(84)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 138, height: 26))
        }
        
        cardContentView.snp.makeConstraints { (make) in
            make.top.equalTo(titleImageView.snp.bottom).offset(36)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 318, height: 538))
        }
        
        cardContentBg.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.width.lessThanOrEqualToSuperview().offset(-xMargin*2)
            make.center.equalToSuperview()
        }
        
        mediaView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalToSuperview().offset(-82)
            make.bottom.equalToSuperview()
        }
        
        activityView.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
        
        cardImageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        playBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 54, height: 54))
        }
        
        redPacketBtn.snp.makeConstraints { (make) in
            make.top.equalTo(cardImageView.snp.bottom).offset(40)
            make.centerX.equalToSuperview()
            make.size.equalTo(CGSize(width: 260, height: 46))
        }
    }
}
