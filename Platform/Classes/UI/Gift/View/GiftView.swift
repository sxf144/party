//
//  GiftView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

// GiftView高度
private let CONTENT_HEIGHT: CGFloat = 310

class GiftView: UIView {
    
    static let shared = GiftView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    var userId: String = ""
    var uniqueCode: String = ""
    var participateItem: SimpleUserInfo = SimpleUserInfo()
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    let HeadWidth: CGFloat = 26
    var dataList: [GiftItem] = []
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func didMoveToWindow() {
        super.didMoveToWindow()
        // 无论本地是否有数据，都去刷新一次，保证代币数据最新
        LoginManager.shared.getUserPage()
        getGiftList()
    }
    
    /// 遮幕
    fileprivate lazy var coverView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height))
        view.alpha = 0.2
        view.backgroundColor = UIColor.darkGray
        let tapGes = UITapGestureRecognizer(target: self, action: #selector(cancelDidClick))
        view.addGestureRecognizer(tapGes)
        return view
    }()
    
    /// 主体view
    fileprivate lazy var contentView: UIView = {
        let view = UIView(frame: CGRect(x: 0, y: kScreenH, width: kScreenW, height: CONTENT_HEIGHT))
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 14
        view.clipsToBounds = true
        return view
    }()
    
    /// 顶部view
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        return view
    }()
    
    /// 标题
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = UIColor.ls_color("#333333")
        label.text = "送礼物"
        label.sizeToFit()
        return label
    }()
    
    // 选择成员按钮
    fileprivate lazy var selectBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickSelectBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 用户头像
    fileprivate lazy var avatar: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = HeadWidth/2
        imageView.kf.setImage(with: URL(string: ""), placeholder: PlaceHolderAvatar)
        imageView.isHidden = true
        return imageView
    }()
    
    // 选择成员
    fileprivate lazy var userLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "选择成员"
        label.sizeToFit()
        return label
    }()
    
    // arrow
    fileprivate lazy var topArrow: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_arrow_right")
        return imageView
    }()
    
    /// 底部view
    fileprivate lazy var bottomBtn: UIButton = {
        let button = UIButton()
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickBottomBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 桔子币图标
    fileprivate lazy var coinIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_coin")
        return imageView
    }()
    
    // 当前代币
    fileprivate lazy var coinLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = String(userPageInfo?.user.coinBalance ?? 0) + " JZ币"
        label.sizeToFit()
        return label
    }()
    
    // 充值提示
    fileprivate lazy var payTipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium12
        label.textColor = UIColor.ls_color("#FE9C5B")
        label.text = "充值 >"
        label.sizeToFit()
        return label
    }()
    
    /// 礼物列表
    fileprivate lazy var giftCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 10
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(GiftCell.self, forCellWithReuseIdentifier: "GiftCell")
        return collectionView
    }()
}


