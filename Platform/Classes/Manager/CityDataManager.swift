//
//  CityDataManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON
import Pinyin4Swift

fileprivate let KEY_CITY_INFO = "KEY_CITY_INFO"   //城市列表信息
fileprivate let KEY_CURR_CITY = "KEY_CURR_CITY"   //当前城市信息

class CityDataManager: NSObject {
    
    static let shared = CityDataManager()
    
    var cityInfo: CityModel?
    // 当前城市
    var currCity: CityItem?
    // 定位城市
    var locationCity: CityItem?
    
    private override init() {
        super.init()
        loadLoaclData()
    }
    
    func loadLoaclData(){
        cityInfo = getCityInfo()
        currCity = getCurrCity()
    }
    
    func defaultCity() -> CityItem {
        let city = CityItem()
        city.code = "5101"
        city.name = "成都"
        city.pinyin = PinyinHelper.getHeaderLettersWithString(city.name)
        if let firstCharacter = city.pinyin.first {
            city.headerLeater = String(firstCharacter)
        }
        
        return city
    }
}

extension CityDataManager {
    
    // 保存城市信息
    func saveCityInfo(_ cityModel: CityModel) {
        cityInfo = handleCityInfo(cityModel)
        if let cityInfo = cityInfo {
            let json = cityInfo.modelToJson()
            var data: Data?
            do {
                data = try json.rawData()
            } catch {
                
            }
            UserDefaults.standard.set(data, forKey: KEY_CITY_INFO)
        }
    }
    
    func handleCityInfo(_ cityModel:CityModel) -> CityModel {
        var tempCityInfo = cityModel
        // 处理all
        tempCityInfo.sections = getSections(tempCityInfo)
        // 处理hots
        tempCityInfo.hots = getHots(tempCityInfo)
        return tempCityInfo
    }
    
    func getSections(_ cityModel:CityModel) -> [PinyinSection] {
        /**
         * 处理成按拼音排序的section的数组
         * 1、先转换拼音
         */
        var tempAll: [CityItem] = []
        for proItem in cityModel.all {
            for cityItem in proItem.cityList {
                cityItem.pinyin = PinyinHelper.getHeaderLettersWithString(cityItem.name)
                if let firstCharacter = cityItem.pinyin.first {
                    cityItem.headerLeater = String(firstCharacter)
                }
                tempAll.append(cityItem)
            }
        }
        /**
         *
         * 2、根据拼音排序
         */
        let sortedAll = tempAll.sorted(by: <)
        /**
         *
         * 3、组成新的sections
         */
        var finalAll: [PinyinSection] = []
        var pinyinSection: PinyinSection = PinyinSection()
        for item in sortedAll {
            if pinyinSection.headerLeater != item.headerLeater {
                pinyinSection = PinyinSection()
                pinyinSection.headerLeater = item.headerLeater
                finalAll.append(pinyinSection)
            }
            pinyinSection.cityList.append(item)
        }
        
        return finalAll
    }
    
    func getHots(_ cityModel:CityModel) -> [CityItem] {
        /**
         * 处理成按拼音排序的section的数组
         * 1、先转换拼音
         */
        var finalAll: [CityItem] = []
        for cityItem in cityModel.hots {
            cityItem.pinyin = PinyinHelper.getHeaderLettersWithString(cityItem.name)
            if let firstCharacter = cityItem.pinyin.first {
                cityItem.headerLeater = String(firstCharacter)
            }
            finalAll.append(cityItem)
        }
        
        return finalAll
    }
    
    func getCityInfo() -> CityModel? {
        if (cityInfo != nil) {
            cityInfo?.locationCity = locationCity ?? CityItem()
            return cityInfo
        }
        let data = UserDefaults.standard.data(forKey: KEY_CITY_INFO)
        guard data != nil else { return nil }
        var json:JSON?
        do {
            json = try JSON(data: data!)
        } catch  {
            
        }
        if let json = json {
            cityInfo = CityModel(json)
            cityInfo?.locationCity = locationCity ?? CityItem()
            return cityInfo
        }
        return nil
    }
    
    // 保存当前城市信息
    func saveCurrCity(_ cityItem: CityItem) {
        currCity = cityItem
        if let currCity = currCity {
            let json = currCity.modelToJson()
            var data: Data?
            do {
                data = try json.rawData()
            } catch {
                
            }
            UserDefaults.standard.set(data, forKey: KEY_CURR_CITY)
        }
    }
    
    func getCurrCity() -> CityItem? {
        if (currCity != nil) {
            return currCity
        }
        let data = UserDefaults.standard.data(forKey: KEY_CURR_CITY)
        guard data != nil else { return nil }
        var json:JSON?
        do {
            json = try JSON(data: data!)
        } catch  {
            
        }
        if let json = json {
            currCity = CityItem(json)
            return currCity
        }
        return nil
    }
    
    func getCityList() {
        NetworkManager.shared.getCityList() { resp in
            if resp.status == .success {
                LSLog("getCityList data:\(resp.data)")
                // 保存城市信息
                if let cityInfo = resp.data {
                    // 获取默认城市信息
                    self.saveCityInfo(cityInfo)
                }
            } else {
                LSLog("getCityList fail")
            }
        }
    }
}


