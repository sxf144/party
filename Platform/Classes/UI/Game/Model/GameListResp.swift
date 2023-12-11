//
//  GameListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class GameListResp: RespModel {
    var data = GameListModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = GameListModel(json["data"])
    }
    
    static func defaultGameItem() -> GameItem {
        var gameItem = GameItem()
        gameItem.name = "无游戏/稍后选择"
        gameItem.personCountMin = 2
        gameItem.personCountMax = 20
        return gameItem
    }
}

struct GameListModel {
    
    /// 页数
    var pageNum: Int = 1
    /// 每页数量
    var pageSize: Int = 10
    /// 总页数
    var pageTotal: Int = 1
    /// 总页数
    var totalCount: Int = 10
    /// items
    var items: [GameItem] = []
    
    
    init(_ json:JSON) {
        pageNum = json["page_num"].intValue
        pageSize = json["page_size"].intValue
        pageTotal = json["page_total"].intValue
        totalCount = json["total_count"].intValue
        items = []
        for (_, subJson) in json["items"] {
            items.append(GameItem(subJson))
        }
    }
    
    init() {}
}

struct GameItem {
    
    var cover: String = ""
    var createTime: String = ""
    var id: Int64 = 0
    var interactPersonCount: Int64 = 0
    var introduction: String = ""
    var name: String = ""
    var personCountMax: Int64 = 0
    var personCountMin: Int64 = 0
    var sort: Int64 = 0
    var state: Int64 = 0
    var selected: Bool = false
    
    init(_ json:JSON) {
        cover = json["cover"].stringValue
        createTime = json["create_time"].stringValue
        id = json["id"].int64Value
        interactPersonCount = json["interact_person_count"].int64Value
        introduction = json["introduction"].stringValue
        name = json["name"].stringValue
        personCountMax = json["person_count_max"].int64Value
        personCountMin = json["person_count_min"].int64Value
        sort = json["sort"].int64Value
        state = json["state"].int64Value
    }
    
    init() {}
}





