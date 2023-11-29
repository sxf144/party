//
//  SortUserController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class SortUserController: BaseController {
    
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 10
    let CollectionSpace: CGFloat = 8
    var uniqueCode: String = ""
    var gameItem: GameItem?
    var itemsPerRow: CGFloat = 4
    var rounds: [[String:Any]] = []
    var dataList: [[SimpleUserInfo]] = []

    override func viewDidLoad() {
        title = "调整玩家顺序"
        super.viewDidLoad()
        setupUI()
        
        collectionView.mj_header?.beginRefreshing()
    }
    
    // 创建顶部View
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    // tip
    fileprivate lazy var tipLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.text = "按住头像拖动可以调整位置"
        label.sizeToFit()
        return label
    }()
    
    /// 成员列表
    fileprivate lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumInteritemSpacing = CollectionSpace
        layout.minimumLineSpacing = CollectionSpace
        layout.sectionInset = UIEdgeInsets(top: yMargin, left: xMargin, bottom: yMargin, right: xMargin)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .white
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.delegate = self
        collectionView.dataSource = self
        // 允许拖动和重新排列项目
        if #available(iOS 14.0, *) {
            collectionView.isEditing = true
            collectionView.allowsSelectionDuringEditing = true;
        } else {
            // Fallback on earlier versions
        }
        collectionView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:))))
        
        // 注册Cell
        collectionView.register(GameUserCell.self, forCellWithReuseIdentifier: "GameUserCell")
        collectionView.register(GameUserTwoCell.self, forCellWithReuseIdentifier: "GameUserTwoCell")
        
        // 设置下拉刷新
        collectionView.mj_header = MJRefreshNormalHeader(refreshingBlock: { [weak self] in
            // 在这里执行下拉刷新的操作，例如加载最新数据
            self?.loadNewData()
        })
        return collectionView
    }()
    
    // 创建底部View
    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 随机重排
    fileprivate lazy var randomSortBtn: UIButton = {
        let button = UIButton(frame: CGRectMake(0, 0, 112, 40))
        button.backgroundColor = UIColor.ls_color("#B9A6F9")
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("随机重排", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium14
        button.addTarget(self, action: #selector(clickRandomSortBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 开始游戏
    fileprivate lazy var startBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("开始游戏", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.addTarget(self, action: #selector(clickStartBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension SortUserController {
    
    func setData(_ uniCode:String, gameItem: GameItem, rounds:[[String:Any]]) {
        self.uniqueCode = uniCode
        self.gameItem = gameItem
        self.rounds = rounds
        self.itemsPerRow = self.gameItem?.interactPersonCount == 2 ? 2 : 4
    }
    
    func getParticipateList() {
        
        if (uniqueCode.isEmpty) {
            if (self.collectionView.mj_header.isRefreshing) {
                self.collectionView.mj_header.endRefreshing()
            }
            return
        }
        
        NetworkManager.shared.getParticipateList(uniqueCode) { resp in
            LSLog("getParticipateList data:\(String(describing: resp.data))")
            if (self.collectionView.mj_header.isRefreshing) {
                self.collectionView.mj_header.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getParticipateList succ")
                self.handleData(resp.data.participateList)
                self.collectionView.reloadData()
            } else {
                LSLog("getParticipateList fail")
            }
        }
    }
    
    func handleData(_ userList:[SimpleUserInfo]) {
        dataList = []
        var step = 1
        if gameItem?.interactPersonCount == 1 {
            step = 1
        } else if gameItem?.interactPersonCount == 2 {
            step = 2
        } else {
            step = 1
        }
        
        for i in stride(from: 0, to: userList.count, by: step) {
            
            if step == 1 {
                dataList.append([userList[i]])
            } else if step == 2 {
                if (i + 1 < userList.count) {
                    dataList.append([userList[i], userList[i+1]])
                } else {
                    dataList.append([userList[i]])
                }
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getParticipateList()
    }
    
            
    @objc func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            if let indexPath = collectionView.indexPathForItem(at: gesture.location(in: collectionView)) {
                collectionView.beginInteractiveMovementForItem(at: indexPath)
                // 添加抖动动画
                let cell = collectionView.cellForItem(at: indexPath)
                UIView.animate(withDuration: 0.1, animations: {
                    cell?.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
                })
            }
        case .changed:
            collectionView.updateInteractiveMovementTargetPosition(gesture.location(in: gesture.view))
        case .ended:
            collectionView.endInteractiveMovement()
        default:
            collectionView.cancelInteractiveMovement()
        }
    }
    
    // 点击随机重排
    @objc func clickRandomSortBtn(_ sender:UIButton) {
        LSLog("clickRandomSortBtn")
        dataList.shuffle()
        collectionView.reloadData()
    }
    
    // 点击开始游戏
    @objc func clickStartBtn(_ sender:UIButton) {
        LSLog("clickStartBtn")
        var teams:[[String: Any]] = []
        
        for i in 0 ..< dataList.count {
            let items = dataList[i]
            var userIds:[String] = []
            for j in 0 ..< items.count {
                let item:SimpleUserInfo = items[j]
                userIds.append(item.userId)
            }
            teams.append(["user_ids": userIds])
        }
        
        // 开始游戏接口
        NetworkManager.shared.startGame(uniqueCode, gameId: gameItem?.id ?? 0, rounds: rounds, teams: teams) { resp in
            
            LSLog("startGame data:\(resp)")
            
            if resp.status == .success {
                LSLog("startGame succ")
                // 返回到群聊
//                let conv:LIMConversation = LIMConversation()
//                conv.type = .LIM_GROUP
//                conv.groupID = self.uniqueCode
//                conv.conversationID = "group_\(conv.groupID ?? "")"
//                PageManager.shared.pushToChatController(conv)
                // 返回到堆栈中的某个特定视图控制器
                if let targetViewController = PageManager.shared.currentNav()?.viewControllers.first(where: { $0 is ChatController }) {
                    PageManager.shared.currentNav()?.popToViewController(targetViewController, animated: true)
                }
            } else {
                LSLog("startGame fail")
                LSHUD.showError("\(resp.msg ?? "")")
            }
        }
    }
}

// UITableView 代理
extension SortUserController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let items = dataList[indexPath.row]
        var cell:UICollectionViewCell
        if gameItem?.interactPersonCount == 1 {
            let tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameUserCell", for: indexPath) as! GameUserCell
            // 配置单元格的内容
            tempCell.configure(with: items)
            cell = tempCell
        } else if gameItem?.interactPersonCount == 2 {
            let tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameUserTwoCell", for: indexPath) as! GameUserTwoCell
            // 配置单元格的内容
            tempCell.configure(with: items)
            cell = tempCell
        } else {
            let tempCell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameUserCell", for: indexPath) as! GameUserCell
            // 配置单元格的内容
            tempCell.configure(with: items)
            cell = tempCell
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算单元格的大小以适应屏幕宽度并保持4列
        let itemWidth = (collectionView.frame.width - xMargin*2 - CollectionSpace*(itemsPerRow - 1)) / itemsPerRow
        let itemHeight: CGFloat = 98
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    // 允许移动项目
    func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        LSLog("canMoveItemAt:\(indexPath)")
        return true
    }

    // 移动项目时更新数据源
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let movedItem = dataList.remove(at: sourceIndexPath.row)
        dataList.insert(movedItem, at: destinationIndexPath.row)
    }
}

extension SortUserController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        topView.addSubview(tipLabel)
        view.addSubview(bottomView)
        bottomView.addSubview(randomSortBtn)
        bottomView.addSubview(startBtn)
        view.addSubview(collectionView)
        
        
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.height.equalTo(40)
        }
        
        tipLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kTabBarHeight)
            make.bottom.equalToSuperview()
        }
        
        randomSortBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.width.equalTo(112)
            make.height.equalTo(40)
        }
        
        startBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(randomSortBtn)
            make.left.equalTo(randomSortBtn.snp.right).offset(10)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(40)
        }
        
        collectionView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalTo(topView.snp.bottom)
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
}
