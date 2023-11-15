//
//  LoginModel.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class LoginModel: NSObject {

}

class MobileLoginResp: RespModel {
    var data = UserTokenModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = UserTokenModel(json["data"])
    }
}

class QQLoginResp: RespModel {
    var data = QQLoginModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = QQLoginModel(json["data"])
    }
}

struct QQLoginModel {
    
    /// 用户OPENID
    var openid = ""
    /// 用户token
    var token = ""
    /// 用户I，全局唯一
    var userId = 0
    
    init(_ json:JSON) {
        openid = json["openid"].stringValue
        token = json["token"].stringValue
        userId = json["userId"].intValue
    }
    
    init() {}
}


class UserInfoResp: RespModel {
    var data = UserInfoModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = UserInfoModel(json["data"])
    }
}

