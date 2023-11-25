//
//  LIMModel.swift
//  constellation
//
//  Created by Lee on 2020/4/15.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON
import ImSDK_Plus_Swift

public enum LIMConversationType: Int {
    
    case LIM_UNKNOWN

    case LIM_C2C

    case LIM_GROUP
}

public enum LIMElemType: String {
    
    case LIMElemNone = "None"
    
    case LIMElemText = "Text"
    
    case LIMElemImage = "Image"
    
    case LIMElemGroupTips = "GroupTips"
    
    case LIMElemGift = "Gift"
    
    case LIMElemInvite = "PlayInvite"
    
    case LIMElemRedPacket = "RedPacket"
    
    case LIMElemSystemMsg = "SystemMsg"
    
    case LIMElemGameStatusSync = "GameStatusSync"
    
}

public enum LIMGameStatus: Int {
    
    case LIMGameStatusNone = 0
    
    case LIMGameStatusStory = 1
    
    case LIMGameStatusCard = 2
    
    case LIMGameStatusRedPacket = 3
    
    case LIMGameStatusEnd = -1
    
}

/// 系统消息
public class LIMSysElem {
    
    /// content
    var content:String = ""
    
    init(_ json: JSON) {
        content = json["content"].stringValue
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "content": content,
        ]
        return json
    }
}

/// 礼物消息
public class LIMGiftElem {
    
    /// id
    var giftId:Int64 = 0
    /// name
    var name:String = ""
    /// icon
    var icon:String = ""
    /// 赠送者
    var fromAccount:String = ""
    /// 接受者
    var toAccount:String = ""
    /// 接受者名字
    var toUserName:String = ""
    
    
    init(_ json: JSON) {
        giftId = json["gift_id"].int64Value
        name = json["name"].stringValue
        icon = json["icon"].stringValue
        fromAccount = json["from_account"].stringValue
        toAccount = json["to_account"].stringValue
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "gift_id": giftId,
            "name": name,
            "icon": icon,
            "from_account": fromAccount,
            "to_account": toAccount
        ]
        return json
    }
}

/// 红包消息
public class LIMRedPacketElem {
    
    /// id
    var id:Int64 = 0
    /// 红包金额
    var amount:Int64 = 0
    /// 红包数量
    var count:Int64 = 0
    /// 过期时间
    var expireTime:String = ""
    /// 领取方式：1、拼手气；2、平分
    var getType:Int64 = 0
    /// 接受者ID
    var toUserId:String = ""
    /// 群红包时表示群ID
    var uniqueCode:String = ""
    /// 红包领取状态，0为未领取，1为领取
    var status:Int = 0
    
    init() {}
    
    init(_ json: JSON) {
        id = json["id"].int64Value
        amount = json["amount"].int64Value
        count = json["count"].int64Value
        expireTime = json["expire_time"].stringValue
        getType = json["get_type"].int64Value
        toUserId = json["to_user_id"].stringValue
        uniqueCode = json["unique_code"].stringValue
    }
    
    func modelToJson()->JSON{
        let json:JSON = [
            "id": id,
            "amount": amount,
            "count": count,
            "expire_time": expireTime,
            "get_type": getType,
            "to_user_id": toUserId,
            "unique_code": uniqueCode
        ]
        return json
    }
}

/// 邀请消息
public class LIMInviteElem {
    
    /// 发起人ID
    var userId:String = ""
    /// 发起人名称
    var userName:String = ""
    /// 被邀请者ID
    var toUserId:String = ""
    /// 被邀请者名称
    var toUserName:String = ""
    /// 局名称
    var name:String = ""
    /// 群时表示群ID
    var uniqueCode:String = ""
    /// 开始时间
    var startTime:String = ""
    /// 结束时间
    var endTime:String = ""
    /// 封面图
    var coverThumbnail:String = ""
    
    
    init() {}
    
    init(_ json: JSON) {
        userId = json["user_id"].stringValue
        toUserId = json["to_user_id"].stringValue
        name = json["name"].stringValue
        uniqueCode = json["unique_code"].stringValue
        startTime = json["start_time"].stringValue
        endTime = json["end_time"].stringValue
        coverThumbnail = json["cover_thumbnail"].stringValue
    }
    
    func modelToJson()->JSON{
        let json:JSON = [
            "user_id": userId,
            "to_user_id": toUserId,
            "name": name,
            "unique_code": uniqueCode,
            "start_time": startTime,
            "end_time": endTime,
            "cover_thumbnail": coverThumbnail,
        ]
        return json
    }
}

