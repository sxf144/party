//
//  RechargeView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import StoreKit

// RechargeView 高度
private let CONTENT_HEIGHT: CGFloat = 446

class RechargeView: UIView {
    
    static let shared = RechargeView(frame: CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH))
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 16
    let CollectionSpace: CGFloat = 10
    var selectedIndex = 0
    var dataList: [RechargeItem] = []
    var userPageInfo: UserPageModel? = LoginManager.shared.getUserPageInfo()
    var dataLoaded: Bool = false
    var orderId: String = ""
    
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
        LSLog("RechargeView didMoveToWindow")
        
        if SKPaymentQueue.canMakePayments() {
            if !dataLoaded {
                // 获取充值商品列表
                getRechargeList()
            }
        } else {
            // 用户禁用了应用内购买
            LSHUD.showInfo("请打开应用内购权限")
        }
    }
    
    // 在视图销毁时移除观察者
    deinit {
        SKPaymentQueue.default().remove(self)
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
        label.text = String(format: "余额：%.2f JZ币", Double((userPageInfo?.user.coinBalance ?? 0))/100)
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
        LSLog("addObservers")
        NotificationCenter.default.addObserver(self, selector: #selector(handleUserPageInfoChange(_:)), name: NotificationName.userPageInfoChange, object: nil)
        // 设置观察者以监听购买事务
        SKPaymentQueue.default().add(self)
    }
    
    @objc func handleUserPageInfoChange(_ notification: Notification) {
        userPageInfo = LoginManager.shared.getUserPageInfo()
        // 更新代币值
        coinLabel.text = String(format: "余额：%.2f JZ币", Double((userPageInfo?.user.coinBalance ?? 0))/100)
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
        
        if selectedIndex >= 0, selectedIndex < dataList.count {
            LSHUD.showLoading()
            // 重置orderId
            self.orderId = ""
            let item = dataList[selectedIndex]
            // 先创建订单
            NetworkManager.shared.createOrder(item.id) { resp in
                LSLog("createOrder data:\(resp.data)")
                if resp.status == .success {
                    LSLog("createOrder succ")
                    self.orderId = resp.data.orderId
                    // 启动购买
                    let payment = SKPayment(product: item.product)
                    SKPaymentQueue.default().add(payment)
                } else {
                    LSHUD.hide()
                    LSHUD.showInfo(resp.msg)
                    LSLog("createOrder fail")
                }
            }
        }
    }
    
    /// 显示 view
    func showInWindow() {
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        UIView.animate(withDuration: 0.3, animations: {
            self.contentView.frame = CGRect(x: 0, y: kScreenH - CONTENT_HEIGHT, width: kScreenW, height: CONTENT_HEIGHT)
            self.coverView.alpha = 0.6
        }) { (suc) in
            LSLog("checkForUnfinishedTransactions")
            // 检查未完成的交易
            self.checkForUnfinishedTransactions()
        }
    }
    
    /// 移除 view
    func removeRechargeView() {
        LSHUD.hide()
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
        LSHUD.showLoading()
        NetworkManager.shared.getRechargeList { resp in
            LSLog("getRechargeList data:\(resp.data)")
            if resp.status == .success {
                LSLog("getRechargeList succ")
                self.requestProductInfo(resp.data.items)
            } else {
                LSHUD.hide()
                LSLog("getRechargeList fail")
            }
        }
    }
    
    // 获取内购商品列表
    func requestProductInfo(_ list:[RechargeItem]) {
        
        self.dataList = list
        
        var productIdentifiers: Set<String> = []
        for i in 0 ..< self.dataList.count {
            let item = self.dataList[i]
            productIdentifiers.insert(item.productId)
        }
        
        if productIdentifiers.count > 0 {
            let productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers)
            productsRequest.delegate = self
            productsRequest.start()
        }
    }
    
    func refreshSelected() {
        
        for i in 0 ..< dataList.count {
            dataList[i].selected = selectedIndex == i
        }
        
        rechargeCollectionView.reloadData()
        
        if selectedIndex >= 0, selectedIndex < dataList.count {
            let confirmBtnTitle: String = "立即充值\(dataList[selectedIndex].product.price)元"
            rechargeBtn.setTitle(confirmBtnTitle, for: .normal)
        }
    }
}

