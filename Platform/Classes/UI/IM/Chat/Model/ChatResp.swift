//
//  ChatResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImSDK_Plus_Swift

class ChatResp {
    var data = ChatModel()
    
    init(_ list: [V2TIMConversation]) {
        data = ChatModel(list)
    }
}

struct ChatModel {
    
    /// list
    var list: [V2TIMConversation] = []
    
    
    init(_ list: [V2TIMConversation]) {
        
    }
    
    init() {}
}







