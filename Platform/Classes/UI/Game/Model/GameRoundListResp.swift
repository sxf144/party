//
//  GameRoundListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class GameRoundListResp: RespModel {
    var data = GameRoundListModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = GameRoundListModel(json["data"])
    }
}

class GameRoundListModel {
    
    /// rounds
    var rounds: [GameRoundItem] = []
    
    init(_ json:JSON) {
        rounds = []
        for (_, subJson) in json["rounds"] {
            rounds.append(GameRoundItem(subJson))
        }
    }
    
    init() {}
}

class GameRoundItem {
    
    /// 轮次ID
    var id: Int64 = 0
    /// 轮次类别 0依次抽卡 1依次发红包
    var roundType: Int64 = 0
    /// 展示时长
    var showSeconds: Int64 = 0
    /// 标题
    var title: String = ""
    /// 介绍
    var introduction: String = ""
    /// 图片或视频
    var introductionMedia: String = ""
    /// cards
    var cards: [GameCardItem] = []
    
    init(_ json:JSON) {
        id = json["id"].int64Value
        roundType = json["round_type"].int64Value
        showSeconds = json["show_seconds"].int64Value
        title = json["title"].stringValue
        introduction = json["introduction"].stringValue
        introductionMedia = json["introduction_media"].stringValue
        cards = []
        for (_, subJson) in json["cards"] {
            cards.append(GameCardItem(subJson))
        }
    }
    
    init() {}
}

class GameCardItem {
    
    /// 卡牌ID
    var id: Int64 = 0
    /// 难度 1简单 2中等 3困难
    var difficulty: Int64 = 0
    /// 需要道具 1需要 2不需要
    var needProps: Int64 = 0
    /// 需要多人才能完成
    var needPersonCnt: Int64 = 0
    /// 名字
    var name: String = ""
    /// 任务图片或视频
    var introductionMedia: String = ""
    /// 轮次
    var index: Int = 0
    /// 选中状态
    var selected: Bool = true
    
    init(_ json:JSON) {
        id = json["id"].int64Value
        difficulty = json["difficulty"].int64Value
        needProps = json["need_props"].int64Value
        needPersonCnt = json["need_person_cnt"].int64Value
        name = json["name"].stringValue
        introductionMedia = json["introduction_media"].stringValue
    }
    
    init() {}
}





