//
//  ReportReasonListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class ReportReasonListController: BaseController {
    
    let CellHeight = 56.0
    let leftMargin = 16.0
    var dataList: ReportReasonListModel = ReportReasonListModel()
    var selectedIndex: Int = -1
    /// 回调闭包
    public var reasonConfirmBlock: ((_ reasonItem:ReportReasonItem) -> ())?

    override func viewDidLoad() {
        title = "举报"
        super.viewDidLoad()
        setupUI()
        
        // 加载数据
        loadNewData()
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: BaseTableView = {
        let tableView = BaseTableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.dataStatus = .loading
        tableView.actionBlock = { [weak self] in
            // 重试
            if tableView.dataStatus == .error {
                tableView.dataStatus = .loading
                self?.loadNewData()
            }
        }
        // 设置下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        // 注册UITableViewCell类
        tableView.register(ReportReasonItemCell.self, forCellReuseIdentifier: "ReportReasonItemCell")
        return tableView
    }()
    
    // 确认按钮
    fileprivate lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.setTitle("确认", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.addTarget(self, action: #selector(clickConfirmBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension ReportReasonListController {
    
    func getReasonList() {
        
        NetworkManager.shared.getReportReasonList() { resp in
            LSLog("getReportReasonList data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getReportReasonList succ")
                
                self.dataList = resp.data
                
                self.tableView.reloadData()
                
                // 判断是否展示空页面
                self.changeTableViewStatus()
                
            } else {
                LSLog("getReportReasonList fail")
                self.tableView.dataStatus = .error
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getReasonList()
    }
    
    func changeTableViewStatus() {
        if dataList.reasonList.count == 0 {
            tableView.dataStatus = .empty
        } else {
            tableView.dataStatus = .none
        }
    }
    
    // 点击确认
    @objc func clickConfirmBtn(_ sender:UIButton) {
        LSLog("clickConfirmBtn")
        if (selectedIndex < 0 || selectedIndex >= dataList.reasonList.count) {
            LSHUD.showInfo("请选择举报理由")
            return
        }
        
        let item =  dataList.reasonList[selectedIndex]
        if let reasonConfirmBlock = reasonConfirmBlock {
            reasonConfirmBlock(item)
            // 返回上一层
            pop()
        }
    }
}

// UITableView 代理
extension ReportReasonListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.reasonList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReportReasonItemCell", for: indexPath) as! ReportReasonItemCell
        let item = dataList.reasonList[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        selectedIndex = indexPath.row
        for i in 0 ..< dataList.reasonList.count {
            dataList.reasonList[i].selected = i == selectedIndex
        }
        tableView.reloadData()
    }
}

extension ReportReasonListController {
    
    fileprivate func setupUI() {
        
        view.addSubview(confirmBtn)
        view.addSubview(tableView)
        
        confirmBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-kSafeAreaHeight)
            make.left.equalToSuperview().offset(leftMargin)
            make.right.equalToSuperview().offset(-leftMargin)
            make.height.equalTo(46)
        }

        tableView.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(confirmBtn.snp.top).offset(-10)
        }
    }
}
