//
//  ConversationListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh
import ImSDK_Plus_Swift

class ConversationListController: BaseController, V2TIMSDKListener {
    
    let CellHeight = 80.0
    var dataList: [LIMConversation] = []

    override func viewDidLoad() {
        showNavifationBar = false
        slideBackEnabled = false
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        
        super.viewDidLoad()
        setupUI()
        addObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // 设置下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        tableView.mj_header?.beginRefreshing()
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = UIColor.ls_color("#F8F8F8")
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = CellHeight
        tableView.rowHeight = UITableView.automaticDimension
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        // 注册UITableViewCell类
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        return tableView
    }()
    
}

extension ConversationListController {
    
    func addObservers() {
        V2TIMManager.shared.addIMSDKListener(listener: self)
        V2TIMManager.shared.addConversationListener(listener: self)
        V2TIMManager.shared.addGroupListener(listener: self)
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        V2TIMManager.shared.getConversationList(nextSeq: 0, count: INT_MAX) { list, nextSeq, isFinished in
            // 获取成功，list 为会话列表
            self.updateConversation(convList: list)
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.reloadData()
        } fail: { code, desc in
            // 获取失败
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
        }
    }
    
    func filterDataList() {
        // 过滤掉管理员会话ID
        dataList = dataList.filter { object in
            return object.conversationID != AdminConvId
        }
    }
    
    func sortDataList() {
        
//        dataList.sort { (item1, item2) -> Bool in
//            if let firstSortKey = item1.originConversation?.orderKey, let secondSortKey = item2.originConversation?.orderKey {
//                return firstSortKey < secondSortKey
//            }
//            return false // 如果无法解析sortKey，则假定它们相等
//        }
        
        // 目前按照时间排序
        dataList.sort { (item1, item2) -> Bool in
            if let firstTime = item1.lastMessage.timestamp, let secondTime = item2.lastMessage.timestamp {
                return firstTime > secondTime
            }
            return false // 如果无法解析timestamp，则假定它们相等
        }
    }
    
    func updateConversation(convList:[V2TIMConversation]){
        
        // 更新 UI 会话列表，如果 UI 会话列表有新增的会话，就替换，如果没有，就新增
        for i in 0 ..< convList.count {
            let conv:V2TIMConversation = convList[i];
            LSLog("convId:\(conv.conversationID)")
            var isExit = false;
            for j in 0 ..< dataList.count {
                let localConv:LIMConversation = dataList[j]
                if (localConv.conversationID == conv.conversationID) {
                    // 转换对象
                    dataList[j] = LIMModel.TIMConvToLIMConv(conv)
                    isExit = true
                    break;
                }
            }
            if (!isExit) {
                // 转换对象
                let limConv:LIMConversation = LIMModel.TIMConvToLIMConv(conv)
                dataList.append(limConv)
            }
        }
        
        // UI 会话列表根据 会话id，过滤管理员信息，用来push专用，不展示
        filterDataList()
        
        // UI 会话列表根据 orderKey 重新排序，目前没使用到
        sortDataList()
    }
}

// MARK: - V2TIMConversationListener, V2TIMGroupListener
extension ConversationListController: V2TIMConversationListener, V2TIMGroupListener {
    
    func onNewConversation(conversationList: Array<V2TIMConversation>) {
        updateConversation(convList: conversationList)
    }
    
    func onConversationChanged(conversationList: Array<V2TIMConversation>) {
        updateConversation(convList: conversationList)
    }
    
    func onGroupInfoChanged(groupID: String, changeInfoList: Array<V2TIMGroupChangeInfo>) {
        if (groupID.isEmpty) {
            return;
        }
        let conversationID:String = "group_\(groupID)"
        var tempItem:LIMConversation? = nil;
        for item in dataList {
            if (item.conversationID == conversationID) {
                tempItem = item;
                break;
            }
        }
        
        if (tempItem == nil) {
            return;
        }
        
        V2TIMManager.shared.getConversation(conversationID: conversationID) { conv in
            self.updateConversation(convList: [conv])
        } fail: { code, desc in
            
        }
    }
}


// UITableView 代理
extension ConversationListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = dataList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.configure(with: item)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = dataList[indexPath.row]
        PageManager.shared.pushToChatController(item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kNavBarHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: kNavBarHeight))
        headerView.backgroundColor = UIColor.ls_color("#F8F8F8")
        let titleLabel = UILabel(frame: CGRect(x: 16, y: kStatusBarHeight + 10, width: headerView.frame.width, height: 24))
        titleLabel.text = "聊天"
        titleLabel.font = UIFont.ls_mediumFont(18)
        titleLabel.textColor = UIColor.ls_color("#333333")
        headerView.addSubview(titleLabel)
        return headerView
    }
}

extension ConversationListController{
    fileprivate func setupUI(){
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kTabBarHeight)
        }
    }
}
