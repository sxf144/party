//
//  MapController.swift
//  constellation
//
//  Created by Lee on 2020/4/10.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SnapKit
import AMapNaviKit
import AMapFoundationKit


class MapNavigationController: BaseController {
    
    let defaultZoomLevel: CGFloat = 15.0
    var landMark:String = ""
    var address:String = ""
    var latitude:Double = 0
    var longitude:Double = 0
    var firstLoad:Bool = true
    
    override func viewDidLoad() {
        title = "地点"
        super.viewDidLoad()
        setupUI()
        
//        AMapNaviWalkManager.sharedInstance().delegate = self
    }
    
    
    // 地图
    fileprivate lazy var myMapView: MAMapView = {
        let mapView = MAMapView(frame: view.bounds)
        mapView.delegate = self
        mapView.showsUserLocation = true
        mapView.userTrackingMode = .follow
        mapView.zoomLevel = defaultZoomLevel
        let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
        mapView.centerCoordinate = coordinate
        return mapView
    }()
    
    // 底部
    fileprivate lazy var bottomView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.layer.cornerRadius = 20
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        return view
    }()
    
    // 名称
    fileprivate lazy var addressNameLabel: UILabel = {
        let label = UILabel()
        label.font = kFontMedium16
        label.textColor = UIColor.ls_color("#333333")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 地址
    fileprivate lazy var addressDetailLabel: UILabel = {
        let label = UILabel()
        label.font = kFontRegualer12
        label.textColor = UIColor.ls_color("#aaaaaa")
        label.numberOfLines = 1
        label.lineBreakMode = .byTruncatingTail
        label.sizeToFit()
        return label
    }()
    
    // 导航
    fileprivate lazy var navigationBtn: UIButton = {
        let button = UIButton()
        button.setTitleColor(kColorTextWhite, for: .normal)
        button.titleLabel?.font = kFontMedium18
        button.layer.cornerRadius = 23
        button.clipsToBounds = true
        button.backgroundColor = UIColor.ls_color("#FE9C5B")
        button.setTitle("导航", for: .normal)
        button.addTarget(self, action: #selector(clickNavigationBtn(_:)), for: .touchUpInside)
        return button
    }()
}

extension MapNavigationController {
    
    func setData(_ landMark:String, address:String, lat:Double, lon:Double) {
        if lat == 0 || lon == 0 {
            LSHUD.showInfo("数据错误")
            return
        }
        
        self.landMark = landMark
        self.address = address
        self.latitude = lat
        self.longitude = lon
        
        // 地标
        addressNameLabel.text = self.landMark
        addressNameLabel.sizeToFit()
        
        // 地址
        addressDetailLabel.text = self.address
        addressDetailLabel.sizeToFit()
    }
    
    // 导航
    @objc func clickNavigationBtn(_ sender:UIButton) {
        LSLog("clickNavigationBtn")
        // 规划路径
//        let startLat = MyLocationManager.shared.currLocation.coordinate.latitude
//        let startLon = MyLocationManager.shared.currLocation.coordinate.longitude
//        let startPoint:AMapNaviPoint = AMapNaviPoint()
//        startPoint.latitude = startLat
//        startPoint.longitude = startLon
//        
//        let endLat = self.latitude
//        let endLon = self.longitude
//        let endPoint:AMapNaviPoint = AMapNaviPoint()
//        endPoint.latitude = endLat
//        endPoint.longitude = endLon
//        
//        let ret = AMapNaviWalkManager.sharedInstance().calculateWalkRoute(withStart: [startPoint], end: [endPoint])
//        LSLog("calculateWalkRoute ret:\(ret)")
        
        // 跳转到外部导航
        showNavigationActionSheet()
    }
    
    func showNavigationActionSheet() {
        // 创建一个UIAlertController
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        // 添加操作按钮
        let option1 = UIAlertAction(title: "高德地图", style: .default) { (action) in
            if let url = URL(string: "iosamap://navi?sourceApplication=juzitang&lat=\(self.latitude)&lon=\(self.longitude)&dev=0&style=2") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // 处理URL创建失败的情况
                LSHUD.showInfo("位置错误")
            }
        }

        let option2 = UIAlertAction(title: "百度地图", style: .default) { (action) in
            if let url = URL(string: "baidumap://map/direction?origin=latlng:0,0|name:我的位置&destination=latlng:\(self.latitude),\(self.longitude)|name:目的地&mode=driving&coord_type=gcj02") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // 处理URL创建失败的情况
                LSHUD.showInfo("位置错误")
            }
        }
        
        let option3 = UIAlertAction(title: "腾讯地图", style: .default) { (action) in
            if let url = URL(string: "qqmap://map/routeplan?type=drive&from=我的位置&fromcoord=0,0&tocoord=\(self.latitude),\(self.longitude)&to=目的地") {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                // 处理URL创建失败的情况
                LSHUD.showInfo("位置错误")
            }
        }

        let cancelAction = UIAlertAction(title: "取消", style: .cancel) { (action) in
            // 处理取消的操作
        }

        // 将操作按钮添加到UIAlertController
        alertController.addAction(option1)
        alertController.addAction(option2)
        alertController.addAction(option3)
        alertController.addAction(cancelAction)

        // 显示UIAlertController
        present(alertController, animated: true, completion: nil)
    }
}

extension MapNavigationController: MAMapViewDelegate, AMapNaviWalkManagerDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MAMapView!) {
        LSLog("mapViewDidFinishLoadingMap:\(mapView.centerCoordinate)")
        if firstLoad {
            firstLoad = false
            
            // 添加图钉
//            let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
//            let annotation = MAPointAnnotation()
//            annotation.coordinate = coordinate
//            annotation.title = "终点"
//            mapView.addAnnotation(annotation)
            
            // 添加图钉
            let coordinate = CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
            let annotation = CustomAnnotation(coordinate: coordinate, title: "终点", subtitle: "", customImage: UIImage(named: "icon_location3"))
            mapView.addAnnotation(annotation)
        }
    }
    
    func mapView(_ mapView: MAMapView!, viewFor annotation: MAAnnotation!) -> MAAnnotationView! {
        
        if annotation is CustomAnnotation {
            let reuseIdentifier = "customAnnotation"
            var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseIdentifier) as? CustomAnnotationView

            if annotationView == nil {
                annotationView = CustomAnnotationView(annotation: annotation, reuseIdentifier: reuseIdentifier)
            } else {
                annotationView!.annotation = annotation
            }

            return annotationView
        }

        return nil
    }
    
    func walkManager(onCalculateRouteSuccess walkManager: AMapNaviWalkManager) {
        LSLog("walkManager onCalculateRouteSuccess")
    }
    
    func walkManager(_ walkManager: AMapNaviWalkManager, onCalculateRouteFailure error: Error) {
        LSLog("walkManager onCalculateRouteFailure")
    }
}


extension MapNavigationController {
    
    fileprivate func setupUI() {
        
        view.addSubview(myMapView)
        view.addSubview(bottomView)
        bottomView.addSubview(addressNameLabel)
        bottomView.addSubview(addressDetailLabel)
        bottomView.addSubview(navigationBtn)
        
        myMapView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(kNavBarHeight)
            make.left.right.bottom.equalToSuperview()
        }
        
        bottomView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.bottom.equalToSuperview()
            make.height.equalTo(164)
        }
        
        addressNameLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        
        addressDetailLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(48)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
        }
        
        navigationBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(95)
            make.left.equalToSuperview().offset(18)
            make.right.equalToSuperview().offset(-18)
            make.height.equalTo(46)
        }
    }
}
