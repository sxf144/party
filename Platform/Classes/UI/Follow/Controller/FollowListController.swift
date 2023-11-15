//
//  FollowListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class FollowListController: BaseController {
    
    let CellHeight = 80.0
    var followList: FollowListModel = FollowListModel()
    /// 回调闭包
    public var followSelectedBlock: ((_ followItems:[FollowItem]) -> ())?

    override func viewDidLoad() {
        title = "邀请好友"
        super.viewDidLoad()
        resetNavigation()
        setupUI()
        
        // 设置下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        // 设置上拉加载更多
        tableView.mj_footer = MJRefreshAutoNormalFooter(refreshingBlock: { [weak self] in
            // 在这里执行上拉加载更多的操作，例如加载更多数据
            self?.loadMoreData()
        })
        
        tableView.mj_header?.beginRefreshing()
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.contentInsetAdjustmentBehavior = .never
        
        // 注册UITableViewCell类
        tv.register(FollowCell.self, forCellReuseIdentifier: "FollowCell")
        return tv
    }()
    
}

extension FollowListController {
    
    func getFollowList(pageNum:Int64, pageSize:Int64) {
        NetworkManager.shared.getFollowList(pageNum, pageSize: pageSize) { resp in
            LSLog("getFollowList data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getFollowList succ")
                self.followList = resp.data
                self.tableView.reloadData()
                if (self.followList.totalCount <= self.followList.pageNum * self.followList.pageSize) {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            } else {
                LSLog("getFollowList fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getFollowList(pageNum: 1, pageSize: followList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (followList.totalCount > followList.pageNum * followList.pageSize) {
            let pn = followList.pageNum + 1
            getFollowList(pageNum: pn, pageSize: followList.pageSize)
        }
    }
    
    func resetSelectedNum() {
        var selectedNum = 0
        for item in  followList.users {
            if item.selected {
                selectedNum += 1
            }
        }
        
        navigationView.rightButton.setTitle("完成（\(selectedNum)）", for: .normal)
    }
    
    override func rightAction() {
        if let followSelectedBlock = followSelectedBlock {
            var seletedItems: [FollowItem] = []
            for item in  followList.users {
                if item.selected {
                    seletedItems.append(item)
                }
            }
            
            followSelectedBlock(seletedItems)
        }
        
        pop()
    }
}

// UITableView 代理
extension FollowListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followList.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FollowCell", for: indexPath) as! FollowCell
        let item = followList.users[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = followList.users[indexPath.row]
        followList.users[indexPath.row].selected = !item.selected
        resetSelectedNum()
        tableView.reloadRows(at: [indexPath], with: .fade)
    }
}


extension FollowListController{
    fileprivate func setupUI(){
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
    
    fileprivate func resetNavigation() {
        
        navigationView.rightButton.setImage(nil, for: .normal)
        navigationView.rightButton.setTitle("完成（0）", for: .normal)
        navigationView.rightButton.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
        navigationView.rightButton.titleLabel?.font = UIFont.ls_mediumFont(16)
        
        navigationView.rightButton.snp.updateConstraints { (make) in
            make.right.equalTo(-16)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(56)
            make.height.equalTo(44)
        }
    }
}
