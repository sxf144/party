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

    override func viewDidLoad() {
        view.backgroundColor = .white
        super.viewDidLoad()
        resetNavigation()
        setupUI()
        IMManager.shared.conversationDelegate = self
        
        // 下拉刷新
        loadNewData()
    }
    
    
    // 创建UITableView
    fileprivate lazy var tableView: BaseTableView = {
        let tableView = BaseTableView(frame: view.bounds, style: .plain)
        tableView.backgroundColor = .white
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.estimatedRowHeight = CellHeight
        tableView.rowHeight = UITableView.automaticDimension
        tableView.dataStatus = .loading
        tableView.actionBlock = { [weak self] in
            // 重试
            if tableView.dataStatus == .error {
                tableView.dataStatus = .loading
                self?.loadNewData()
            }
        }
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        // 设置下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        // 注册UITableViewCell类
        tableView.register(ConversationCell.self, forCellReuseIdentifier: "ConversationCell")
        return tableView
    }()
}

extension ConversationListController {

    func loadNewData() {
        IMManager.shared.loadConversationList {
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            self.tableView.reloadData()
            
            // 判断是否展示空页面
            self.changeTableViewStatus()
        }
    }
    
    func changeTableViewStatus() {
        if IMManager.shared.conversationList.count == 0 {
            tableView.dataStatus = .empty
        } else {
            tableView.dataStatus = .none
        }
    }
}


// UITableView 代理
extension ConversationListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, IMConversationDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return IMManager.shared.conversationList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = IMManager.shared.conversationList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell", for: indexPath) as! ConversationCell
        cell.configure(with: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = IMManager.shared.conversationList[indexPath.row]
        PageManager.shared.pushToChatController(item)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return kNavBarHeight
    }
    
    // 启用左滑删除
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // 在这里处理删除操作，更新数据源
            let item = IMManager.shared.conversationList[indexPath.row]
            
            // IM删除会话
            if let convID = item.conversationID {
                V2TIMManager.shared.deleteConversation(conversation: convID) {
                    LSLog("deleteConversation succ conversationID:\(convID)")
                } fail: { code, desc in
                    LSLog("deleteConversation fail")
                }
            }
            
            // 删除当前数据
            IMManager.shared.conversationList.remove(at: indexPath.row)
            // 执行UI
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    func updateConversationComplete(_ data: [LIMConversation]) {
        tableView.reloadData()
    }
}

extension ConversationListController {
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.equalToSuperview()
            make.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-kTabBarHeight)
        }
    }
    
    fileprivate func resetNavigation() {
        navigationView.leftButton.isHidden = true
        navigationView.rightButton.isHidden = true
        navigationView.titleLabel.text = "聊天"
        navigationView.titleLabel.font = UIFont.ls_mediumFont(18)
        navigationView.titleLabel.textColor = UIColor.ls_color("#333333")
        
        navigationView.titleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-9)
        }
    }
}
