//
//  GameRoundListController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class GameRoundListController: BaseController {
    
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 10
    let CollectionSpace: CGFloat = 6
    var gameItem: GameItem?
    var originDataList: [GameRoundItem] = []
    var allDataList: [GameCardItem] = []
    var dataList: [GameCardItem] = []
    var seletedRounds: [[String: Any]] = []
    var options: [[String: Any]] = [
        ["key": "轮次：", "value": []],
        ["key": "难度：", "value": [["key": "困难", "value": 3], ["key": "中等", "value": 2], ["key": "简单", "value": 1]]],
        ["key": "匹配：", "value": [["key": "单人", "value": 1], ["key": "双人", "value": 2]]],
        ["key": "道具：", "value": [["key": "不用道具", "value": 2], ["key": "需要道具", "value": 1]]],
    ]
    var filter1:[Int] = []
    var filter2:[Int] = [1, 2, 3]
    var filter3:[Int] = [1, 2]
    var filter4:[Int] = [1, 2]
    let BtnKeyType = "type"
    let BtnKeyValue = "value"
//    var needBlock: Bool = true
    
    /// 回调闭包
    public var selectedBlock: ((_ roundItems:[[String: Any]]) -> ())?

    override func viewDidLoad() {
        title = "选择本局卡牌"
        super.viewDidLoad()
        setupUI()
        
        rechargeCollectionView.mj_header?.beginRefreshing()
    }
    
    override func pop() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 创建顶部View
    fileprivate lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    
    /// 卡牌列表
    fileprivate lazy var rechargeCollectionView: UICollectionView = {
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
        collectionView.register(GameCardCell.self, forCellWithReuseIdentifier: "GameCardCell")
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
    
    // 下一步
    fileprivate lazy var confirmBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.layer.cornerRadius = 20
        button.clipsToBounds = true
        button.setTitle("确定", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = kFontMedium16
        button.addTarget(self, action: #selector(clickConfirmBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension GameRoundListController {
    
    func setData(_ gameItem: GameItem) {
        self.gameItem = gameItem
    }
    
    func getGameRoundList() {
        if (gameItem == nil || gameItem?.id == 0) {
            return
        }
        NetworkManager.shared.getGameRoundList(gameItem?.id ?? 0) { resp in
            LSLog("getGameRoundList data:\(resp.data)")
            if (self.rechargeCollectionView.mj_header.isRefreshing) {
                self.rechargeCollectionView.mj_header.endRefreshing()
            }
            
            if resp.status == .success {
                LSLog("getGameRoundList succ")
                self.originDataList = resp.data.rounds
                self.handleData()
                self.rechargeCollectionView.reloadData()
                
            } else {
                LSLog("getGameRoundList fail")
            }
        }
    }

    func loadNewData() {
        // 在这里执行下拉刷新的操作
        getGameRoundList()
    }
    
    func handleData() {
        if self.originDataList.count > 0 {
            var valueArray:[[String: Any]] = []
            allDataList = []
            filter1 = []
            for i in 0 ..< originDataList.count {
                let valueItem:[String: Any] = ["key": "第\(i+1)轮次", "value": i+1]
                valueArray.append(valueItem)
                filter1.append(i+1)
                for j in 0 ..< originDataList[i].cards.count {
                    let item = originDataList[i].cards[j]
                    item.index = i + 1
                    allDataList.append(item)
                }
            }
            // 过滤数据
            filterData()
            options[0]["value"] = valueArray
            createOptions()
        }
    }
    
    // 点击确定
    @objc func clickConfirmBtn(_ sender:UIButton) {
        LSLog("clickConfirmBtn")
        // 如果全部都是选择状态，则没有修改自定义，返回空
        var changed = false
        for round in originDataList {
            var sRoundItem:[String: Any] = ["round_id": round.id]
            var cardIds:[Int64] = []
            
            for card in round.cards {
                if !card.selected {
                    changed = true
                } else {
                    cardIds.append(card.id)
                }
            }
            
            sRoundItem["card_ids"] = cardIds
            seletedRounds.append(sRoundItem)
        }
        
        
        if let selectedBlock = selectedBlock {
            if changed {
                selectedBlock(seletedRounds)
            } else {
                selectedBlock([])
            }
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    // 点击筛选项
    @objc func clickOptionBtn(_ sender:UIButton) {
        sender.isSelected = !sender.isSelected
        LSLog("clickOptionBtn")
        let type:Int = sender.layer.value(forKey: BtnKeyType) as! Int
        let value:Int = sender.layer.value(forKey: BtnKeyValue) as! Int
        
        if (type == 1) {
            if sender.isSelected {
                filter1.append(value)
            } else {
                filter1.removeAll { $0 == value }
            }
            
        } else if (type == 2) {
            if sender.isSelected {
                filter2.append(value)
            } else {
                filter2.removeAll { $0 == value }
            }
        } else if (type == 3) {
            if sender.isSelected {
                filter3.append(value)
            } else {
                filter3.removeAll { $0 == value }
            }
            
        } else if (type == 4) {
            
            if sender.isSelected {
                filter4.append(value)
            } else {
                filter4.removeAll { $0 == value }
            }
        }
        
        // 过滤数据
        filterData()
        // 刷新数据
        self.rechargeCollectionView.reloadData()
    }
    
    func filterData() {
        dataList = []
        dataList = allDataList.filter { object in
            return (filter1.contains(object.index)) && (filter2.contains(object.index)) && (filter3.contains(object.index)) && (filter4.contains(object.index))
        }
    }
    
    func createOptions() {
        LSLog("createOptions options:\(options)")
        // 移除personContent 所有子view
        for subview in topView.subviews {
            subview.removeFromSuperview()
        }
        view.layoutIfNeeded()
        let sub_height: CGFloat = 46
        for i in 0 ..< options.count {
            let option = options[i]
            
            let topSubView = UIView()
            topView.addSubview(topSubView)
            
            let keyLabel = UILabel()
            keyLabel.font = kFontRegualer14
            keyLabel.textColor = UIColor.ls_color("#333333")
            keyLabel.text = option["key"] as? String
            keyLabel.sizeToFit()
            topSubView.addSubview(keyLabel)
            
            topSubView.snp.makeConstraints { (make) in
                make.left.equalToSuperview()
                make.top.equalToSuperview().offset(sub_height*CGFloat(i))
                make.width.equalTo(topView)
                make.height.equalTo(sub_height)
            }
            
            keyLabel.snp.makeConstraints { (make) in
                make.left.equalToSuperview().offset(xMargin)
                make.centerY.equalToSuperview()
            }
            
            var btn_width = 68
            let btn_height = 30
            if (i == 3) {
                btn_width = 96
            }
            
            let optionValue:[[String: Any]] = option["value"] as! [[String : Any]]
            for j in 0 ..< optionValue.count {
                let valueBtn = UIButton()
                valueBtn.setTitleColor(UIColor.ls_color("#999999"), for: .normal)
                valueBtn.setTitleColor(UIColor.white, for: .selected)
                valueBtn.titleLabel?.font = kFontRegualer14
                valueBtn.layer.cornerRadius = 4
                valueBtn.clipsToBounds = true
                valueBtn.isSelected = true
                // 设置普通状态下的背景色
                valueBtn.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#F4F4F4")), for: .normal)
                valueBtn.setBackgroundImage(UIImage.ls_image(UIColor.ls_color("#FE9C5B")), for: .selected)
                valueBtn.setTitle(optionValue[j]["key"] as? String, for: .normal)
                valueBtn.layer.setValue((i+1), forKey: BtnKeyType)
                valueBtn.layer.setValue(optionValue[j]["value"], forKey: BtnKeyValue)
                valueBtn.addTarget(self, action: #selector(clickOptionBtn(_:)), for: .touchUpInside)
                topSubView.addSubview(valueBtn)
                
                valueBtn.snp.makeConstraints { (make) in
                    make.left.equalTo(keyLabel.snp.right).offset((btn_width+8)*j)
                    make.centerY.equalToSuperview()
                    make.size.equalTo(CGSize(width: btn_width, height: btn_height))
                }
                
            }
        }
    }
    
    func resetSelectedItems() {
        var totalCount = 0
        for round in originDataList {
            for card in round.cards {
                if card.selected {
                    totalCount += 1
                }
            }
        }
        
        confirmBtn.setTitle("确定（\(totalCount)）", for: .normal)
    }
}

// UITableView 代理
extension GameRoundListController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return dataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let item = dataList[indexPath.row]
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "GameCardCell", for: indexPath) as! GameCardCell
        // 配置单元格的内容
        cell.configure(with: item)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 计算单元格的大小以适应屏幕宽度并保持4列
        let itemsPerRow: Int = 4
        let itemWidth = (collectionView.frame.width - xMargin*2 - CollectionSpace*CGFloat(itemsPerRow - 1)) / CGFloat(itemsPerRow)
        let itemHeight: CGFloat = 112
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        dataList[indexPath.row].selected = !dataList[indexPath.row].selected
        
        // 更新已选数据
        resetSelectedItems()
        collectionView.reloadItems(at: [indexPath])
    }
}

extension GameRoundListController {
    
    fileprivate func setupUI() {
        
        view.addSubview(topView)
        view.addSubview(rechargeCollectionView)
        view.addSubview(bottomView)
        bottomView.addSubview(confirmBtn)
        
        topView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.height.equalTo(184)
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.height.equalTo(kTabBarHeight)
            make.bottom.equalToSuperview()
        }
        
        confirmBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(yMargin)
            make.left.equalToSuperview().offset(xMargin)
            make.right.equalToSuperview().offset(-xMargin)
            make.height.equalTo(40)
        }
        
        rechargeCollectionView.snp.remakeConstraints { (make) in
            make.top.equalTo(topView.snp.bottom)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
            make.bottom.equalTo(bottomView.snp.top)
        }
    }
}
