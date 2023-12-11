//
//  UserTokenModel.swift
//  constellation
//
//  Created by Lee on 2020/4/17.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


struct UserTokenModel {
    
    /// 用户accessToken
    var accessToken = ""
    /// 用户失效时间
    var expiresIn: Int64 = 0
    /// 用户refreshToken
    var refreshToken = ""
    /// 用户scope
    var scope = ""
    /// 用户tokenType
    var tokenType = ""
    /// 用户失效到期时间，(客户端使用)
    var expireTimestamp: Int64 = 0
    
    init(_ json:JSON) {
        accessToken = json["access_token"].stringValue
        expiresIn = json["expires_in"].int64Value
        refreshToken = json["refresh_token"].stringValue
        scope = json["scope"].stringValue
        tokenType = json["token_type"].stringValue
        expireTimestamp = json["expire_timestamp"].int64Value
    }
    
    init() {}
    
    func modelToJson()->JSON{
        
        let json:JSON = [
            "access_token":accessToken,
            "expires_in":expiresIn,
            "refresh_token":refreshToken,
            "scope":scope,
            "token_type":tokenType,
            "expire_timestamp": expireTimestamp == 0 ? (Int64(Date().timeIntervalSince1970) + expiresIn) : expireTimestamp
        ]
        return json
    }
}

