//
//  FollowedController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import JXSegmentedView

class FollowedController: BaseController {
    
    var recommendData: RecommendModel = RecommendModel()
    var lastIndexPath: IndexPath?
    var lastActiveCell: RecommendCell?

    override func viewDidLoad() {
        self.slideBackEnabled = false
        self.showNavifationBar = false
        title = "推荐"
        
        super.viewDidLoad()
        setupUI()
        // 添加监听
        addObservers()
        
        // 拉取列表信息
        getFollowed()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LSLog("FollowedController viewDidDisappear")
        super.viewDidDisappear(animated)
        // 停止当前cell 播放
        let visiableIndexPaths = tableView.visibleCells
        for cell in tableView.visibleCells {
            let recommendCell = cell as! RecommendCell
            recommendCell.inactivity()
        }
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.isPagingEnabled = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .black
        
        // 注册UITableViewCell类
        tableView.register(RecommendCell.self, forCellReuseIdentifier: "RecommendCell")
        return tableView
    }()
    
}

extension FollowedController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin(_:)), name: NotificationName.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: NotificationName.logoutSuccess, object: nil)
    }
    
    @objc func handleLogin(_ notification: Notification) {
        // 登录成功，重新拉取列表信息
        getFollowed()
    }
    
    @objc func handleLogout(_ notification: Notification) {
        // 退出登录
    }
    
    func getFollowed() {
        let pageSize:Int64 = 10
        NetworkManager.shared.followed(pageSize) { resp in
            LSLog("getFollowed data:\(String(describing: resp.data))")
            if resp.status == .success {
                LSLog("getFollowed succ")
                self.recommendData = resp.data
                
                self.tableView.reloadData()
                DispatchQueue.main.async {
                    // 在这里执行reloadData完成后的操作
                    // 例如，你可以更新UI或执行其他任务
                    self.handleCurrentCell()
                }
                
                // 判断是否展示空页面
                self.isEmpty()
                
            } else {
                LSLog("getFollowed fail")
            }
        }
    }
    
    func handleCurrentCell() {
        if let visibleIndexPaths = tableView.indexPathsForVisibleRows {
            for indexPath in visibleIndexPaths {
                // 在这里处理可见单元格的索引路径，例如：
                print("可见的单元格索引：\(indexPath.row)")
                if (indexPath != lastIndexPath) {
                    if let tempCell = lastActiveCell {
                        tempCell.inactivity()
                    }
                    
                    if let currCell = tableView.cellForRow(at: indexPath) as? RecommendCell {
                        currCell.activity()
                        
                        lastIndexPath = indexPath
                        lastActiveCell = currCell
                    }
                }
            }
        }
    }
    
    func isEmpty() {
        if recommendData.items?.count == 0 {
            tableView.ls_showEmpty()
        } else {
            tableView.ls_hideEmpty()
        }
    }
}

// 配合父view实现横向滚动的容器代理
extension FollowedController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

// UITableView 代理
extension FollowedController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recommendData.items?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecommendCell", for: indexPath) as! RecommendCell
        let item = recommendData.items?[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.frame.size.height // 使每个单元格充满父view
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        LSLog("scrollViewDidEndDecelerating ...")
        handleCurrentCell()
    }
}


extension FollowedController {
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
}
