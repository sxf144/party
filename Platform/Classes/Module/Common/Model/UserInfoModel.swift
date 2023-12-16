//
//  UserInfoModel.swift
//  constellation
//
//  Created by Lee on 2020/4/17.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

enum UserGender:Int {
    case unknown = 0
    case male = 1
    case female = 2
}

/// 用户类型
enum UserType: Int{
    case unknown = -1
}

enum UserBgObjectType: Int{
    case image = 101
    case video = 102
}



class UserInfoModel {
    
    /// IM标识
    var userSig:String = ""
    /// IM标识过期时间
    var expiresIn:Int64 = 0
    /// IM标识过期时间戳
    var expireTimestamp:Int64 = 0
    /// 用户简介
    var intro:String = ""
    /// 用户手机号码
    var mobile:String = ""
    /// 用户昵称
    var nick:String = ""
    /// 年龄
    var portrait:String = ""
    /// 注册时间
    var registerTime:String = ""
    /// 性别
    var sex:Int64 = 0
    /// 用户id
    var userId:String = ""
    
    
    init(_ json:JSON) {
        userSig = json["im"]["user_sig"].stringValue
        expiresIn = json["im"]["expires_in"].int64Value
        expireTimestamp = json["expire_timestamp"].int64Value
        intro = json["user"]["intro"].stringValue
        mobile = json["user"]["mobile"].stringValue
        nick = json["user"]["nick"].stringValue
        portrait = json["user"]["portrait"].stringValue
        registerTime = json["user"]["register_time"].stringValue
        sex = json["user"]["sex"].int64Value
        userId = json["user"]["user_id"].stringValue
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json:JSON = [
            "im": ["user_sig": userSig,
                   "expires_in": expiresIn,
                   "expire_timestamp": expireTimestamp],
            "user": ["intro": intro,
                     "mobile": mobile,
                     "nick": nick,
                     "portrait": portrait,
                     "register_time": registerTime,
                     "sex": sex,
                     "user_id": userId]]
        return json
    }
}

/// 用户形象
class UserBgObject {
    /// Oss对象存储ID
    var ossObjId = ""
    /// 对象类型，101：图片；102：视频
    var type:UserBgObjectType = .image
    
    init(_ json: JSON) {
        ossObjId = json["ossObjId"].stringValue
        type = UserBgObjectType(rawValue: json["type"].int ?? 101) ?? .image
    }
    
    func modelToJson()->JSON{
        let json:JSON = [
            "ossObjId":ossObjId,
            "type":type.rawValue
        ]
        return json
    }
    
}

class QQInfoModel {
    
    var openId = ""
    var nickName = ""
    var gender: UserGender = .unknown
    var headUrl = ""
}

class SimpleUserInfo {
    
    /// 用户ID
    var userId: String = ""
    /// 头像
    var portrait: String = ""
    /// 昵称
    var nick: String = ""
    /// 性别
    var sex: Int64 = 0
    /// 加入时间
    var joinTime: String = ""
    /// 用户签名
    var selfSignature: String = ""
    /// 选中状态
    var selected: Bool = false
    
    
    init(_ json:JSON) {
        userId = json["user_id"].stringValue
        portrait = json["portrait"].stringValue
        nick = json["nick"].stringValue
        sex = json["sex"].int64Value
        joinTime = json["join_time"].stringValue
        selfSignature = json["self_signature"].stringValue
        selected = json["selected"].boolValue
    }
    
    init() {}
}