/// 游戏消息
public class LIMGameElem {
    
    /// 现场ID
    var sceneId:Int64 = 0
    /// 任务ID
    var taskId:Int64 = 0
    /// 群主持人ID
    var adminUserId:String = ""
    /// GameStatusActionInfo
    var action:GameActionInfo = GameActionInfo()
    /// 状态，0未完成，1完成
    var status:Int = 1
    
    init(_ json: JSON) {
        sceneId = json["scene_id"].int64Value
        taskId = json["task_id"].int64Value
        adminUserId = json["admin_user_id"].stringValue
        action = GameActionInfo(json["action"])
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "scene_id": sceneId,
            "task_id": taskId,
            "admin_user_id": adminUserId,
            "action": action.modelToJson()
        ]
        return json
    }
}

/// 游戏行为
public class GameActionInfo {
    /// 行为ID
    var actionId:LIMGameStatus = .LIMGameStatusNone
    /// 卡牌信息
    var cardInfo:CardInfo = CardInfo()
    /// 轮次信息
    var roundInfo:RoundInfo = RoundInfo()
    /// 用户ID集合
    var teamUserIds:[String] = []
    
    
    init(_ json: JSON) {
        let aid = json["action_id"].int64Value
        switch aid {
        case 1:
            actionId = .LIMGameStatusStory
            break
        case 2:
            actionId = .LIMGameStatusCard
            break
        case 3:
            actionId = .LIMGameStatusRedPacket
            break
        case -1:
            actionId = .LIMGameStatusEnd
            break
        default:
            actionId = .LIMGameStatusNone
            break
        }
        
        cardInfo = CardInfo(json["card_info"])
        roundInfo = RoundInfo(json["round_info"])
        teamUserIds = json["team_user_ids"].rawValue as! [String]
//        for (_, subJson) in json["team_user_ids"] {
//            teamUserIds.append(subJson.rawValue)
//        }
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "action_id": actionId,
            "card_info": cardInfo.modelToJson(),
            "round_info": roundInfo.modelToJson(),
            "team_user_ids": teamUserIds
        ]
        return json
    }
}

/// 卡牌信息
public class CardInfo {
    /// 卡牌ID
    var id:Int64 = 0
    /// 名称
    var name:String = ""
    /// 难度 1简单 2中等 3困难
    var difficulty:Int64 = 0
    /// 0未知 1 图片 2 视频
    var introductionMediaType:Int64 = 0
    /// 任务图片或视频
    var introductionMedia:String = ""
    /// 封面缩略图
    var introductionThumbnail:String = ""
    /// 需要多人才能完成
    var needPersonCnt:Int64 = 0
    /// 需要道具 1需要 2不需要
    var needProps:Int64 = 0
    
    init(_ json: JSON) {
        id = json["id"].int64Value
        name = json["name"].stringValue
        difficulty = json["difficulty"].int64Value
        introductionMediaType = json["introduction_media_type"].int64Value
        introductionMedia = json["introduction_media"].stringValue
        introductionThumbnail = json["introduction_thumbnail"].stringValue
        needPersonCnt = json["need_person_cnt"].int64Value
        needProps = json["need_props"].int64Value
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "id": id,
            "name": name,
            "difficulty": difficulty,
            "introduction_media_type": introductionMediaType,
            "introduction_media": introductionMedia,
            "introduction_thumbnail": introductionThumbnail,
            "need_person_cnt": needPersonCnt,
            "need_props": needProps
        ]
        return json
    }
}

/// 轮次信息
public class RoundInfo {
    /// 标题
    var title:String = ""
    /// 介绍
    var introduction:String = ""
    /// 图片或视频
    var introductionMedia:String = ""
    /// 时长
    var showSeconds:Int64 = 0
    
    init(_ json: JSON) {
        title = json["title"].stringValue
        introduction = json["introduction"].stringValue
        introductionMedia = json["introduction_media"].stringValue
        showSeconds = json["show_seconds"].int64Value
    }
    
    init() {}
    
    func modelToJson()->JSON{
        let json:JSON = [
            "title": title,
            "introduction": introduction,
            "introduction_media": introductionMedia,
            "show_seconds": showSeconds
        ]
        return json
    }
}

public class LIMConversation {
    
    public init() {}
    
    /// 原始数据
    public var originConversation:V2TIMConversation?
    
    /// Conversation type.
    public var type: LIMConversationType = .LIM_UNKNOWN

    /// Unique ID of a conversation. For one-to-one chats, the value format is String.format("c2c_%s", "userID"). For group chats, the value format is String.format("group_%s", "groupID").
    public var conversationID: String?