extension RechargeView: SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        LSLog("------ paymentQueue updatedTransactions ------")
        for transaction in transactions {
            
            switch transaction.transactionState {
            case .purchased:
                // 购买成功
                completeTransaction(transaction: transaction)
            case .failed:
                // 购买失败
                failTransaction(transaction: transaction)
            case .restored:
                // 恢复购买
                restoreTransaction(transaction: transaction)
            case .deferred:
                // 交易延迟
                LSLog("交易延迟")
            case .purchasing:
                // 正在购买
                LSLog("正在购买")
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            }
        }
    }
    
    func paymentQueue(_ queue: SKPaymentQueue, shouldAddStorePayment payment: SKPayment, for product: SKProduct) -> Bool {
        return true
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        
        if response.products.count > 0 {
            dataLoaded = true
            for product in response.products {
//                print("Product ID: \(product.productIdentifier)")
//                print("Product Title: \(product.localizedTitle)")
//                print("Product Description: \(product.localizedDescription)")
//                print("Product Price: \(product.price)")
                
                for i in 0 ..< dataList.count {
                    if dataList[i].productId == product.productIdentifier {
                        dataList[i].product = product
                        break
                    }
                }
            }
            
        } else {
            LSLog("No products found.")
        }
        
        if self.dataList.count >= 2 {
            selectedIndex = 1
        }
        
        DispatchQueue.main.async {
            LSHUD.hide()
            self.refreshSelected()
        }
    }
    
    // 处理购买成功的交易
    func completeTransaction(transaction: SKPaymentTransaction) {
        // 处理购买成功的逻辑
        // 比如：解锁功能，提供内容等
        SKPaymentQueue.default().finishTransaction(transaction)
        // 通知服务端
        payNotify(transaction)
    }

    // 处理购买失败的交易
    func failTransaction(transaction: SKPaymentTransaction) {
        LSHUD.hide()
        if let error = transaction.error as? SKError {
            if error.code == .paymentCancelled {
                // 用户取消购买
                LSLog("用户取消购买")
            } else {
                // 非用户取消的购买失败
                LSLog("购买失败: \(error.localizedDescription), code:\(error.code)")
            }
        }
        SKPaymentQueue.default().finishTransaction(transaction)
    }

    // 处理恢复购买的交易
    func restoreTransaction(transaction: SKPaymentTransaction) {
        // 处理恢复购买的逻辑
        LSLog("恢复购买")
        LSHUD.hide()
        SKPaymentQueue.default().finishTransaction(transaction)
    }
    
    // 检查是否有未完成的订单
    func checkForUnfinishedTransactions() {
        for transaction in SKPaymentQueue.default().transactions {
            switch transaction.transactionState {
            case .purchased, .failed, .restored:
                // 处理已完成的交易
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            case .deferred, .purchasing:
                // 存在未完成的交易
                LSLog("存在未完成的交易")
                SKPaymentQueue.default().finishTransaction(transaction)
            @unknown default:
                SKPaymentQueue.default().finishTransaction(transaction)
                break
            }
        }
    }
    
    // 支付成功通知后端
    func payNotify(_ transaction: SKPaymentTransaction) {
        let item = dataList[selectedIndex]
        let fee: Int64 = Int64(Int(truncating: item.product.price)*100)
        if let receiptURL = Bundle.main.appStoreReceiptURL, let receiptData = try? Data(contentsOf: receiptURL) {
            // receiptData 包含了票据信息，可以使用它进行验证
            let receiptString = receiptData.base64EncodedString(options: [])
            let orderId = orderId
            let transactionId = transaction.transactionIdentifier ?? ""
            let originalTransactionId = transaction.original?.transactionIdentifier ?? ""
            
            if !receiptString.isEmpty, !transactionId.isEmpty {
                NetworkManager.shared.payNotify(orderId, transactionId: transactionId, originalTransactionId: originalTransactionId, receiptData: receiptString, totalFee: fee) { resp in
                    LSHUD.hide()
                    if resp.status == .success {
                        LSLog("payNotify succ")
                        LSLog("购买成功")
                        // 支付成功，刷新个人信息
                        LoginManager.shared.getUserPage()
                    } else {
                        LSLog("payNotify fail")
                        LSHUD.showError(resp.msg)
                        // 检查订单结果
                    }
                }
            } else {
                // 参数问题
            }
        } else {
            // 票据获取失败
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
        selectedIndex = indexPath.row
        
        // 刷新状态
        refreshSelected()
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
