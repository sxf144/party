//
//  RechargeView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit

// RechargeView 高度
private let CONTENT_HEIGHT: CGFloat = 446

class RechargeView: UIView {
    
    static let shared = RechargeView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    let CollectionSpace: CGFloat = 10
    var dataList: [RechargeItem] = []
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
        // 获取充值商品列表
        getRechargeList()
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
        label.text = "充值"
        label.sizeToFit()
        return label
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
        label.text = "余额：" + String(userPageInfo?.user.coinBalance ?? 0) + " JZ币"
        label.sizeToFit()
        return label
    }()
    
    // 用户协议
    fileprivate lazy var privacyLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        // 创建一个富文本字符串
        let privaceString: String = "《用户充值协议》"
        let attributedText = NSMutableAttributedString(string: "充值即代表同意《用户充值协议》")
        attributedText.addAttributes([.foregroundColor: UIColor.ls_color("#FE9C5B")], range: NSRange(location: attributedText.length - privaceString.count, length: privaceString.count))
        label.attributedText = attributedText
        label.sizeToFit()
        label.isUserInteractionEnabled = true
        let privacyTapGes = UITapGestureRecognizer(target: self, action: #selector(rechargePrivacyDidClick))
        label.addGestureRecognizer(privacyTapGes)
        return label
    }()
    
    /// 充值按钮
    fileprivate lazy var rechargeBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("立即充值1元", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium18
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(clickRechargeBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 充值商品列表
    fileprivate lazy var rechargeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CollectionSpace
        layout.minimumLineSpacing = CollectionSpace
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(RechargeCell.self, forCellWithReuseIdentifier: "RechargeCell")
        return collectionView
    }()
}


extension RechargeView {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPageInfoChange(_:)), name: NotificationName.userPageInfoChange, object: nil)
    }
    
    @objc func handleUserPageInfoChange(_ notification: Notification) {
        userPageInfo = LoginManager.shared.getUserPageInfo()
        // 更新代币值
        coinLabel.text = "余额：" + String(userPageInfo?.user.coinBalance ?? 0) + " JZ币"
        coinLabel.sizeToFit()
    }
    
    // 取消
    @objc fileprivate func cancelDidClick(){
        LSLog("cancelDidClick")
        removeRechargeView()
    }
    
    // 充值协议
    @objc fileprivate func rechargePrivacyDidClick(){
        LSLog("rechargePrivacyDidClick")
        PageManager.shared.presentWebViewController(RechargePrivacy)
    }
    
    // 充值
    @objc fileprivate func clickRechargeBtn(_ sender:UIButton){
        LSLog("clickRechargeBtn")
        
    }
    
    
    
    
//    func sendGift(_ item:GiftItem) {
//
//        let peopleId:String = userId.isEmpty ? self.participateItem.userId : userId
//        if (peopleId.isEmpty) {
//            LSHUD.showInfo("请选择成员")
//            return
//        }
//
//        NetworkManager.shared.sendGift(uniqueCode, peopleId:peopleId, giftId:item.id) { resp in
//            LSLog("sendGift resp:\(String(describing: resp))")
//
//            if resp.status == .success {
//                LSLog("sendGift succ")
//                self.userPageInfo?.user.coinBalance = resp.data.coinBalance
//                if let userPageInfo = self.userPageInfo {
//                    LoginManager.shared.saveUserPageInfo(userPageInfo)
//                }
//
//                self.removeGiftView()
//            } else {
//                LSLog("sendGift fail")
//                LSHUD.showError(resp.msg)
//            }
//        }
//    }
    
    /// 显示 view
    func showInWindow() {
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3) {
            self.contentView.frame = CGRect(x: 0, y: kScreenH - CONTENT_HEIGHT, width: kScreenW, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.6
        }
    }
    
    /// 移除 view
    func removeRechargeView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.2
            UIApplication.shared.sendAction(#selector(self.resignFirstResponder), to: nil, from: nil, for: nil)
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
    
    // 拉取数据
    func getRechargeList() {
        NetworkManager.shared.getRechargeList { resp in
            LSLog("getRechargeList data:\(String(describing: resp.data))")
            
            if resp.status == .success {
                LSLog("getRechargeList succ")
                self.dataList = resp.data.items
                self.rechargeCollectionView.reloadData()
            } else {
                LSLog("getRechargeList fail")
                // 模拟数据
                self.dataList = []
                for i in 0 ..< 10 {
                    var item = RechargeItem()
                    item.id = Int64(i)
                    item.productId = String(i)
                    item.title = String(i)
                    item.coinAmount = Int64(10*i)
                    item.cashAmount = Int64(i)
                    self.dataList.append(item)
                }
                self.rechargeCollectionView.reloadData()
            }
        }
    }
}

extension RechargeView: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "RechargeCell", for: indexPath) as! RechargeCell
        // 配置单元格的内容
        cell.configure(with: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算单元格的大小以适应屏幕宽度并保持4列
        let itemsPerRow: Int = 3
        let itemWidth = (collectionView.frame.width - xMargin*2 - CollectionSpace*CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
        let itemHeight: CGFloat = 68
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        for i in 0 ..< dataList.count {
            dataList[i].selected = indexPath.row == i
        }
        collectionView.reloadData()
    }
}

extension RechargeView {
    
    fileprivate func setupUI() {
        
        addSubview(coverView)
        addSubview(contentView)
        contentView.addSubview(topView)
        topView.addSubview(titleLabel)
        topView.addSubview(coinIV)
        topView.addSubview(coinLabel)
        contentView.addSubview(privacyLabel)
        contentView.addSubview(rechargeBtn)
        contentView.addSubview(rechargeCollectionView)
        
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
        
        coinIV.snp.makeConstraints { (make) in
            make.right.equalTo(coinLabel.snp.left).offset(-10)
            make.centerY.equalToSuperview()
            make.size.equalTo(CGSizeMake(16, 16))
        }
        
        coinLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.centerY.equalToSuperview()
        }
        
        privacyLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-(kSafeAreaHeight + 10))
            make.centerX.equalToSuperview()
        }
        
        rechargeBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(privacyLabel.snp.top).offset(-10)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
        }
        
        rechargeCollectionView.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-xMargin*2)
            make.centerX.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(rechargeBtn.snp.top).offset(-10)
        }
    }
}
