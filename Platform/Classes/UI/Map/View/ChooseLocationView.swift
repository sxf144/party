//
//  ChooseLocationView.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import MAMapKit
import AMapFoundationKit
import AMapSearchKit

class ChooseLocationView: UIView {
    
    var selectedRowIndex: Int? = 0
    let defaultZoomLevel: CGFloat = 15.0
    let mapHeight: CGFloat = 560
    let maxSearchCount: Int = 20
    let cellHeight: CGFloat = 60
    let leftMargin: CGFloat = 20
    var keyString: String? = ""
    let search: AMapSearchAPI = AMapSearchAPI()
    var responseList:[AMapPOI] = []
    /// 回调闭包
    fileprivate var confirmBlock: ((_ poiItem:AMapPOI) -> ())?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.white
        setupUI()
        search.delegate = self
        // 监听键盘状态
        addObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // 地图
    fileprivate lazy var myMapView: MAMapView = {
        let mapView = MAMapView(frame: self.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.zoomLevel = defaultZoomLevel
        return mapView
    }()
    
    // 定位图标
    fileprivate lazy var locationImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icon_location2")
        return imageView
    }()
    
    // 搜索结果列表
    fileprivate lazy var responseView: UITableView = {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.contentInsetAdjustmentBehavior = .never
        tableView.backgroundColor = .white
        tableView.tableHeaderView = headerView
        
        // 注册UITableViewCell类
        tableView.register(PoiCell.self, forCellReuseIdentifier: "PoiCell")
        return tableView
    }()
    
    fileprivate lazy var headerView: UIView = {
        let view = UIView()
        return view
    }()
    
    // 搜索按钮
    fileprivate lazy var searchBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#f9f9f9")
        button.titleLabel?.font = UIFont.ls_mediumFont(14)
        button.setTitleColor(UIColor.ls_color("#aaaaaa"), for: .normal)
        button.layer.cornerRadius = 8
        button.clipsToBounds = true
        button.setTitle("搜索地点", for: .normal)
        button.addTarget(self, action: #selector(clickSearchBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 搜索框
    fileprivate lazy var searchTextField: UITextField = {
        let textField = UITextField()
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: textField.frame.height))
        textField.leftView = paddingView
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 8
        textField.backgroundColor = UIColor.ls_color("#F9F9F9")
        textField.textColor = kColorTextBlack
        textField.delegate = self
        textField.returnKeyType = .search
        textField.attributedPlaceholder = NSAttributedString(string: "搜索地点", attributes: [NSAttributedString.Key.foregroundColor: kColorTextGray])
        return textField
    }()
    
    fileprivate lazy var leftBtn: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.ls_mediumFont(15)
        button.setTitle("取消", for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .normal)
        button.addTarget(self, action: #selector(clickLeftBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var rightBtn: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.titleLabel?.font = UIFont.ls_mediumFont(15)
        button.setTitle("发送", for: .normal)
        button.setTitleColor(UIColor.ls_color("#ffffff"), for: .normal)
        button.layer.cornerRadius = 8
        button.addTarget(self, action: #selector(clickRightBtn(_:)), for: .touchUpInside)
        return button
    }()
    
    // 回归定位
    fileprivate lazy var myLocationBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "my_location"), for: .normal)
        button.addTarget(self, action: #selector(clickMyLocationBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension ChooseLocationView {
    /// 显示 ChooseLocationView
    public func showInWindow(confirmBlock: @escaping ((_ poiItem:AMapPOI) -> ())){
        let keyWindow = UIApplication.shared.windows.first(where: { $0.isKeyWindow })
        keyWindow!.addSubview(self)
        keyWindow!.bringSubviewToFront(self)
        self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: kScreenH)
        self.confirmBlock = confirmBlock
        //显示页面
        UIView.animate(withDuration: 0.3) {
            self.frame = CGRect(x: 0, y: 0, width: kScreenW, height: kScreenH)
        }
    }
    
    /// 移除view
    func dissmiss() {
        UIView.animate(withDuration: 0.3, animations: {
            self.frame = CGRect(x: 0, y: kScreenH, width: kScreenW, height: kScreenH)
            self.searchTextField.resignFirstResponder()
        }) { (suc) in
            self.removeFromSuperview()
        }
    }
}


extension ChooseLocationView {
    
    func shouldDisableRightButton() -> Bool {
        
        return true
    }
    
    func searchAround() {
        // 地图中心点位置
        let geoPoint = AMapGeoPoint.location(withLatitude: CGFloat(myMapView.centerCoordinate.latitude), longitude: CGFloat(myMapView.centerCoordinate.longitude))
        
        // 获取点击位置的地理信息
        let request = AMapPOIAroundSearchRequest()
        request.location = geoPoint
        /* 按照距离排序. */
        request.sortrule = 0;
        search.aMapPOIAroundSearch(request)
    }
    
    func searchKeys() {
        // 地图中心点位置
        let geoPoint = AMapGeoPoint.location(withLatitude: CGFloat(myMapView.centerCoordinate.latitude), longitude: CGFloat(myMapView.centerCoordinate.longitude))
        
        let request = AMapPOIKeywordsSearchRequest()
        request.keywords = keyString
        request.location = geoPoint
        request.sortrule = 0;
        request.cityLimit = true
        search.aMapPOIKeywordsSearch(request)
    }
    
    @objc func clickSearchBtn(_ sender:UIButton) {
        
    }
    
