//
//  CityModel.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON
import Pinyin4Swift

/// 获取订单支付结果
class CityResp: RespModel {
    var data:CityModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = CityModel(json["data"])
    }
}

class CityModel {
    
    /// 所有省、市列表
    var all: [ProvinceItem] = []
    /// 热门城市列表
    var hots: [CityItem] = []
    /// 所有拼音排序列表
    var sections: [PinyinSection] = []
    /// 定位城市
    var locationCity: CityItem = CityItem()
    
    init(_ json: JSON) {
        
        all = []
        for (_, subJson) in json["all"] {
            all.append(ProvinceItem(subJson))
        }
        
        hots = []
        for (_, subJson) in json["hots"] {
            hots.append(CityItem(subJson))
        }
        
        sections = []
        for (_, subJson) in json["sections"] {
            sections.append(PinyinSection(subJson))
        }
    }
    
    init() {}
    
    func modelToJson()->JSON{
        var jsonAll = JSON([])
        for item in all {
            jsonAll.arrayObject?.append(item.modelToJson().object)
        }
        var jsonHost = JSON([])
        for item in hots {
            jsonHost.arrayObject?.append(item.modelToJson().object)
        }
        var jsonSections = JSON([])
        for item in sections {
            jsonSections.arrayObject?.append(item.modelToJson().object)
        }
        let json: JSON = [
            "all": jsonAll,
            "hots": jsonHost,
            "sections": jsonSections,
        ]
        
        return json
    }
}

class ProvinceItem {
    
    /// 城市列表
    var cityList: [CityItem] = []
    /// 地区代码
    var code: String = ""
    /// 地区名称
    var name: String = ""
    
    init(_ json: JSON) {
        code = json["code"].stringValue
        name = json["name"].stringValue
        
        cityList = []
        for (_, subJson) in json["city_list"] {
            cityList.append(CityItem(subJson))
        }
    }
    
    init() {}
    
    func modelToJson()->JSON{
        var jsonArray = JSON([])
        for item in cityList {
            jsonArray.arrayObject?.append(item.modelToJson().object)
        }
        let json: JSON = [
            "code": code,
            "name": name,
            "city_list": jsonArray
        ]
        
        return json
    }
}

class PinyinSection {
    
    /// 城市列表
    var cityList: [CityItem] = []
    /// 拼音首字母
    var headerLeater: String = ""
    
    init(_ json: JSON) {
        headerLeater = json["headerLeater"].stringValue
        
        cityList = []
        for (_, subJson) in json["city_list"] {
            cityList.append(CityItem(subJson))
        }
    }
    
    init() {}
    
    func modelToJson()->JSON{
        var jsonArray = JSON([])
        for item in cityList {
            jsonArray.arrayObject?.append(item.modelToJson().object)
        }
        let json: JSON = [
            "headerLeater": headerLeater,
            "city_list": jsonArray
        ]
        
        return json
    }
}

class CityItem {
    
    /// 地区代码
    var code: String = ""
    /// 地区名称
    var name: String = ""
    /// 拼音
    var pinyin: String = ""
    /// 拼音首字母
    var headerLeater: String = ""
    
    init(_ json: JSON) {
        code = json["code"].stringValue
        name = json["name"].stringValue
        pinyin = json["pinyin"].stringValue
        headerLeater = json["headerLeater"].stringValue
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json: JSON = [
            "code": code,
            "name": name,
            "pinyin": pinyin,
            "headerLeater": headerLeater
        ]
        
        return json
    }
    
    static func < (lhs: CityItem, rhs: CityItem) -> Bool {
        return lhs.pinyin.localizedStandardCompare(rhs.pinyin) == .orderedAscending
    }
}
