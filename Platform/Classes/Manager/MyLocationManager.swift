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
    var currPlacemark: CLPlacemark?
    
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
    
    func stopLocation() {
        myLocationManager.stopUpdatingLocation()
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
        // 获取位置信息
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location) { (placemarks, error) in
            if let error = error {
                LSLog("Reverse geocoding failed with error: \(error.localizedDescription)")
                return
            }

            // 获取位置信息中的城市
            if let placemark = placemarks?.first {
                // 定位城市信息不存在，或者与当前定位的城市不同，则需要遍历更新
                var needUpdate = false
                if let cityInfo = CityDataManager.shared.getCityInfo(), cityInfo.sections.count > 0, let locality = placemark.locality {
                    if let locationCity = CityDataManager.shared.locationCity {
                        if locality != self.currPlacemark?.locality {
                            needUpdate = true
                        }
                    } else {
                        needUpdate = true
                    }
                    
                    if needUpdate {
                        var isFind = false
                        var tempCity: CityItem?
                        for sectionItem in cityInfo.sections {
                            for cityItem in sectionItem.cityList {
                                if locality.contains(cityItem.name) {
                                    tempCity = cityItem
                                    isFind = true
                                    break
                                }
                            }
                            if isFind {
                                break
                            }
                        }
                        if let tempCity = tempCity {
                            // 设置当前定位城市信息
                            CityDataManager.shared.locationCity = tempCity
                            // 判断当前选择城市是否存在，若不存在，把定位城市作为当前选择城市
                            if CityDataManager.shared.getCurrCity() == nil {
                                CityDataManager.shared.saveCurrCity(tempCity)
                            }
                        }
                    }
                }
                
                self.currPlacemark = placemark
                // 定位信息更新
                LSNotification.postLocationDidUpdate()
            }
        }
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
            finalStr = "\(String(format: "%.2f", distance))m"
        } else {
            finalStr = "\(String(format: "%.2f", distance/1000))km"
        }
        
        return finalStr
    }
}


