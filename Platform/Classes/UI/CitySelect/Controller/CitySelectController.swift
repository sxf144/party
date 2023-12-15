//
//  CitySelectController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MJRefresh

class CitySelectController: BaseController {
    
    /// 回调闭包
    public var selectBlock: ((_ cityItem:CityItem) -> ())?
    let xMargin: CGFloat = 16
    let yMargin: CGFloat = 10
    let SectionHeaderHeight: CGFloat = 36
    let hotCount: Int = 6
    var cityInfo: CityModel?
    var allData: [PinyinSection] = []
    var dataList: [PinyinSection] = []

    override func viewDidLoad() {
        showNavifationBar = false
        super.viewDidLoad()
        setupUI()
        addObservers()
        // 加载数据
        loadLocalData()
    }
    
    // 创建顶部View
    fileprivate lazy var navView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    
    /// 返回按钮
    fileprivate lazy var leftButton: UIButton = {
        let button = UIButton()
        let img = UIImage(named: "icon_arrow_left_black")
        let backImg = img?.withRenderingMode(.alwaysOriginal)
        button.setImage(backImg, for: .normal)
        button.addTarget(self, action: #selector(clickLeftBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    /// 搜索栏
    fileprivate lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "请输入城市名或拼音首字母"
        searchBar.delegate = self
        searchBar.textField?.borderStyle = .none
        searchBar.layer.cornerRadius = 17
        searchBar.backgroundImage = UIImage()
        searchBar.backgroundColor = UIColor.ls_color("#F8F8F8")
        searchBar.clipsToBounds = true
        return searchBar
    }()
    
    /// 城市列表
    fileprivate lazy var tableView: UITableView = {
        let tableView = UITableView(frame: view.bounds, style: .plain)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.separatorStyle = .none
        tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.bounds.width, height: kSafeAreaHeight))
        tableView.sectionIndexColor = UIColor.ls_color("#aaaaaa")
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        } else {
            // Fallback on earlier versions
        }
        
        // 注册UITableViewCell类
        tableView.register(LocalCityItemCell.self, forCellReuseIdentifier: "LocalCityItemCell")
        tableView.register(HotCityItemCell.self, forCellReuseIdentifier: "HotCityItemCell")
        tableView.register(CityItemCell.self, forCellReuseIdentifier: "CityItemCell")
        
        return tableView
    }()
}

extension CitySelectController {
    
    func loadLocalData() {
        cityInfo = CityDataManager.shared.getCityInfo()
        if let cityInfo = cityInfo {
            allData = []
            dataList = []
            let localSection = PinyinSection()
            localSection.headerLeater = "定位"
            localSection.cityList = [cityInfo.locationCity]
            allData.append(localSection)
            let hotSection = PinyinSection()
            hotSection.headerLeater = "热门"
            hotSection.cityList = cityInfo.hots
            allData.append(hotSection)
            allData.append(contentsOf: cityInfo.sections)
            filterData("")
        }
    }
    
    func addObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(handleLocationDidUpdate(_:)), name: NotificationName.locationDidUpdate, object: nil)
    }
    
    @objc func handleLocationDidUpdate(_ notification: Notification) {
        // 定位城市发生变化，如果与当前不同，则更新
        if let newLocationCity = CityDataManager.shared.locationCity, newLocationCity.code != cityInfo?.locationCity.code {
            loadLocalData()
        }
    }
    
    @objc func clickLeftBtn(_ sender: UIButton) {
        LSLog("clickLeftBtn")
        pop()
    }
}

