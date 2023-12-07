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
    
    override func viewDidLoad() {
        showNavifationBar = false
        slideBackEnabled = false
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        // 初始化controllers
        setupControllers()
        
        // 添加监听
        addObservers()
        
        // checkToken
//        LoginManager.shared.login()
        LoginManager.shared.refreshToken()
        // 加载数据
        loadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        segmentedView.frame = CGRect(x: 0, y: 44, width: view.bounds.size.width, height: 50)
        listContainerView.frame = CGRect(x: 0, y: 0, width: view.bounds.size.width, height: view.bounds.size.height - kTabBarHeight)
    }
}

extension HomeController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin(_:)), name: NotificationName.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: NotificationName.logoutSuccess, object: nil)
    }
    
    @objc func handleLogin(_ notification: Notification) {
        // 登录成功，重新加载数据
        loadData()
    }
    
    @objc func handleLogout(_ notification: Notification) {
        // 退出登录
    }
    
    func loadData() {
        // 拉取自己的个人主页信息，主要为了获取代币信息
        LoginManager.shared.getUserPage()
        // 刷新会话信息，获取未读数
        IMManager.shared.loadConversationList {
            
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
            return RecommendController()
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
}


