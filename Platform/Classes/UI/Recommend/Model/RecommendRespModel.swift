//
//  RecommendResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class RecommendResp: RespModel {
    var data = RecommendModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = RecommendModel(json["data"])
    }
}

struct RecommendModel {
    
    /// 起始时间
    var cursorTime: String = ""
    /// 是否有更多
    var hasMore: Bool = true
    /// items
    var items: [RecommendItem]?
    /// ongoing
    var ongoing:Ongoing?
    
    
    init(_ json:JSON) {
        cursorTime = json["cursor_time"].stringValue
        hasMore = json["has_more"].boolValue
        ongoing = Ongoing(json["ongoing"])
        items = []
        for (_, subJson) in json["items"] {
            items?.append(RecommendItem(subJson))
        }
    }
    
    init() {}
}

struct RecommendItem {
    var address: String = ""
    var commentCnt: Int = 0
    var cover: String = ""
    var coverThumbnail: String = ""
    var coverType: Int = 0
    var introduction: String = ""
    var landmark: String = ""
    var latitude:Double = 0
    var longitude: Double = 0
    var likeCnt: Int = 0
    var like: Bool = true
    var nick: String = ""
    var playName: String = ""
    var portrait: String = ""
    var uniqueCode: String = ""
    var userId: String = ""
    var startTime: String = ""
    var endTime: String = ""
    
    init(_ json:JSON) {
        address = json["address"].stringValue
        commentCnt = json["comment_cnt"].intValue
        cover = json["cover"].stringValue
        coverThumbnail = json["cover_thumbnail"].stringValue
        coverType = json["cover_type"].intValue
        introduction = json["introduction"].stringValue
        landmark = json["landmark"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        likeCnt = json["like_cnt"].intValue
        like = json["like"].boolValue
        nick = json["nick"].stringValue
        playName = json["play_name"].stringValue
        portrait = json["portrait"].stringValue
        uniqueCode = json["unique_code"].stringValue
        userId = json["user_id"].stringValue
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
    }
}

struct Ongoing {
    var address: String = ""
    var cityName: String = ""
    var cover: String = ""
    var coverThumbnail: String = ""
    var coverType: Int = 0
    var endTime: String = ""
    var femaleCnt: Int = 0
    var femaleRemainCount: Int = 0
    var introduction: String = ""
    var landmark: String = ""
    var latitude: Double = 0
    var longitude: Double = 0
    var maleCnt: Int = 0
    var maleRemainCount: Int = 0
    var name: String = ""
    var startTime: String = ""
    var state: Int = 0
    var uniqueCode: String = ""
    var userId: String = ""
    
    init(_ json:JSON) {
        address = json["address"].stringValue
        cityName = json["city_name"].stringValue
        cover = json["cover"].stringValue
        coverThumbnail = json["cover_thumbnail"].stringValue
        coverType = json["cover_type"].intValue
        endTime = json["end_time"].stringValue
        femaleCnt = json["female_cnt"].intValue
        femaleRemainCount = json["female_remain_count"].intValue
        introduction = json["introduction"].stringValue
        landmark = json["landmark"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        maleCnt = json["male_cnt"].intValue
        maleRemainCount = json["male_remain_count"].intValue
        name = json["name"].stringValue
        startTime = json["start_time"].stringValue
        state = json["state"].intValue
        uniqueCode = json["unique_code"].stringValue
        userId = json["user_id"].stringValue
    }
}



