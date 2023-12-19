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
    public var selectedBlock: ((_ items:[SimpleUserInfo]) -> ())?
    var mutiSelect:Bool = false

    override func viewDidLoad() {
        title = "选择成员"
        super.viewDidLoad()
        resetNavigation()
        setupUI()
        
        // 拉取数据
        loadNewData()
    }
    
    override func pop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: BaseTableView = {
        let tableView = BaseTableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
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
        tableView.register(ParticipateCell.self, forCellReuseIdentifier: "ParticipateCell")
        return tableView
    }()
    
}

extension ParticipateListController {
    
    func setData(_ uniCode: String, mutiSelect:Bool) {
        uniqueCode = uniCode
        self.mutiSelect = mutiSelect
        
        // 重置导航栏
        resetNavigation()
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
                self.handleData(resp.data.participateList)
                self.tableView.reloadData()
                
                // 判断是否展示空页面
                self.changeTableViewStatus()
            } else {
                LSLog("getParticipateList fail")
                self.tableView.dataStatus = .error
            }
        }
    }
    
    // 处理数据
    func handleData(_ list:[SimpleUserInfo]) {
        self.participateList = []
        let userInfo: UserInfoModel = LoginManager.shared.getUserInfo() ?? UserInfoModel()
        // 排除掉自己
        for i in 0 ..< list.count {
            let item = list[i]
            if item.userId != userInfo.userId {
                self.participateList.append(item)
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getParticipateList()
    }
    
    func changeTableViewStatus() {
        if participateList.count == 0 {
            tableView.dataStatus = .empty
        } else {
            tableView.dataStatus = .none
        }
    }
    
    func resetSelectedNum() {
        var selectedNum = 0
        for item in participateList {
            if item.selected {
                selectedNum += 1
            }
        }
        
        navigationView.rightButton.setTitle("完成（\(selectedNum)）", for: .normal)
    }
    
    override func rightAction() {
        
        if let selectedBlock = selectedBlock {
            var seletedItems: [SimpleUserInfo] = []
            for item in participateList {
                if item.selected {
                    seletedItems.append(item)
                }
            }
            
            selectedBlock(seletedItems)
        }
        
        pop()
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
        
        
        // 多选、单选
        if mutiSelect {
            participateList[indexPath.row].selected = !item.selected
            resetSelectedNum()
            tableView.reloadRows(at: [indexPath], with: .automatic)
        } else {
            item.selected = true
            tableView.reloadRows(at: [indexPath], with: .automatic)
            
            if let selectedBlock = selectedBlock {
                selectedBlock([item])
                // 返回上一层
                self.dismiss(animated: true, completion: nil)
            }
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
    
    fileprivate func resetNavigation() {
        
        if mutiSelect {
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
}
