//
//  CashOutLogController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class CashOutLogController: BaseController {
    
    let CellHeight = 72.0
    var dataList: CashOutLogModel = CashOutLogModel()

    override func viewDidLoad() {
        title = "提现历史"
        super.viewDidLoad()
        setupUI()
        
        view.backgroundColor = UIColor.ls_color("#F6F6F6")
        tableView.mj_header?.beginRefreshing()
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .singleLine
        tableView.backgroundColor = UIColor.ls_color("#F6F6F6")
        
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
        
        // 注册UITableViewCell类
        tableView.register(CashOutLogCell.self, forCellReuseIdentifier: "CashOutLogCell")
        return tableView
    }()
}

extension CashOutLogController {
    
    func getCashOutLogs(pageNum:Int64, pageSize:Int64) {
        
        NetworkManager.shared.getCashOutLogs(pageNum, pageSize: pageSize) { resp in
            LSLog("getCoinLogs data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getCashOutLogs succ")
                
                if let data = resp.data {
                    if pageNum == 1 {
                        self.dataList = data
                        self.dataList.pageNum = pageNum
                        self.dataList.pageSize = pageSize
                    } else {
                        self.dataList.logs.append(contentsOf: data.logs)
                        self.dataList.pageNum = pageNum
                        self.dataList.pageTotal = data.pageTotal
                        self.dataList.totalCount = data.totalCount
                    }
                    
                    self.tableView.reloadData()
                    if (self.dataList.totalCount <= self.dataList.pageNum * self.dataList.pageSize) {
                        self.tableView.mj_footer.endRefreshingWithNoMoreData()
                    }
                    
                    // 判断是否展示空页面
                    self.isEmpty()
                }
            } else {
                LSLog("getCashOutLogs fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        self.tableView.mj_footer.resetNoMoreData()
        getCashOutLogs(pageNum: 1, pageSize: dataList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (dataList.totalCount > dataList.pageNum * dataList.pageSize) {
            let pn = dataList.pageNum + 1
            getCashOutLogs(pageNum: pn, pageSize: dataList.pageSize)
        }
    }
    
    func isEmpty() {
        if dataList.logs.count == 0 {
            tableView.ls_showEmpty()
            tableView.mj_footer.isHidden = true
        } else {
            tableView.ls_hideEmpty()
            tableView.mj_footer.isHidden = false
        }
    }
}

// UITableView 代理
extension CashOutLogController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.logs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CashOutLogCell", for: indexPath) as! CashOutLogCell
        let item = dataList.logs[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
}

extension CashOutLogController {
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        
        tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
