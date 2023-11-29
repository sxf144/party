//
//  MyPartyResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class MyPartyResp: RespModel {
    var data = MyPartyModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = MyPartyModel(json["data"])
    }
}

struct MyPartyModel {
    
    /// 页数
    var pageNum: Int64 = 1
    /// 每页数量
    var pageSize: Int64 = 10
    /// 总页数
    var pageTotal: Int64 = 1
    /// 总页数
    var totalCount: Int64 = 10
    /// plays
    var plays: [PartyItem] = []
    
    
    init(_ json:JSON) {
        pageNum = json["page_num"].int64Value
        pageSize = json["page_size"].int64Value
        pageTotal = json["page_total"].int64Value
        totalCount = json["total_count"].int64Value
        plays = []
        for (_, subJson) in json["plays"] {
            plays.append(PartyItem(subJson))
        }
    }
    
    init() {}
}

struct PartyItem {
    
    var userId: String = ""
    var uniqueCode: String = ""
    var name: String = ""
    var landmark: String = ""
    var introduction: String = ""
    var address: String = ""
    var cityName: String = ""
    var cover: String = ""
    var coverThumbnail: String = ""
    var coverType: Int64 = 0
    var startTime: String = ""
    var endTime: String = ""
    var maleCnt: Int64 = 0
    var maleRemainCount: Int64 = 0
    var femaleCnt: Int64 = 0
    var femaleRemainCount: Int64 = 0
    var latitude: Double = 0
    var longitude: Double = 0
    var state: Int64 = 0    //局状态 1正常 2解散 3结束
    var firstInvalid:Bool = false
    
    init(_ json:JSON) {
        userId = json["user_id"].stringValue
        uniqueCode = json["unique_code"].stringValue
        name = json["name"].stringValue
        landmark = json["landmark"].stringValue
        introduction = json["introduction"].stringValue
        address = json["address"].stringValue
        cityName = json["city_name"].stringValue
        cover = json["cover"].stringValue
        coverThumbnail = json["cover_thumbnail"].stringValue
        coverType = json["cover_type"].int64Value
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        maleCnt = json["male_cnt"].int64Value
        maleRemainCount = json["male_remain_count"].int64Value
        femaleCnt = json["female_cnt"].int64Value
        femaleRemainCount = json["female_remain_count"].int64Value
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        state = json["state"].int64Value
    }
    
    init() {}
}





