//
//  MyPartyController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class MyPartyController: BaseController {
    
    let CellHeight = 140.0
    var partyList: MyPartyModel = MyPartyModel()

    override func viewDidLoad() {
        showNavifationBar = false
        slideBackEnabled = false
        view.backgroundColor = UIColor.ls_color("#F8F8F8")
        
        super.viewDidLoad()
        setupUI()
        addObservers()
        
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
        tableView.register(MyPartyCell.self, forCellReuseIdentifier: "MyPartyCell")
        tableView.register(MyHistoryPartyCell.self, forCellReuseIdentifier: "MyHistoryPartyCell")
        return tableView
    }()
}

extension MyPartyController {
    
    func getMyParty(pageNum:Int64, pageSize:Int64) {
        NetworkManager.shared.getMyPlay(pageNum, pageSize: pageSize) { resp in
            LSLog("getMyParty data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getMyParty succ")
                if pageNum == 1 {
                    self.partyList = resp.data
                    self.partyList.pageNum = pageNum
                    self.partyList.pageSize = pageSize
                } else {
                    self.partyList.plays.append(contentsOf: resp.data.plays)
                    self.partyList.pageNum = pageNum
                    self.partyList.pageTotal = resp.data.pageTotal
                    self.partyList.totalCount = resp.data.totalCount
                }
                
                self.handleData()
                self.tableView.reloadData()
                if (self.partyList.totalCount <= self.partyList.pageNum * self.partyList.pageSize) {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            } else {
                LSLog("getMyParty fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        self.tableView.mj_footer.resetNoMoreData()
        getMyParty(pageNum: 1, pageSize: partyList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (partyList.totalCount > partyList.pageNum * partyList.pageSize) {
            let pn = partyList.pageNum + 1
            getMyParty(pageNum: pn, pageSize: partyList.pageSize)
        }
    }
    
    func handleData() {
        let len = partyList.plays.count
        for i in 0 ..< len {
            var item  = partyList.plays[i]
            if (item.state == 2 || item.state == 3) {
                item.firstInvalid = true
                partyList.plays[i] = item
                break
            }
        }
        
        LSLog("partyList.plays:\(partyList.plays)")
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handlePartyStatusChange(_:)), name: NotificationName.partyStatusChange, object: nil)
    }
    
    @objc func handlePartyStatusChange(_ notification: Notification) {
        LSLog("---- MyPartyController handlePartyStatusChange ----")
        loadNewData()
    }
}

// UITableView 代理
extension MyPartyController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return partyList.plays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = partyList.plays[indexPath.row]
        var finalCell:UITableViewCell!
        if item.firstInvalid {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyHistoryPartyCell", for: indexPath) as! MyHistoryPartyCell
            cell.configure(with: item)
            finalCell = cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyPartyCell", for: indexPath) as! MyPartyCell
            cell.configure(with: item)
            finalCell = cell
        }
        
        return finalCell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = partyList.plays[indexPath.row]
        // 跳转到局详情
        PageManager.shared.pushToPartyDetail(item.uniqueCode)
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
        titleLabel.text = "我的桔"
        titleLabel.font = UIFont.ls_mediumFont(18)
        titleLabel.textColor = UIColor.ls_color("#333333")
        headerView.addSubview(titleLabel)
        return headerView
    }
}


extension MyPartyController{
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
