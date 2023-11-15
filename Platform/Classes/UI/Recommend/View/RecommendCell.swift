//
//  RecommendCell.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import AVFoundation
import AMapLocationKit

enum CoverType: Int {
    case none = 0
    case image = 1
    case video = 2
}

class RecommendCell: UITableViewCell {
    
    let RightToolWidth = 44.0
    let RightToolHeight = 240.0
    let InfoAreaHeight = 100.0
    var item: RecommendItem?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.backgroundColor = .black
        self.selectionStyle = .none
        setupUI()
        addObservers()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 创建视频播放器并将其添加到videoPlayerView上
    fileprivate lazy var avPlayer: AVPlayer = {
        let player = AVPlayer()
        return player
    }()
    
    fileprivate lazy var avPlayerLayer: AVPlayerLayer = {
        let playerLayer = AVPlayerLayer(player: avPlayer)
        playerLayer.frame = contentView.bounds
        playerLayer.videoGravity = .resizeAspectFill
        return playerLayer
    }()
    
    // 视频封面图
    fileprivate lazy var videoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    // 右侧工具栏区域
    fileprivate lazy var rightToolView: UIView = {
        let rightToolView = UIView()
        return rightToolView
    }()
    
    // 视频作者头像
    fileprivate lazy var avatar: UIButton = {
        let button = UIButton()
        button.contentMode = .scaleAspectFill
        button.clipsToBounds = true
        button.layer.cornerRadius = CGFloat(RightToolWidth/2)
        button.kf.setImage(with: URL(string: ""), for: .normal, placeholder: PlaceHolderAvatar)
        button.addTarget(self, action: #selector(clickAvatarBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 喜欢按钮
    fileprivate lazy var likeBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "icon_like_normal"), for: .normal)
        button.setImage(UIImage(named: "icon_like_selected"), for: .selected)
        button.addTarget(self, action: #selector(clickLikeBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 喜欢label
    fileprivate lazy var likeLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#ffffff")
        label.text = String(item?.likeCnt ?? 0)
        label.sizeToFit()
        return label
    }()
    
