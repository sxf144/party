//
//  UserPageResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


class UserPageResp: RespModel {
    var data = UserPageModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = UserPageModel(json["data"])
    }
}

struct UserPageModel {
    
    /// 礼物
    var gift: Gift = Gift()
    /// 好友关系
    var relation: Relation = Relation()
    /// 用户信息
    var user: User = User()
    
    init(_ json: JSON) {
        gift = Gift(json["gift"])
        relation = Relation(json["relation"])
        user = User(json["user"])
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json: JSON = [
            "gift": gift.modelToJson(),
            "relation": relation.modelToJson(),
            "user": user.modelToJson()
        ]
        
        return json
    }
}

struct Gift {
    var recvGiftCnt: Int64 = 0
    var recvGiftValue: Int64 = 0
    
    init(_ json:JSON) {
        recvGiftCnt = json["recv_gift_cnt"].int64Value
        recvGiftValue = json["recv_gift_value"].int64Value
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json: JSON = [
            "recv_gift_cnt": recvGiftCnt,
            "recv_gift_value": recvGiftValue
        ]
        
        return json
    }
}

struct Relation {
    var black: Bool = true
    var fansCnt: Int64 = 0
    var follow: Bool = false
    var followCnt: Int64 = 0
    
    init(_ json:JSON) {
        black = json["black"].boolValue
        fansCnt = json["fans_cnt"].int64Value
        follow = json["follow"].boolValue
        followCnt = json["follow_cnt"].int64Value
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json: JSON = [
            "black": black,
            "fans_cnt": fansCnt,
            "follow": follow,
            "follow_cnt": followCnt
        ]
        
        return json
    }
}

struct User {
    var coinBalance: Int64 = 0
    var intro: String = ""
    var nick: String = ""
    var portrait: String = ""
    var sex: Int64 = 0
    var userId: String = ""
    
    init(_ json:JSON) {
        coinBalance = json["coin_balance"].int64Value
        intro = json["intro"].stringValue
        nick = json["nick"].stringValue
        portrait = json["portrait"].stringValue
        sex = json["sex"].int64Value
        userId = json["user_id"].stringValue
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json: JSON = [
            "coin_balance": coinBalance,
            "intro": intro,
            "nick": nick,
            "portrait": portrait,
            "sex": sex,
            "user_id": userId
        ]
        
        return json
    }
}