extension GiftView {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPageInfoChange(_:)), name: NotificationName.userPageInfoChange, object: nil)
    }
    
    @objc func handleUserPageInfoChange(_ notification: Notification) {
        userPageInfo = LoginManager.shared.getUserPageInfo()
        // 更新代币值
        coinLabel.text = String(userPageInfo?.user.coinBalance ?? 0) + " JZ币"
        coinLabel.sizeToFit()
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeGiftView()
    }
    
    // 点击选择成员
    @objc fileprivate func clickSelectBtn(_ sender:UIButton) {
        LSLog("clickSelectBtn")
        // 选择游戏类型
        let vc = ParticipateListController()
        vc.setData(uniCode: uniqueCode)
        vc.selectedBlock = { item in
            LSLog("selectedBlock item:\(item)")
            self.participateItem = item
            // 刷新成员UI
            self.handleSelectBtn()
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentVC()?.present(vc, animated: true)
    }
    
    // 点击充值
    @objc fileprivate func clickBottomBtn(_ sender:UIButton) {
        LSLog("clickBottomBtn")
        // 拉起充值view
        RechargeView.shared.showInWindow()
    }
    
    fileprivate func handleSelectBtn() {
        if (participateItem.userId.isEmpty) {
            // 用户头像
            avatar.isHidden = true
            
            // 用户昵称
            userLabel.font = kFontRegualer12
            userLabel.textColor = UIColor.ls_color("#aaaaaa")
            userLabel.text = "选择成员"
            userLabel.sizeToFit()
        } else {
            // 用户头像
            avatar.isHidden = false
            avatar.kf.setImage(with: URL(string: participateItem.portrait), placeholder: PlaceHolderAvatar)
            
            // 用户昵称
            userLabel.font = kFontMedium12
            userLabel.textColor = UIColor.ls_color("#333333")
            userLabel.text = participateItem.nick
            userLabel.sizeToFit()
        }
    }
    
    func sendGift(_ item:GiftItem) {
        
        let peopleId:String = userId.isEmpty ? self.participateItem.userId : userId
        if (peopleId.isEmpty) {
            LSHUD.showInfo("请选择成员")
            return
        }
        
        NetworkManager.shared.sendGift(uniqueCode, peopleId:peopleId, giftId:item.id) { resp in
            LSLog("sendGift resp:\(String(describing: resp))")
            
            if resp.status == .success {
                LSLog("sendGift succ")
                self.userPageInfo?.user.coinBalance = resp.data.coinBalance
                if let userPageInfo = self.userPageInfo {
                    LoginManager.shared.saveUserPageInfo(userPageInfo)
                }
                
                self.removeGiftView()
            } else {
                LSLog("sendGift fail")
                LSHUD.showError(resp.msg)
            }
        }
    }
    
    /// 显示 view
    func showInWindow(userId:String, uniqueCode:String) {
        
        self.userId = userId
        self.uniqueCode = uniqueCode
        
        // 选择成员，根据 uniqueCode而判断
        selectBtn.isHidden = self.uniqueCode.isEmpty
        
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: 0, y: kScreenH - CONTENT_HEIGHT, width: kScreenW, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.6
        }
    }
    
    /// 移除 view
    func removeGiftView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    // 拉取数据
    func getGiftList() {
        NetworkManager.shared.getGiftList { resp in
            LSLog("getGiftList data:\(String(describing: resp.data))")
            
            if resp.status == .success {
                LSLog("getGiftList succ")
                self.dataList = resp.data.items
                self.giftCollectionView.reloadData()
            } else {
                LSLog("getGiftList fail")
            }
        }
    }
}

extension GiftView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GiftCell", for: indexPath) as! GiftCell
        // 配置单元格的内容
        cell.configure(with: item)
        cell.sendBlock = { sendItem in
            LSLog("sendBlock item:\(sendItem)")
            // 发送礼物
            self.sendGift(sendItem)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算单元格的大小以适应屏幕宽度并保持4列
        let itemsPerRow: Int = 4
        let itemWidth = (collectionView.frame.width) / CGFloat(itemsPerRow)
        let itemHeight: CGFloat = 167
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0 ..< dataList.count {
            dataList[i].selected = indexPath.row == i
        }
        collectionView.reloadData()
    }
}

extension GiftView {
    
    fileprivate func setupUI() {
        
        addSubview(coverView)
        addSubview(contentView)
        contentView.addSubview(topView)
        topView.addSubview(titleLabel)
        topView.addSubview(selectBtn)
        selectBtn.addSubview(avatar)
        selectBtn.addSubview(userLabel)
        selectBtn.addSubview(topArrow)
        contentView.addSubview(bottomBtn)
        bottomBtn.addSubview(coinIV)
        bottomBtn.addSubview(coinLabel)
        bottomBtn.addSubview(payTipLabel)
        contentView.addSubview(giftCollectionView)
        
        topView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.top.equalToSuperview().offset(yMargin)
            make.height.equalTo(30)
        }
        
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(6)
            make.top.equalToSuperview().offset(2)
        }
        
        selectBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.height.equalToSuperview()
            make.width.equalToSuperview().dividedBy(2)
        }
        
        avatar.snp.makeConstraints { (make) in
            make.right.equalTo(userLabel.snp.left).offset(-6)
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: HeadWidth, height: HeadWidth))
        }
        
        userLabel.snp.makeConstraints { (make) in
            make.right.equalTo(topArrow.snp.left).offset(-6)
            make.centerY.equalTo(titleLabel)
        }
        
        topArrow.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalTo(titleLabel)
            make.size.equalTo(CGSize(width: 12, height: 12))
        }
        
        bottomBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(xMargin)
            make.width.equalToSuperview().dividedBy(2)
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.height.equalTo(20)
        }
        
        coinIV.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(16, 16))
        }
        
        coinLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinIV.snp.right).offset(10)
            make.centerY.equalToSuperview()
        }
        
        payTipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(coinLabel.snp.right).offset(5)
            make.centerY.equalToSuperview()
        }
        
        giftCollectionView.snp.makeConstraints { (make) in
            make.width.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomBtn.snp.top).offset(-2)
        }
    }
}