    /// If the conversation type is one-to-one chat, the userID stores the user ID of the peer; otherwise, the userID is nil
    public var userID: String?

    /// If the conversation type is group chat, the groupID stores the current group ID; otherwise, the groupID is nil
    public var groupID: String?

    /// Group type of a conversation (valid for group conversations only)
    public var groupType: String?

    /// Display name of a conversation. Conversation display name priorities are as follows:
    /// - Group: group name -> group ID
    /// - One-to-one: peer's remarks -> peer's nickname -> peer's userID
    public var showName: String?

    /// Conversation display profile photo.
    /// - Group: group profile photo
    /// - One-to-one: peer's profile photo
    public var faceUrl: String?

    /// Count of unread messages in a conversation.
    public var unreadCount: Int = 0
    
    /// lastMessage
    public var lastMessage:LIMMessage = LIMMessage()
    
    /// Draft information, please call setConversationDraft() API to set draft information
    public var draftText: String?
    
    /// UTC timestamp when the draft was last set
    public var draftTimestamp: Date?
    
}

public class LIMMessage {
    
    public init() {}
    
    /// originMessage
    public var originMessage: V2TIMMessage?
    
    /// userId
    public var userID: String?
    
    /// groupId
    public var groupID: String?
    
    /// is group message
    public var isGroupMsg: Bool?
    
    /// is self
    public var isSelf: Bool?
    
    /// msgID
    public var msgID: String?
    
    /// sender
    public var sender: String?
    
    /// nick name
    public var nickName: String?
    
    /// face url
    public var faceURL: String?
    
    /// timestamp
    public var timestamp: Date?
    
    /// isRead
    public var isRead: Bool?
    
    /// Message type
    public var elemType: LIMElemType = .LIMElemNone
    
    /// If the message type is LIMTextElem, textElem stores the content of the text message.
    public var textElem: V2TIMTextElem?
    
    /// If the message type is LIMImageElem, imageElem stores the content of the image message.
    public var imageElem: V2TIMImageElem?
    
    /// If the message type is LIMGroupTipsElem, groupTipsElem stores the content of the group tip message.
    public var groupTipsElem: V2TIMGroupTipsElem?
    
    /// If the message type is LIMGift, giftElem stores the content of the gift message.
    public var giftElem: LIMGiftElem?
    
    /// If the message type is LIMInviteElem, inviteElem stores the content of the play invite message.
    public var inviteElem: LIMInviteElem?
    
    /// If the message type is LIMRedPacket, redPacketElem stores the content of the red packet message.
    public var redPacketElem: LIMRedPacketElem?
    
    /// If the message type is LIMSystemMsg, sysElem stores the content of the system message.
    public var sysElem: LIMSysElem?
    
    /// If the message type is LIMGameStatusSync, gameElem stores the content of the game message.
    public var gameElem: LIMGameElem?
}

class LIMModel: NSObject {
    
    /// TIMMsgToLIMMsg
    static func TIMConvToLIMConv(_ timConv:V2TIMConversation?) -> LIMConversation {
        
        let limConv:LIMConversation = LIMConversation()
        if let conv = timConv {
            limConv.originConversation = conv
            limConv.type = conv.type == .V2TIM_C2C ? .LIM_C2C : conv.type == .V2TIM_GROUP ? .LIM_GROUP : .LIM_UNKNOWN
            limConv.conversationID = conv.conversationID
            limConv.userID = conv.userID
            limConv.groupID = conv.groupID
            limConv.groupType = conv.groupType
            limConv.showName = conv.showName
            limConv.faceUrl = conv.faceUrl
            limConv.unreadCount = conv.unreadCount
            limConv.lastMessage = LIMModel.TIMMsgToLIMMsg(conv.lastMessage)
        }
        
        return limConv
    }
    
