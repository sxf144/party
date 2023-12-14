//
//  RecommendController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import JXSegmentedView

class RecommendController: BaseController {
    
    var recommendData: RecommendModel = RecommendModel()
    var lastIndexPath: IndexPath?
    var lastActiveCell: RecommendCell?
    var currCity: CityItem?

    override func viewDidLoad() {
        self.slideBackEnabled = false
        self.showNavifationBar = false
        title = "推荐"
        super.viewDidLoad()
        setupUI()
        // 添加监听
        addObservers()
        
        // 拉取列表信息
        loadNewData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        LSLog("RecommendController viewDidDisappear")
        super.viewDidDisappear(animated)
        // 停止当前cell 播放
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
        tableView.backgroundColor = .white
        
        // 注册UITableViewCell类
        tableView.register(RecommendCell.self, forCellReuseIdentifier: "RecommendCell")
        return tableView
    }()
    
    // 进行中view
    fileprivate lazy var onGoingView: UIView = {
        let view = UIView()
        view.isHidden = true
        view.layer.cornerRadius = 23
        view.clipsToBounds = true
        let goingTapGes = UITapGestureRecognizer(target: self, action: #selector(goingPartyDidClick))
        view.addGestureRecognizer(goingTapGes)
        return view
    }()
    
    fileprivate lazy var onGoingBgLayer: CAGradientLayer = {
        // fillCode
        let bgLayer = CAGradientLayer()
        bgLayer.colors = [UIColor(red: 1, green: 0.61, blue: 0.36, alpha: 1).cgColor, UIColor(red: 0.98, green: 0.48, blue: 0.48, alpha: 0.04).cgColor]
        bgLayer.locations = [0, 1]
        bgLayer.frame = onGoingView.bounds
        bgLayer.startPoint = CGPoint(x: 0.02, y: 0.07)
        bgLayer.endPoint = CGPoint(x: 1, y: 1)
        return bgLayer
    }()
    
    fileprivate lazy var onGoingLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium14
        label.textColor = UIColor.ls_color("#ffffff")
        label.text = ""
        label.sizeToFit()
        return label
    }()
    
    fileprivate lazy var onGoingIV: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_ongoing")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
}

extension RecommendController {
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogin(_:)), name: NotificationName.loginSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleLogout(_:)), name: NotificationName.logoutSuccess, object: nil)
    }
    
    @objc func handleLogin(_ notification: Notification) {
        // 登录成功，重新拉取列表信息
        loadNewData()
    }
    
    @objc func handleLogout(_ notification: Notification) {
        // 退出登录
    }
    
    @objc func goingPartyDidClick() {
        LSLog("goingPartyDidClick")
        // 跳转到群聊
        let conv:LIMConversation = LIMConversation()
        conv.type = .LIM_GROUP
        conv.groupID = recommendData.ongoing?.uniqueCode
        conv.conversationID = "group_\(conv.groupID ?? "")"
        conv.showName = recommendData.ongoing?.name
        PageManager.shared.pushToChatController(conv)
    }
    
    func loadNewData() {
        currCity = CityDataManager.shared.getCurrCity()
        if let currCity = currCity, !currCity.code.isEmpty {
            LSLog("city code:\(currCity.code)")
            getRecommend(cursor: "", cityCode: currCity.code)
        }
    }
    
    func getRecommend(cursor:String, cityCode:String) {
        if cursor.isEmpty {
            LSHUD.showLoading()
        }
        if let cityCode = Int64(cityCode) {
            NetworkManager.shared.recommend(cursor, cityCode:cityCode) { resp in
                LSLog("getRecommend data:\(String(describing: resp.data))")
                LSHUD.hide()
                if resp.status == .success {
                    LSLog("getRecommend succ")
                    self.recommendData = resp.data
                    if cursor.isEmpty {
                        self.recommendData = resp.data
                    } else {
                        self.recommendData.items?.append(contentsOf: resp.data.items ?? [])
                        self.recommendData.cursorTime = resp.data.cursorTime
                        self.recommendData.hasMore = resp.data.hasMore
                        self.recommendData.ongoing = resp.data.ongoing
                    }
                    self.handleOnGoingView()
                    self.tableView.reloadData()
                    DispatchQueue.main.async {
                        // 在这里执行reloadData完成后的操作
                        // 例如，你可以更新UI或执行其他任务
                        self.handleCurrentCell()
                    }
                    
                    // 判断是否展示空页面
                    self.isEmpty()
                    
                } else {
                    LSLog("getRecommend fail")
                }
            }
        } else {
            LSHUD.hide()
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
                    
                    preLoad(indexPath.row)
                    break
                }
            }
        }
    }
    
    func preLoad(_ index:Int) {
        // 判断是否需要去预加载
        if self.recommendData.items?.count ?? 0 > 0, self.recommendData.hasMore, index > (self.recommendData.items?.count ?? 0) - 5 {
            if !self.recommendData.cursorTime.isEmpty {
                getRecommend(cursor: self.recommendData.cursorTime, cityCode: currCity?.code ?? "")
            }
        }
    }
    
    func handleOnGoingView() {
        if (recommendData.ongoing?.userId == "")  {
            onGoingView.isHidden = true
        } else {
            onGoingView.isHidden = false
            onGoingLabel.text = "正在参与" + (recommendData.ongoing?.name)! + "..."
            onGoingLabel.sizeToFit()
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
extension RecommendController: JXSegmentedListContainerViewListDelegate {
    func listView() -> UIView {
        return view
    }
}

// UITableView 代理
extension RecommendController: UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate {
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


extension RecommendController {
    
    fileprivate func setupUI() {
        
        view.addSubview(tableView)
        view.addSubview(onGoingView)
        onGoingView.layer.addSublayer(onGoingBgLayer)
        onGoingView.addSubview(onGoingLabel)
        onGoingView.addSubview(onGoingIV)
        
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        onGoingView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(45)
        }
        
        onGoingLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(onGoingIV.snp.left).offset(-10)
        }
        
        onGoingIV.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-10)
            make.size.equalTo(CGSize(width: 36, height: 36))
        }
        
        view.layoutIfNeeded()
        onGoingBgLayer.frame = onGoingView.bounds
    }
}
