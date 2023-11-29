//
//  MyLocationManager.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//
/**
 地理位置
 */
import UIKit
import AMapFoundationKit
import AMapLocationKit


class MyLocationManager: NSObject {
    
    static let shared = MyLocationManager()
    lazy var myLocationManager = AMapLocationManager()
    var currLocation = CLLocation()
    
    private override init() {
        super.init()
    }
}

extension MyLocationManager {
    
    static func updatePrivacy() {
        AMapLocationManager.updatePrivacyAgree(.didAgree)
        AMapLocationManager.updatePrivacyShow(.didShow, privacyInfo: .didContain)
    }
    
    func startLocation() {
        
        myLocationManager.delegate = self
        myLocationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters // 设置定位精度
        myLocationManager.locationTimeout = 10 // 定位超时时间，单位秒
        myLocationManager.reGeocodeTimeout = 10 // 逆地理编码超时时间，单位秒
        myLocationManager.startUpdatingLocation()
    }
    
    /*
     * 计算自己两个point之间的距离
     */
    func calculateDistanceBetweenPoints(point1:CLLocation, point2:CLLocation) -> String {
        
        // 使用distance(from:)方法计算两点之间的距离，结果以米为单位
        let distance = point1.distance(from: point2)
        
        return getStrByDistance(distance: distance)
    }
    
    /*
     * 计算自己当前位置与point之间的距离
     */
    func calculateDistanceByPoint(point:CLLocation) -> String {
        
        var finalStr = ""
        
        if CLLocationCoordinate2DIsValid(currLocation.coordinate) {
            // 使用distance(from:)方法计算两点之间的距离，结果以米为单位
            let distance = currLocation.distance(from: point)
            finalStr = getStrByDistance(distance: distance)
        }
        
        return finalStr
    }
}

//MARK: - AMapLocationManagerDelegate
extension MyLocationManager: AMapLocationManagerDelegate {
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        LSLog("amapLocationManager didUpdate location:\(String(describing: location))")
        self.currLocation = location
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, didFailWithError error: Error!) {
        LSLog("amapLocationManager didFailWithError:\(String(describing: error))")
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, doRequireLocationAuth locationManager: CLLocationManager!) {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func amapLocationManager(_ manager: AMapLocationManager!, locationManagerDidChangeAuthorization locationManager: CLLocationManager!) {
        if #available(iOS 14.0, *) {
            LSLog("authorizationStatus:\(locationManager.authorizationStatus)")
            switch locationManager.authorizationStatus {
            case .authorizedWhenInUse:
                startLocation()
                break
            case .authorizedAlways:
                startLocation()
                break
            default:
                break
            }
        } else {
            // Fallback on earlier versions
        }
    }
}

fileprivate extension MyLocationManager {
    
    /*
     * 根据距离返回字符串
     */
    func getStrByDistance(distance: CLLocationDistance) -> String {
        
        var finalStr: String
        
        if (distance < 1000) {
            finalStr = "\(distance)m"
        } else {
            finalStr = "\(String(format: "%.2f", distance/1000))km"
        }
        
        return finalStr
    }
}


