//
//  HomeController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import JXSegmentedView

class HomeController: BaseController {
    
    var segmentedDataSource: JXSegmentedTitleDataSource?
    let segmentedView = JXSegmentedView()
    lazy var listContainerView: JXSegmentedListContainerView! = {
        return JXSegmentedListContainerView(dataSource: self)
    }()
    var currCity: CityItem? = CityDataManager.shared.getCurrCity()
    let recommendController: RecommendController = RecommendController()
    
    override func viewDidLoad() {
        showNavifationBar = false
        slideBackEnabled = false
        super.viewDidLoad()
        
        // 初始化controllers
        setupControllers()
        setupUI()
        
        // 添加监听
        addObservers()
        
        // 刷新token
        LoginManager.shared.refreshToken()
        // 加载数据
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        segmentedView.frame = CGRect(x: view.bounds.size.width/4, y: 44, width: view.bounds.size.width/2, height: 50)
        listContainerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - kTabBarHeight)
    }
    
    // 城市选择
    fileprivate lazy var cityBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clickCityBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var cityLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium18
        label.textColor = .white
        label.text = currCity?.name
        label.ls_shadow()
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var cityExpandIcon: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = UIImage(named: "icon_expand_city")
        return imageView
    }()
}

extension HomeController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin(_:)), name: NotificationName.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: NotificationName.logoutSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationDidUpdate(_:)), name: NotificationName.locationDidUpdate, object: nil)
    }
    
    @objc func handleLogin(_ notification: Notification) {
        // 登录成功，重新加载数据
        loadData()
    }
    
    @objc func handleLogout(_ notification: Notification) {
        // 退出登录
    }
    
    @objc func handleLocationDidUpdate(_ notification: Notification) {
        // 定位城市发生变化，如果之前currCity不存在，则拉取数据
        if currCity == nil {
            refreshCity()
        }
    }
    
    func loadData() {
        // 拉取自己的个人主页信息，主要为了获取代币信息
        LoginManager.shared.getUserPage()
        // 刷新会话信息，获取未读数
        IMManager.shared.loadConversationList {
            
        }
        // 获取城市信息
        CityDataManager.shared.getCityList()
        // 检查更新
        UpdateManager.checkForUpdate()
    }
    
    // 点击选择城市
    @objc func clickCityBtn(_ sender: UIButton) {
        LSLog("clickCityBtn")
        let vc = CitySelectController()
        vc.selectBlock = { [weak self] cityItem in
            // 保存新的当前城市
            CityDataManager.shared.saveCurrCity(cityItem)
            self?.refreshCity()
        }
        PageManager.shared.currentNav()?.pushViewController(vc, animated: true)
    }
    
    func refreshCity() {
        currCity = CityDataManager.shared.getCurrCity()
        if let currCity = currCity {
            cityLabel.text = currCity.name
            cityLabel.sizeToFit()
            recommendController.loadNewData()
        }
    }
}

extension HomeController: JXSegmentedViewDelegate {
    func segmentedView(_ segmentedView: JXSegmentedView, canClickItemAt index: Int) -> Bool {
        LSLog("canClickItemAt index:\(index)")
        return true
    }
}

extension HomeController: JXSegmentedListContainerViewDataSource {
    
    func numberOfLists(in listContainerView: JXSegmentedListContainerView) -> Int {
        return segmentedDataSource?.titles.count ?? 0
    }
    
    func listContainerView(_ listContainerView: JXSegmentedListContainerView, initListAt index: Int) -> JXSegmentedListContainerViewListDelegate {
        
        switch index {
        case 0:
            return recommendController
        case 1:
            return FollowedController()
        default:
            return RecommendController()
        }
    }
}

extension HomeController {
    
    func setupControllers() {
        //segmentedDataSource一定要通过属性强持有，不然会被释放掉
        segmentedDataSource = JXSegmentedTitleDataSource()
        //配置数据源相关配置属性
        segmentedDataSource?.titles = ["推荐", "关注"]
        segmentedDataSource?.isTitleColorGradientEnabled = true
        segmentedDataSource?.titleNormalFont = UIFont.ls_font(16)
        segmentedDataSource?.titleSelectedFont = UIFont.ls_boldFont(16)
        segmentedDataSource?.titleNormalColor = UIColor.ls_color("#ffffff", alpha: 0.8)
        segmentedDataSource?.titleSelectedColor = UIColor.ls_color("#ffffff", alpha: 1)
        
        // listContainerView 先添加，以确保segmentedView在 listContainerView 之上
        segmentedView.listContainer = listContainerView
        view.addSubview(listContainerView)
        
        segmentedView.dataSource = segmentedDataSource
        segmentedView.delegate = self
        view.addSubview(segmentedView)

        let indicator = JXSegmentedIndicatorLineView()
        indicator.indicatorWidth = 20
        indicator.indicatorColor = UIColor.ls_color("#ffffff")
        segmentedView.indicators = [indicator]
    }
    
    fileprivate func setupUI() {
        view.addSubview(cityBtn)
        cityBtn.addSubview(cityLabel)
        cityBtn.addSubview(cityExpandIcon)
        
        cityBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(segmentedView)
            make.left.equalToSuperview().offset(16)
            make.height.equalTo(segmentedView)
        }
        
        cityLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview()
        }
        
        cityExpandIcon.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(cityLabel.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 12, height: 12))
            make.right.equalToSuperview()
        }
    }
}


