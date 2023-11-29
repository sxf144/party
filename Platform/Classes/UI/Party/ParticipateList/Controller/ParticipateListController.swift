//
//  ParticipateListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class ParticipateListController: BaseController {
    
    var uniqueCode: String = ""
    let CellHeight = 80.0
    var participateList: [SimpleUserInfo] = []
    /// 回调闭包
    public var selectedBlock: ((_ item:SimpleUserInfo) -> ())?

    override func viewDidLoad() {
        title = "选择成员"
        super.viewDidLoad()
        setupUI()
        
        // 设置下拉刷新
        tableView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        
        tableView.mj_header?.beginRefreshing()
    }
    
    override func pop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tv = UITableView(frame: view.bounds, style: .plain)
        tv.dataSource = self
        tv.delegate = self
        tv.contentInsetAdjustmentBehavior = .never
        
        // 注册UITableViewCell类
        tv.register(ParticipateCell.self, forCellReuseIdentifier: "ParticipateCell")
        return tv
    }()
    
}

extension ParticipateListController {
    
    func setData(uniCode: String) {
        uniqueCode = uniCode
    }
    
    func getParticipateList() {
        
        if (uniqueCode.isEmpty) {
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            return
        }
        
        NetworkManager.shared.getParticipateList(uniqueCode) { resp in
            LSLog("getParticipateList data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getParticipateList succ")
                self.participateList = resp.data.participateList
                self.tableView.reloadData()
            } else {
                LSLog("getParticipateList fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getParticipateList()
    }
}

// UITableView 代理
extension ParticipateListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return participateList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ParticipateCell", for: indexPath) as! ParticipateCell
        let item = participateList[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let item = participateList[indexPath.row]
        if let selectedBlock = selectedBlock {
            selectedBlock(item)
            // 返回上一层
            self.dismiss(animated: true, completion: nil)
        }
    }
}


extension ParticipateListController{
    fileprivate func setupUI(){
        
        view.addSubview(tableView)
        
        tableView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }
}
