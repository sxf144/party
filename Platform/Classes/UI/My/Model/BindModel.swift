//
//
//  BindResp.swift
//  constellation
//
//  Created by Lee on 2020/4/27.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON


/// 获取收支记录
class BindResp: RespModel {
    var data:BindModel?
    
    override init(_ json: JSON) {
        super.init(json)
        data = BindModel(json["data"])
    }
}

class BindModel {
    
    ///
    var bindInfo:BindInfo = BindInfo()
    
    
    init(_ json: JSON) {
        bindInfo = BindInfo(json["bind_info"])
    }
    
    init() {}
}

class BindInfo {
    
    ///
    var mobile:AdditionalProp = AdditionalProp()
    
    ///
    var wx:AdditionalProp = AdditionalProp()
    
    ///
    var apple:AdditionalProp = AdditionalProp()
    
    
    init(_ json: JSON) {
        mobile = AdditionalProp(json["mobile"])
        wx = AdditionalProp(json["wx"])
        apple = AdditionalProp(json["apple"])
    }
    
    init() {}
}

class AdditionalProp {
    
    ///
    var account:String = ""
    
    ///
    var source:String = ""
    
    
    
    init(_ json: JSON) {
        account = json["account"].stringValue
        source = json["source"].stringValue
    }
    
    init() {}
}
