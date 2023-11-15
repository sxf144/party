//
//  PartyDetailResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class PartyDetailResp: RespModel {
    var data = PartyDetailModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = PartyDetailModel(json["data"])
    }
}

struct PartyDetailModel {
    
    /// 地址
    var address: String?
    /// 城市地址六位编码
    var addressCode: Int64?
    /// 城市名称
    var cityName: String?
    /// 评论数
    var commentCnt: Int64?
    /// 图片或者视频
    var cover: String?
    /// 开始时间
    var startTime: String?
    /// 结束时间
    var endTime: String?
    /// 本局费用(单位：分)
    var fee: Int64?
    /// 女性数量要求
    var femaleCnt: Int64?
    /// 女性剩余数量
    var femaleRemainCount: Int64?
    /// 本轮介绍
    var introduction: String?
    /// 参与状态 0 未参与 1已参与 2待付款
    var joinState: Int64?
    /// 地标
    var landmark: String?
    /// 纬度
    var latitude: Double?
    /// 经度
    var longitude: Double?
    /// 点赞数
    var likeCnt: Int64?
    /// 男性数量要求
    var maleCnt: Int64?
    /// 男性剩余数量
    var maleRemainCount: Int64?
    /// 名字
    var name: String?
    /// 创局用户昵称
    var nick: String?
    /// 创局用户头像
    var portrait: String?
    /// 1 公开 其他人可以刷到，可以加入 0私密 其他人刷不到，只能邀请或者扫码加入
    var isPublic: Int64?
    /// 局状态 1正常 2解散 3结束
    var state: Int64?
    /// 此局唯一码
    var uniqueCode: String?
    /// 创局用户ID
    var userId: String?
    /// 关联游戏
    var relationGame: RelationGame?
    
    init(_ json:JSON) {
        address = json["address"].stringValue
        addressCode = json["address_code"].int64Value
        cityName = json["city_name"].stringValue
        commentCnt = json["comment_cnt"].int64Value
        cover = json["cover"].stringValue
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        fee = json["fee"].int64Value
        femaleCnt = json["female_cnt"].int64Value
        femaleRemainCount = json["female_remain_count"].int64Value
        introduction = json["introduction"].stringValue
        joinState = json["join_state"].int64Value
        landmark = json["landmark"].stringValue
        latitude = json["latitude"].doubleValue
        longitude = json["longitude"].doubleValue
        likeCnt = json["like_cnt"].int64Value
        maleCnt = json["male_cnt"].int64Value
        maleRemainCount = json["male_remain_count"].int64Value
        name = json["name"].stringValue
        nick = json["nick"].stringValue
        portrait = json["portrait"].stringValue
        isPublic = json["public"].int64Value
        state = json["state"].int64Value
        uniqueCode = json["unique_code"].stringValue
        userId = json["user_id"].stringValue
        relationGame = RelationGame(json["relation_game"])
        
    }
    
    init() {}
}

struct RelationGame {
    var gameId: Int64
    var cover: String
    var gameStatus: Int64
    var interactPersonCount: Int64
    var introduction: String
    var name: String
    var personCountMax: Int64
    var personCountMin: Int64
    var sceneId: Int64
    
    init(_ json:JSON) {
        gameId = json["game_id"].int64Value
        cover = json["cover"].stringValue
        gameStatus = json["game_status"].int64Value
        interactPersonCount = json["interact_person_count"].int64Value
        introduction = json["introduction"].stringValue
        name = json["name"].stringValue
        personCountMax = json["person_count_max"].int64Value
        personCountMin = json["person_count_min"].int64Value
        sceneId = json["scene_id"].int64Value
    }
}



