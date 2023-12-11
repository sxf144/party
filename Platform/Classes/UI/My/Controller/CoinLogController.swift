//
//  CoinLogController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class CoinLogController: BaseController {
    
    let CellHeight = 72.0
    var dataList: CoinLogModel = CoinLogModel()
    var currentDate: Date = Date()

    override func viewDidLoad() {
        title = "收支记录"
        super.viewDidLoad()
        setupUI()
        
        view.backgroundColor = UIColor.ls_color("#F6F6F6")
        tableView.mj_header?.beginRefreshing()
    }
    
    // 创建顶部View
    fileprivate lazy var topBtn: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(clickDateBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.text = currentDate.ls_formatterStr("yyyy-MM")
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var iconExpand: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = UIImage(named: "icon_expand_black")
        return imageView
    }()
    
    
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
        tableView.register(CoinLogCell.self, forCellReuseIdentifier: "CoinLogCell")
        return tableView
    }()
}

extension CoinLogController {
    
    func getCoinLogs(pageNum:Int64, pageSize:Int64) {
        let monthStr = currentDate.ls_formatterStr("yyyy-MM")
        NetworkManager.shared.getCoinLogs(pageNum, pageSize: pageSize, month: monthStr) { resp in
            LSLog("getCoinLogs data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getCoinLogs succ")
                
                if let data = resp.data {
                    if pageNum == 1 {
                        self.dataList = data
                        self.dataList.pageNum = pageNum
                        self.dataList.pageSize = pageSize
                    } else {
                        self.dataList.items.append(contentsOf: data.items)
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
                LSLog("getCoinLogs fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        self.tableView.mj_footer.resetNoMoreData()
        getCoinLogs(pageNum: 1, pageSize: dataList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (dataList.totalCount > dataList.pageNum * dataList.pageSize) {
            let pn = dataList.pageNum + 1
            getCoinLogs(pageNum: pn, pageSize: dataList.pageSize)
        }
    }
    
    func isEmpty() {
        if dataList.items.count == 0 {
            tableView.ls_showEmpty()
        } else {
            tableView.ls_hideEmpty()
        }
    }
    
    // 选择日期
    @objc func clickDateBtn(_ sender:UIButton) {
        LSLog("clickDateBtn")
        // 设置最小和最大日期
        let maxDate = Date()
        let minDate:Date = Calendar.current.date(byAdding: .year, value: -1, to: currentDate) ?? Date()
        let datePickerController = DatePickerController()
        datePickerController.setDate(currentDate)
        datePickerController.setMinimumDate(minDate)
        datePickerController.setMaximumDate(maxDate)
        
        datePickerController.confirmAction = { date in
            LSLog("confirmAction date:\(date)")
            self.currentDate = date
            self.dateLabel.text = self.currentDate.ls_formatterStr("yyyy-MM")
            self.dateLabel.sizeToFit()
            // 重新拉取数据
            self.loadNewData()
        }
        datePickerController.show()
    }
}

// UITableView 代理
extension CoinLogController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return dataList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CoinLogCell", for: indexPath) as! CoinLogCell
        let item = dataList.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
}

extension CoinLogController {
    fileprivate func setupUI(){
        
        view.addSubview(topBtn)
        topBtn.addSubview(dateLabel)
        topBtn.addSubview(iconExpand)
        view.addSubview(tableView)
        
        topBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(62)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(16)
        }
        
        iconExpand.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(dateLabel.snp.right).offset(2)
            make.size.equalTo(CGSize(width: 16, height: 16))
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.top.equalTo(topBtn.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
