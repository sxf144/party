//
//  RedPacketManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class RedPacketManager: NSObject {
    
    static let shared = RedPacketManager()
    
    var localRedPacketStatus: [String: Any] = [String: Any]()
    
    private override init() {
        super.init()
        loadLoaclData()
    }
    
    func loadLoaclData(){
        localRedPacketStatus = UserDefaults.standard.dictionary(forKey: REDPACKET_RECORD) ?? [String: Any]()
    }
}

extension RedPacketManager {
    
    // 保存红包领取信息
    func saveRedPacketStatusById(_ id: Int64) {
        let key: String = String(id)
        var dic: [String: Any] = UserDefaults.standard.dictionary(forKey: REDPACKET_RECORD) ?? [String: Any]()
        dic[key] = 1
        localRedPacketStatus = dic
        UserDefaults.standard.set(dic, forKey: REDPACKET_RECORD)
    }
    
    func getRedPacketStatusById(_ id: Int64) -> Int {
        
        if localRedPacketStatus.count == 0 {
            localRedPacketStatus = UserDefaults.standard.dictionary(forKey: REDPACKET_RECORD) ?? [String: Any]()
        }
        
        let key: String = String(id)
        var status: Int = 0
        if localRedPacketStatus.count > 0, !key.isEmpty {
            if let value = localRedPacketStatus[key] {
                status = value as! Int
            }
        }
        return status
    }
}


