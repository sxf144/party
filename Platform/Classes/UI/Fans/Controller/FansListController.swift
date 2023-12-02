//
//  FansListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class FansListController: BaseController {
    
    let CellHeight = 80.0
    var fansList: FansListModel = FansListModel()
    /// 回调闭包
    public var followSelectedBlock: ((_ followItems:[FollowItem]) -> ())?
    var needSelect:Bool = false

    override func viewDidLoad() {
        title = "我的粉丝"
        super.viewDidLoad()
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
        tv.register(FansCell.self, forCellReuseIdentifier: "FansCell")
        return tv
    }()
}

extension FansListController {
    
    func getFansList(pageNum:Int64, pageSize:Int64) {
        NetworkManager.shared.getFansList(pageNum, pageSize: pageSize) { resp in
            LSLog("getFansList data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getFansList succ")
                
                if let data = resp.data {
                    if pageNum == 1 {
                        self.fansList = data
                        self.fansList.pageNum = pageNum
                        self.fansList.pageSize = pageSize
                    } else {
                        self.fansList.users.append(contentsOf: data.users)
                        self.fansList.pageNum = pageNum
                        self.fansList.pageTotal = data.pageTotal
                        self.fansList.totalCount = data.totalCount
                    }
                    
                    self.tableView.reloadData()
                    if (self.fansList.totalCount <= self.fansList.pageNum * self.fansList.pageSize) {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                }
            } else {
                LSLog("getFollowList fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        self.tableView.mj_footer.resetNoMoreData()
        getFansList(pageNum: 1, pageSize: fansList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (fansList.totalCount > fansList.pageNum * fansList.pageSize) {
            let pn = fansList.pageNum + 1
            getFansList(pageNum: pn, pageSize: fansList.pageSize)
        }
    }
}

// UITableView 代理
extension FansListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fansList.users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FansCell", for: indexPath) as! FansCell
        var item = fansList.users[indexPath.row]
        item.needSelect = needSelect
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = fansList.users[indexPath.row]
        PageManager.shared.pushToUserPage(item.userId )
    }
}


extension FansListController {
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