    /// TIMMsgToLIMMsg
    static func TIMMsgToLIMMsg(_ timMsg:V2TIMMessage?) -> LIMMessage {
        
        let limMessage:LIMMessage = LIMMessage()
        if let msg = timMsg {
            limMessage.originMessage = msg
            limMessage.msgID = msg.msgID
            limMessage.userID = msg.userID
            limMessage.groupID = msg.groupID
            limMessage.isGroupMsg = msg.userID?.isEmpty
            limMessage.isSelf = msg.isSelf
            limMessage.sender = msg.sender
            limMessage.nickName = msg.nickName
            limMessage.faceURL = msg.faceURL
            limMessage.timestamp = msg.timestamp
            switch msg.elemType {
                case .V2TIM_ELEM_TYPE_TEXT:
                    limMessage.elemType = LIMElemType.LIMElemText
                    limMessage.textElem = msg.textElem
                    break
                case .V2TIM_ELEM_TYPE_IMAGE:
                    limMessage.elemType = LIMElemType.LIMElemImage
                    limMessage.imageElem = msg.imageElem
                    break
                case .V2TIM_ELEM_TYPE_GROUP_TIPS:
                    limMessage.elemType = LIMElemType.LIMElemGroupTips
                    limMessage.groupTipsElem = msg.groupTipsElem
                    break
                case .V2TIM_ELEM_TYPE_CUSTOM:
                    let json:JSON = JSON(msg.customElem?.data ?? "")
                    let subType:String = json["type"].rawValue as! String
                    switch subType {
                        
                        case LIMElemType.LIMElemGift.rawValue:
                            limMessage.elemType = LIMElemType.LIMElemGift
                            limMessage.giftElem = LIMGiftElem(json["data"])
                            break
                        case LIMElemType.LIMElemInvite.rawValue:
                            limMessage.elemType = LIMElemType.LIMElemInvite
                            limMessage.inviteElem = LIMInviteElem(json["data"])
                            break
                        case LIMElemType.LIMElemRedPacket.rawValue:
                            limMessage.elemType = LIMElemType.LIMElemRedPacket
                            limMessage.redPacketElem = LIMRedPacketElem(json["data"])
                            break
                        case LIMElemType.LIMElemSystemMsg.rawValue:
                            limMessage.elemType = LIMElemType.LIMElemSystemMsg
                            limMessage.sysElem = LIMSysElem(json["data"])
                            break
                        case LIMElemType.LIMElemGameStatusSync.rawValue:
                            limMessage.elemType = LIMElemType.LIMElemGameStatusSync
                            limMessage.gameElem = LIMGameElem(json["data"])
                            break
                        
                        default:
                            break
                    }
                    
                    break
                
                default:
                    break
            }
        }
        
        return limMessage
    }
    
    // 获取群组提示内容
    static func GetGroupTipsContent(_ groupTipsElem:V2TIMGroupTipsElem?) -> String {
        var str = ""
        if let groupTipsElem = groupTipsElem {
            if let memberList = groupTipsElem.memberList {
                for obj in memberList {
                    str = str + " \"" + (obj.nickName ?? "") + "\""
                }
            }
            switch groupTipsElem.type {
                case .V2TIM_GROUP_TIPS_TYPE_JOIN, .V2TIM_GROUP_TIPS_TYPE_INVITE:
                    str = str + "已加入"
                    break
                case .V2TIM_GROUP_TIPS_TYPE_QUIT:
                    str = str + "已退出"
                    break
                case .V2TIM_GROUP_TIPS_TYPE_KICKED:
                    str = str + "已被移出"
                    break
            default:
                str = ""
                break
            }
        }
        
        return str
    }
    
    /// 根据Elem获取内容
    static func getContentByElem(_ limMessage:LIMMessage?) -> String {
        var str = ""
        if let msg = limMessage {
            if (msg.isGroupMsg == true) {
                str = (msg.nickName ?? "") + "："
            }
            
            switch msg.elemType {
                case .LIMElemText:
                    str = str + (msg.textElem?.text ?? "")
                    break
                case .LIMElemImage:
                    str = str + "[图片]"
                    break
                case .LIMElemGroupTips:
                    str = str + GetGroupTipsContent(msg.groupTipsElem!)
                    break
                case .LIMElemGift:
                    str = str + "[礼物]"
                    break
                case .LIMElemInvite:
                    str = str + "[邀请你加入桔]"
                    break
                case .LIMElemRedPacket:
                    str = str + "[红包]"
                    break
                case .LIMElemSystemMsg:
                    str = msg.sysElem?.content ?? ""
                    break
                case .LIMElemGameStatusSync:
                    switch msg.gameElem?.action.actionId {
                        case .LIMGameStatusStory:
                            str = msg.gameElem?.action.roundInfo.title ?? ""
                            break
                        case .LIMGameStatusCard:
                            str = "抽到了[\(String(describing: msg.gameElem?.action.cardInfo.name))]"
                            break
                        case .LIMGameStatusRedPacket:
                            str = "请发红包"
                            break
                        case .LIMGameStatusEnd:
                            str = "游戏已结束"
                            break
                        default:
                            str = ""
                            break
                    }
                    break
                default:
                    str = str + "[未知消息]"
                    break
            }
        }
        
        return str
    }
}