    // 评论按钮
    fileprivate lazy var commentBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "icon_comment"), for: .normal)
        button.addTarget(self, action: #selector(clickCommentBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 评论label
    fileprivate lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#ffffff")
        label.text = String(item?.commentCnt ?? 0)
        label.sizeToFit()
        return label
    }()
    
    // 分享按钮
    fileprivate lazy var shareBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.setImage(UIImage(named: "icon_share"), for: .normal)
        button.addTarget(self, action: #selector(clickShareBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 分享label
    fileprivate lazy var shareLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#ffffff")
        label.text = "分享"
        label.sizeToFit()
        return label
    }()
    
    // 底部区域
    fileprivate lazy var infoArea: UIView = {
        let view = UIView()
        return view
    }()
    
    // 视频作者标签
    fileprivate lazy var authorLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_mediumFont(16)
        label.textColor = UIColor.white
        label.sizeToFit()
        return label
    }()
    
    // 视频简介标签
    fileprivate lazy var desLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.ls_font(14)
        label.textColor = UIColor.white
        label.numberOfLines = 2
        label.sizeToFit()
        return label
    }()
    
    // 地址
    fileprivate lazy var addressBtn:UIButton = {
        let button = UIButton()
        button.setTitleColor(UIColor.ls_color("#cecece"), for: .normal)
        button.titleLabel?.font = UIFont.ls_mediumFont(14)
        button.titleLabel?.lineBreakMode = .byTruncatingTail // 设置末尾省略
        button.titleLabel?.numberOfLines = 1 // 设置按钮标题为单行
        button.layer.cornerRadius = 16
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10) //内容设置左右间距
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#000000", alpha: 0.32)
        button.setTitle("电子科技大学 · 13km", for: .normal)
        button.setImage(UIImage(named: "icon_location"), for: .normal)
        button.ls_layout(.imageLeft, padding: 0)
        button.addTarget(self, action: #selector(clickAddressBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension RecommendCell {
    
    func configure(with citem: RecommendItem!) {
        LSLog("configure citem:\(String(describing: citem))")
        item = citem
        
        // 作者昵称
        authorLabel.text = "@" + (item?.nick ?? "")
        authorLabel.sizeToFit()
        
        // 描述
        desLabel.text = item?.introduction
        desLabel.sizeToFit()
        
        // 地址信息
        let point = CLLocation(latitude: item?.latitude ?? 0.00, longitude: item?.longitude ?? 0.00 )
        let disStr = MyLocationManager.shared.calculateDistanceByPoint(point: point)
        
        let regeo = (item?.landmark ?? "") + " · " + disStr
        addressBtn.setTitle(regeo, for: .normal)
        
        // 设置头像
        avatar.kf.setImage(with: URL(string: item?.portrait ?? ""), for: .normal, placeholder: PlaceHolderAvatar)
        
        // coverType 1、图片，2、视频
        if (item?.coverType == CoverType.image.rawValue) {
            videoImageView.kf.setImage(with: URL(string: item?.cover ?? ""))
            avPlayerLayer.isHidden = true
            videoImageView.isHidden = false
        } else if (item?.coverType == CoverType.video.rawValue) {
            avPlayerLayer.isHidden = false
            videoImageView.isHidden = true
            avPlayerLayer.frame = contentView.bounds
            if let videoURL = URL(string: item?.cover ?? "") {
                // 创建AVPlayerItem，加载视频，但此处不播放
                let playerItem = AVPlayerItem(url: videoURL)
                avPlayer.replaceCurrentItem(with: playerItem)
            }
        }
    }
    
    @objc func clickAvatarBtn(_ sender:UIButton) {
        PageManager.shared.pushToUserPage(item?.userId ?? "")
    }
    
    @objc func clickLikeBtn(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        if (sender.isSelected) {
            item?.likeCnt += 1
        } else {
            item?.likeCnt -= 1
        }
        
        if item!.likeCnt < 0 {
            item?.likeCnt = 0
        }
        
        likeLabel.text = String(item!.likeCnt)
        likeLabel.sizeToFit()
    }
    
    @objc func clickCommentBtn(_ sender:UIButton) {
        
    }
    
    @objc func clickShareBtn(_ sender:UIButton) {
        
    }
    
    @objc func clickAddressBtn(_ sender:UIButton) {
        
    }
    
    func activity() {
        if item?.coverType == CoverType.video.rawValue {
            
            // 开始播放
            avPlayer.play()
        }
    }
    
    func inactivity() {
        if item?.coverType == CoverType.video.rawValue {
            // 暂停播放
            avPlayer.pause()
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(playerDidFinishPlaying), name: .AVPlayerItemDidPlayToEndTime, object: avPlayer.currentItem)
    }
    
    @objc func playerDidFinishPlaying() {
        avPlayer.seek(to: CMTime.zero) // 将播放头重置到视频的开始位置
        avPlayer.play() // 重新开始播放
    }
}

extension RecommendCell{
    fileprivate func setupUI(){
        
        contentView.layer.addSublayer(avPlayerLayer)
        contentView.addSubview(videoImageView)
        contentView.addSubview(rightToolView)
        rightToolView.addSubview(avatar)
        rightToolView.addSubview(likeBtn)
        rightToolView.addSubview(likeLabel)
        rightToolView.addSubview(commentBtn)
        rightToolView.addSubview(commentLabel)
        rightToolView.addSubview(shareBtn)
        rightToolView.addSubview(shareLabel)
        contentView.addSubview(infoArea)
        infoArea.addSubview(authorLabel)
        infoArea.addSubview(desLabel)
        infoArea.addSubview(addressBtn)
        
        
        videoImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        rightToolView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-100)
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: RightToolWidth, height: RightToolHeight))
        }
        
        avatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalTo(rightToolView.snp.width)
            make.height.equalTo(rightToolView.snp.width)
        }
        
        likeBtn.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        likeLabel.snp.makeConstraints { (make) in
            make.top.equalTo(likeBtn.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        commentBtn.snp.makeConstraints { (make) in
            make.top.equalTo(likeLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        commentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(commentBtn.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        shareBtn.snp.makeConstraints { (make) in
            make.top.equalTo(commentLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalTo(28)
            make.height.equalTo(28)
        }
        
        shareLabel.snp.makeConstraints { (make) in
            make.top.equalTo(shareBtn.snp.bottom).offset(4)
            make.centerX.equalToSuperview()
        }
        
        infoArea.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview().offset(-64)
            make.height.equalTo(InfoAreaHeight)
        }
        
        authorLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        desLabel.snp.makeConstraints { (make) in
            make.top.equalTo(authorLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        addressBtn.snp.makeConstraints { (make) in
            make.top.equalTo(desLabel.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(10)
            make.height.equalTo(32)
            // 设置按钮宽度约束，使其根据标题内容而变化
            make.trailingMargin.lessThanOrEqualTo(0) // 最小右边距
        }
    }
}

