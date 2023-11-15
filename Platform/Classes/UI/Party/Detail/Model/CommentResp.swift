//
//  CommentListResp.swift
//  constellation
//
//  Created by Lee on 2020/4/3.
//  Copyright © 2020 Constellation. All rights reserved.
//

import UIKit
import SwiftyJSON

class CommentListResp: RespModel {
    var data = CommentListModel()
    
    override init(_ json: JSON) {
        super.init(json)
        data = CommentListModel(json["data"])
    }
}

class CommentListModel {
    
    /// 页数
    var pageNum: Int64 = 1
    /// 每页数量
    var pageSize: Int64 = 10
    /// 总页数
    var pageTotal: Int64 = 0
    /// 评论总数
    var totalCount: Int64 = 0
    /// 评论
    var comments: [CommentItem] = []
    
    
    init(_ json:JSON) {
        pageNum = json["page_num"].int64Value
        pageSize = json["page_size"].int64Value
        pageTotal = json["page_total"].int64Value
        totalCount = json["total_count"].int64Value
        for (_, subJson) in json["comments"] {
            comments.append(CommentItem(subJson))
        }
    }
    
    init() {}
}

class CommentItem {
    var id: Int64 = 0
    var childTotalCount: Int64 = 0
    var commentTime: String = ""
    var content: String = ""
    var likeCnt: Int64 = 0
    var parentId: Int64 = 0
    var from: UserBrief = UserBrief()
    var to: UserBrief = UserBrief()
    var childComments: [CommentItem] = []
    
    
    init(_ json:JSON) {
        
        id = json["id"].int64Value
        childTotalCount = json["child_total_count"].int64Value
        commentTime = json["comment_time"].stringValue
        content = json["content"].stringValue
        likeCnt = json["likeCnt"].int64Value
        parentId = json["parent_id"].int64Value
        from = UserBrief(json["from"])
        to = UserBrief(json["to"])
        for (_, subJson) in json["child_comments"] {
            childComments.append(CommentItem(subJson))
        }
    }
    
    init() {}
}

class UserBrief {
    
    var userId: String = ""
    var nick: String = ""
    var portrait: String = ""
    var sex: Int64 = 0
    
    init(_ json:JSON) {
        userId = json["user_id"].stringValue
        nick = json["nick"].stringValue
        portrait = json["portrait"].stringValue
        sex = json["sex"].int64Value
    }
    
    init() {}
}

class CommentResp: RespModel {
    var data = CommentModel()

    override init(_ json: JSON) {
        super.init(json)
        data = CommentModel(json["data"])
    }
}

class CommentModel {
    
    /// 评论id
    var commentId: Int64 = 0
    
    init(_ json:JSON) {
        commentId = json["comment_id"].int64Value
    }
    
    init() {}
}