    func addObservers(){
        // 注册键盘通知
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.size.height
            LSLog("keyboardHeight:\(keyboardHeight)")
            // 在这里处理键盘显示时的逻辑
            myMapView.snp.updateConstraints { make in
                make.height.equalTo(CGFloat(mapHeight)-keyboardHeight)
            }
            responseView.snp.updateConstraints { make in
                make.bottom.equalToSuperview().offset(-keyboardHeight)
            }

            // 使用动画来平滑地改变布局
            UIView.animate(withDuration: 0.3) {
                self.layoutIfNeeded()
            }
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        // 在这里处理键盘隐藏时的逻辑
        myMapView.snp.updateConstraints { make in
            make.height.equalTo(mapHeight)
        }
        responseView.snp.updateConstraints { make in
            make.bottom.equalToSuperview()
        }

        // 使用动画来平滑地改变布局
        UIView.animate(withDuration: 0.3) {
            self.layoutIfNeeded()
        }
    }
    
    @objc func clickLeftBtn(_ sender:UIButton) {
        dissmiss()
    }
    
    @objc func clickRightBtn(_ sender:UIButton) {
        if (responseList.count == 0) {
            return
        }
        // 回调闭包
        let poiItem:AMapPOI = responseList[selectedRowIndex ?? 0]
        self.confirmBlock?(poiItem)
        dissmiss()
    }
    
    @objc func clickMyLocationBtn(_ sender:UIButton) {
        // 回到自己位置
        myMapView.setCenter(myMapView.userLocation.location.coordinate, animated: true)
    }
}

extension ChooseLocationView: MAMapViewDelegate, AMapSearchDelegate {
    
    func mapView(_ mapView: MAMapView!, didSingleTappedAt coordinate: CLLocationCoordinate2D) {
        // 单击时，输入框失去焦点
        searchTextField.resignFirstResponder()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        LSLog("mapViewDidFinishLoadingMap:\(mapView.centerCoordinate)")
        // 地图加载完成，搜索周边
        searchAround()
    }
    
    func mapView(_ mapView: MAMapView!, mapDidMoveByUser wasUserAction: Bool) {
        LSLog("mapDidMoveByUser centerCoordinate:\(mapView.centerCoordinate), wasUserAction:\(wasUserAction)")
        
        // 用户移动地图结束，搜索周边
        if (wasUserAction){
            searchAround()
        }
    }
    
    func onPOISearchDone(_ request: AMapPOISearchBaseRequest!, response: AMapPOISearchResponse!) {
        LSLog("onPOISearchDone response:\(String(describing: response))")
        if (response.pois.count == 0) {
            return;
        }
        // 解析数据
        LSLog("onPOISearchDone response count:\(String(describing: response.count))")
        LSLog("onPOISearchDone response pois:\(String(describing: response.pois))")
        responseList = response.pois
        // 选中inde重置为0
        selectedRowIndex = 0
        responseView.reloadData()
        for item in response.pois {
            LSLog("onPOISearchDone item:\(item)")
        }
    }
    
    func aMapSearchRequest(_ request: Any!, didFailWithError error: Error!) {
        LSLog("aMapSearchRequest error:\(String(describing: error))")
    }
}

extension ChooseLocationView: UITableViewDataSource, UITableViewDelegate {
    
    // 实现UITableViewDataSource方法
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return responseList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PoiCell", for: indexPath) as! PoiCell
        let item = responseList[indexPath.row]
        // 检查是否应该显示Checkmark标识
        if indexPath.row == selectedRowIndex {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        cell.configure(with: item)
        return cell
    }
    
    // 实现UITableViewDelegate方法
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return cellHeight
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 地图中心点移动到选中位置
        let item = responseList[indexPath.row]
        selectedRowIndex = indexPath.row
        tableView.reloadData()
        let coordinate = CLLocationCoordinate2D(latitude: item.location.latitude, longitude: item.location.longitude)
        myMapView.setCenter(coordinate, animated: true)
        // 设置地图的缩放级别
        myMapView.setZoomLevel(defaultZoomLevel, animated: true)
    }
}

extension ChooseLocationView: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // 获取当前文本字段的文本
        guard let currentText = textField.text else {
            return true
        }
        
        // 计算新的文本长度
        let newLength = currentText.count + string.count - range.length
        
        // 检查是否超过了最大字符数
        return newLength <= maxSearchCount
    }
    
    func textFieldDidChangeSelection(_ textField: UITextField) {
        LSLog("markedTextRange:\(String(describing: textField.markedTextRange))")
        if (textField.markedTextRange == nil && keyString != textField.text) {
            // 关键词
            keyString = textField.text
            // 按关键词搜索
            searchKeys()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
    }
}


extension ChooseLocationView {
    
    fileprivate func setupUI() {
        
        self.addSubview(myMapView)
        myMapView.addSubview(locationImageView)
        self.addSubview(responseView)
        headerView.addSubview(searchTextField)
        self.addSubview(leftBtn)
        self.addSubview(rightBtn)
        self.addSubview(myLocationBtn)
        
        
        myMapView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(mapHeight)
        }
        
        locationImageView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalTo(CGSize(width: 44, height: 54))
        }
        
        responseView.snp.makeConstraints { (make) in
            make.top.equalTo(myMapView.snp.bottom)
            make.bottom.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        headerView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview()
            make.width.equalToSuperview()
            make.height.equalTo(cellHeight)
        }
        
        searchTextField.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-leftMargin*2)
            make.height.equalTo(36)
            make.center.equalToSuperview()
        }
        
        leftBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.top.equalToSuperview().offset(kStatusBarHeight)
            make.height.equalTo(44)
            make.width.equalTo(44)
        }
        
        rightBtn.snp.makeConstraints { (make) in
            make.right.equalTo(-16)
            make.top.equalToSuperview().offset(kStatusBarHeight+6)
            make.width.greaterThanOrEqualTo(56)
            make.height.equalTo(32)
        }
        
        myLocationBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
            make.bottom.equalTo(responseView.snp.top)
            make.size.equalTo(CGSize(width: 80, height: 80))
        }
    }
}
