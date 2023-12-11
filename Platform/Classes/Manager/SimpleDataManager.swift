//
//  SimpleDataManager.swift
//  constellation
//
//  Created by Lee on 2020/4/13.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit

class SimpleDataManager: NSObject {
    
    static let shared = SimpleDataManager()
    
    var localRedPacketStatus: [String: Any] = [String: Any]()
    var localC2CMsgCount: [String: Any] = [String: Any]()
    
    private override init() {
        super.init()
        loadLoaclData()
    }
    
    func loadLoaclData(){
        localRedPacketStatus = UserDefaults.standard.dictionary(forKey: REDPACKET_RECORD) ?? [String: Any]()
        localC2CMsgCount = UserDefaults.standard.dictionary(forKey: C2C_RECORD) ?? [String: Any]()
    }
}

extension SimpleDataManager {
    
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
    
    // 保存发送私聊信息
    func saveC2CMsgCountById(_ id: String) {
        if id.isEmpty {
            return
        }
        
        let dateStr = Date().ls_formatterStr()
        let keyUser: String = "\(id)\(dateStr)"
        let keyTotal: String = "\(dateStr)"
        LSLog("saveC2CMsgCountById keyUser:\(keyUser), keyTotal:\(keyTotal)")
        var dic: [String: Any] = UserDefaults.standard.dictionary(forKey: C2C_RECORD) ?? [String: Any]()
        if let countUser:Int = dic[keyUser] as? Int {
            dic[keyUser] = countUser + 1
        } else {
            dic[keyUser] = 1
        }
        if let countTotal:Int = dic[keyTotal] as? Int {
            dic[keyTotal] = countTotal + 1
        } else {
            dic[keyTotal] = 1
        }
        localC2CMsgCount = dic
        UserDefaults.standard.set(dic, forKey: C2C_RECORD)
    }
    
    func getC2CMsgCountById(_ id: String) -> Int {
        
        if localC2CMsgCount.count == 0 {
            localC2CMsgCount = UserDefaults.standard.dictionary(forKey: C2C_RECORD) ?? [String: Any]()
        }
        let dateStr = Date().ls_formatterStr()
        let key: String = "\(id)\(dateStr)"
        var count: Int = 0
        if localC2CMsgCount.count > 0, !key.isEmpty {
            if let obj:Int = localC2CMsgCount[key] as? Int {
                count = obj
            } else {
                count = 0
            }
        }
        return count
    }
    
    func getC2CMsgTotalCount() -> Int {
        
        if localC2CMsgCount.count == 0 {
            localC2CMsgCount = UserDefaults.standard.dictionary(forKey: C2C_RECORD) ?? [String: Any]()
        }
        let dateStr = Date().ls_formatterStr()
        let key: String = "\(dateStr)"
        var count: Int = 0
        if localC2CMsgCount.count > 0, !key.isEmpty {
            if let obj:Int = localC2CMsgCount[key] as? Int {
                count = obj
            } else {
                count = 0
            }
        }
        return count
    }
    
    func isCanC2CMsgById(_ id: String) -> Bool {
        if (id.isEmpty) {
            return false
        }
        if localC2CMsgCount.count == 0 {
            localC2CMsgCount = UserDefaults.standard.dictionary(forKey: C2C_RECORD) ?? [String: Any]()
        }
        let dateStr = Date().ls_formatterStr()
        let keyUser: String = "\(id)\(dateStr)"
        let keyTotal: String = "\(dateStr)"
        
        var countUser: Int = 0
        if localC2CMsgCount.count > 0, !keyUser.isEmpty {
            if let obj:Int = localC2CMsgCount[keyUser] as? Int {
                countUser = obj
            } else {
                countUser = 0
            }
        }
        var countTotal: Int = 0
        if localC2CMsgCount.count > 0, !keyTotal.isEmpty {
            if let obj:Int = localC2CMsgCount[keyTotal] as? Int {
                countTotal = obj
            } else {
                countTotal = 0
            }
        }
        
        return countUser < 1 && countTotal < 10
    }
}


