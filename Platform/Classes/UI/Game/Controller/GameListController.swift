//
//  GameListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class GameListController: BaseController {
    
    let CellHeight = 120.0
    var gameList: GameListModel = GameListModel()
    var needBlock: Bool = true
    var uniqueCode: String = ""
    var selectedIndex: Int = -1
    var selectedRounds: [[String:Any]] = []
    /// 回调闭包
    public var gameSelectedBlock: ((_ gameItem:GameItem) -> ())?

    override func viewDidLoad() {
        self.title = "选择游戏"
        super.viewDidLoad()
        setupUI()
        
        tableView.mj_header?.beginRefreshing()
    }
    
    // 创建UITableView
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
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
        tableView.register(GameItemCell.self, forCellReuseIdentifier: "GameItemCell")
        return tableView
    }()
    
    // 创建底部View
    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()
    
    // 自定义卡牌
    fileprivate lazy var cardBtn: UIButton = {
        let button = UIButton(frame: CGRectMake(0, 0, 112, 40))
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("自定义卡牌", for: .normal)
        button.setTitleColor(UIColor.ls_color("#FE9C5B"), for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.addTarget(self, action: #selector(clickCardBtn(_:)), for: .touchUpInside)
        // 设置虚线边框
        let dashedBorderLayer = CAShapeLayer()
        dashedBorderLayer.strokeColor = UIColor.ls_color("#FE9C5B").cgColor
        dashedBorderLayer.lineWidth = 1
        dashedBorderLayer.lineDashPattern = [3, 3] // 这里的数组表示虚线的线段长度和间隔长度
        dashedBorderLayer.frame = button.bounds
        dashedBorderLayer.fillColor = nil
        dashedBorderLayer.path = UIBezierPath(roundedRect: button.bounds, cornerRadius: 20).cgPath
        // 添加虚线边框图层到 UIButton
        button.layer.addSublayer(dashedBorderLayer)
        return button
    }()
    
    // 下一步
    fileprivate lazy var nextBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.addTarget(self, action: #selector(clickNextBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension GameListController {
    
    func setData(_ needBlock: Bool, uniCode: String) {
        self.needBlock = needBlock
        self.uniqueCode = uniCode
    }
    
    func getGameList(pageNum:Int, pageSize:Int) {
        
        NetworkManager.shared.getGameList(pageNum, pageSize: pageSize) { resp in
            LSLog("getGameList data:\(String(describing: resp.data))")
            if (self.tableView.mj_header.isRefreshing) {
                self.tableView.mj_header.endRefreshing()
            }
            
            if (self.tableView.mj_footer.isRefreshing) {
                self.tableView.mj_footer.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getGameList succ")
                self.gameList = resp.data
                self.tableView.reloadData()
                if (self.gameList.totalCount <= self.gameList.pageNum * self.gameList.pageSize) {
                    self.tableView.mj_footer.endRefreshingWithNoMoreData()
                }
            } else {
                LSLog("getGameList fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getGameList(pageNum: 1, pageSize: gameList.pageSize)
    }

    func loadMoreData() {
        // 在这里执行上拉加载更多的操作
        if (gameList.totalCount > gameList.pageNum * gameList.pageSize) {
            let pn = gameList.pageNum + 1
            getGameList(pageNum: pn, pageSize: gameList.pageSize)
        }
    }
    
    // 点击自定义卡牌
    @objc func clickCardBtn(_ sender:UIButton) {
        LSLog("clickCardBtn")
        if (selectedIndex < 0 || selectedIndex >= gameList.items.count) {
            LSHUD.showError("请选择游戏")
            return
        }
        let gameItem = gameList.items[selectedIndex]
//        PageManager.shared.presentGameRoundListController(gameItem)
        
        let vc = GameRoundListController()
        vc.setData(gameItem)
        vc.selectedBlock = { roundItems in
            LSLog("selectedBlock roundItems:\(roundItems)")
            self.selectedRounds = roundItems
        }
        vc.hidesBottomBarWhenPushed = true
        PageManager.shared.currentVC()?.present(vc, animated: true, completion: nil)
    }
    
    // 点击下一步
    @objc func clickNextBtn(_ sender:UIButton) {
        LSLog("clickNextBtn")
        if (selectedIndex < 0 || selectedIndex >= gameList.items.count) {
            LSHUD.showError("请选择游戏")
            return
        }
        let gameItem = gameList.items[selectedIndex]
        PageManager.shared.pushToSortUserController(uniqueCode, gameItem: gameItem, rounds: selectedRounds)
    }
}

// UITableView 代理
extension GameListController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return gameList.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "GameItemCell", for: indexPath) as! GameItemCell
        let item = gameList.items[indexPath.row]
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        if (needBlock) {
            let item = gameList.items[indexPath.row]
            if let gameSelectedBlock = gameSelectedBlock {
                gameSelectedBlock(item)
                // 返回上一层
                pop()
            }
        } else {
            selectedIndex = indexPath.row
            for i in 0 ..< gameList.items.count {
                gameList.items[i].selected = i == selectedIndex
            }
            tableView.reloadData()
        }
    }
}

extension GameListController{
    fileprivate func setupUI(){
        
        view.addSubview(tableView)
        view.addSubview(bottomView)
        bottomView.addSubview(cardBtn)
        bottomView.addSubview(nextBtn)
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kTabBarHeight)
            make.bottom.equalToSuperview()
        }
        
        cardBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(16)
            make.width.equalTo(112)
            make.height.equalTo(40)
        }
        
        nextBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(cardBtn)
            make.left.equalTo(cardBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(40)
        }
        
        if (needBlock) {
            bottomView.isHidden = true

            tableView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(kNavBarHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalToSuperview()
            }
        } else {
            bottomView.isHidden = false

            tableView.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(kNavBarHeight)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview()
                make.bottom.equalTo(bottomView.snp.top)
            }
        }
    }
}
