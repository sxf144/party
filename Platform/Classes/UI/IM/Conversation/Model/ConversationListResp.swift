//
//  ConversationListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImSDK_Plus_Swift

class ConversationListResp {
    var data = ConversationListModel()
    
    init(_ list: [V2TIMConversation]) {
        data = ConversationListModel(list)
    }
}

struct ConversationListModel {
    
    /// list
    var list: [V2TIMConversation] = []
    
    
    init(_ list: [V2TIMConversation]) {
        
    }
    
    init() {}
}