// MARK: - UITableView 代理
extension CitySelectController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        dataList.count
    }
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var finalRows: Int = 1
        let sectionItem = dataList[section]
        if sectionItem.headerLeater == "定位" {
            finalRows = 1
        } else if sectionItem.headerLeater == "热门" {
            finalRows = 1
        } else {
            finalRows = sectionItem.cityList.count
        }
        
        return finalRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let sectionItem: PinyinSection = dataList[indexPath.section]
        var cell: UITableViewCell
        if sectionItem.headerLeater == "定位" {
            LSLog("---- 定位 ---- cityList count:\(sectionItem.cityList.count)")
            let tempCell = tableView.dequeueReusableCell(withIdentifier: "LocalCityItemCell", for: indexPath) as! LocalCityItemCell
            // 配置单元格的内容
            let item: CityItem = sectionItem.cityList[indexPath.row]
            tempCell.configure(item)
            tempCell.citySelectBlock = { [weak self] cityItem in
                if let selectBlock = self?.selectBlock {
                    selectBlock(cityItem)
                }
                self?.pop()
            }
            cell = tempCell
        } else if sectionItem.headerLeater == "热门" {
            let tempCell = tableView.dequeueReusableCell(withIdentifier: "HotCityItemCell", for: indexPath) as! HotCityItemCell
            // 配置单元格的内容
            tempCell.configure(sectionItem.cityList)
            tempCell.citySelectBlock = { [weak self] cityItem in
                if let selectBlock = self?.selectBlock {
                    selectBlock(cityItem)
                }
                self?.pop()
            }
            cell = tempCell
        } else {
            let tempCell = tableView.dequeueReusableCell(withIdentifier: "CityItemCell", for: indexPath) as! CityItemCell
            // 配置单元格的内容
            let item: CityItem = sectionItem.cityList[indexPath.row]
            tempCell.configure(item)
            cell = tempCell
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return SectionHeaderHeight
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        var finalHeight: CGFloat = 6
        if section == dataList.count - 1 {
            finalHeight = 0.01
        }
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: finalHeight))
        view.backgroundColor = UIColor.ls_color("F8F8F8")
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        var finalHeight: CGFloat = 6
        if section == dataList.count - 1 {
            finalHeight = 0.01
        }
        return finalHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // 创建一个自定义的section头部视图
        let sectionItem = dataList[section]
        let view = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.width, height: SectionHeaderHeight))
        view.backgroundColor = .white
        let label = UILabel()
        label.text = sectionItem.headerLeater
        label.textColor = UIColor.ls_color("#999999")
        label.font = kFontRegualer12
        label.textAlignment = .left
        label.sizeToFit()
        label.frame.origin = CGPoint(x: 16, y: (SectionHeaderHeight - label.frame.size.height)/2)
        view.addSubview(label)
        
        return view
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        var finalHeight: CGFloat = 44
        let sectionItem = dataList[indexPath.section]
        if sectionItem.headerLeater == "定位" {
            finalHeight = 40
        } else if sectionItem.headerLeater == "热门" {
            finalHeight = 80
        }
        
        return finalHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 选中cell
        let sectionItem = dataList[indexPath.section]
        if sectionItem.headerLeater != "定位", sectionItem.headerLeater != "热门" {
            let item: CityItem = sectionItem.cityList[indexPath.row]
            if let selectBlock = selectBlock {
                selectBlock(item)
            }
            pop()
        }
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return dataList.map { $0.headerLeater }
    }
    
    func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
}

// MARK: - UITableView 代理
extension CitySelectController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        LSLog("searchBarSearchButtonClicked searchText:\(searchBar.text ?? "")")
        filterData(searchBar.text ?? "")
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        LSLog("textDidChange searchText:\(searchText)")
        filterData(searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        LSLog("searchBarCancelButtonClicked")
        filterData("")
        searchBar.resignFirstResponder()
    }
    
    func filterData(_ text: String) {
        if !text.isEmpty {
            LSLog("filterData text:\(text)")
            // 过滤数据
            dataList = allData.filter { section in
                let cityList = section.cityList.filter { city in
                    return (city.name.contains(text)) || (city.pinyin.uppercased().contains(text.uppercased()))
                }
                
                return cityList.count > 0
            }
        } else {
            dataList = allData
        }
        
        tableView.reloadData()
    }
}

extension CitySelectController {
    
    fileprivate func setupUI() {
        
        view.addSubview(navView)
        navView.addSubview(leftButton)
        navView.addSubview(searchBar)
        view.addSubview(tableView)
        
        navView.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview()
            make.height.equalTo(kNavBarHeight)
        }
        
        leftButton.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(4)
            make.bottom.equalToSuperview()
            make.width.greaterThanOrEqualTo(44)
            make.height.equalTo(44)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(52)
            make.bottom.equalToSuperview().offset(-5)
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(34)
        }
        
        tableView.snp.remakeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.bottom.equalToSuperview()
        }
    }
}
