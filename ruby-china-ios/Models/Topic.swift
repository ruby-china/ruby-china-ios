//
//  Topic.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/9.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Topic {
    let id: Int
    let user: User
    let title: String
    let createdAt: NSDate
    let updatedAt: NSDate
    let repliedAt: NSDate?
    let repliesCount: Int
    let lastReplyUserID: Int?
    let lastReplyUserLogin: String?
    let likesCount: Int
    
    let nodeName: String
    let nodeID: Int
    
    /// 精华帖
    let excellent: Bool
    /// 已删除
    let deleted: Bool
    /// 置顶时间
    let suggestedAt: NSDate?
    /// 关闭时间
    let closedAt: NSDate?
    /// 操作权限
    let abilities: Abilities
    
    init(json: JSON) {
        id = json["id"].intValue
        user = User(json: json["user"])!
        title = json["title"].stringValue
        createdAt = json["created_at"].stringValue.dateValueFromISO8601()!
        updatedAt = json["updated_at"].stringValue.dateValueFromISO8601()!
        repliedAt = json["replied_at"].string?.dateValueFromISO8601()
        repliesCount = json["replies_count"].intValue
        lastReplyUserID = json["last_reply_user_id"].int
        lastReplyUserLogin = json["last_reply_user_login"].string
        likesCount = json["likes_count"].intValue
        
        nodeName = json["node_name"].stringValue
        nodeID = json["node_id"].intValue
        
        excellent = json["excellent"].boolValue
        deleted = json["deleted"].boolValue
        
        suggestedAt = json["suggested_at"].string?.dateValueFromISO8601()
        closedAt = json["closed_at"].string?.dateValueFromISO8601()
        
        abilities = Abilities(json: json["abilities"])
    }
    
    
    /// 帖子权限
    struct Abilities {
        /// 可修改
        let update: Bool
        /// 可删除
        let destroy: Bool
        /// 屏蔽话题
        let ban: Bool
        /// 加精华
        let excellent: Bool
        /// 取消精华
        let unexcellent: Bool
        /// 关闭回复
        let close: Bool
        /// 开启回复
        let open: Bool
        
        init(json: JSON) {
            update = json["update"].boolValue
            destroy = json["destroy"].boolValue
            ban = json["ban"].boolValue
            excellent = json["excellent"].boolValue
            unexcellent = json["unexcellent"].boolValue
            close = json["close"].boolValue
            open = json["open"].boolValue
        }
    }
    
}

/// 帖子更多状态
struct TopicMeta {
    /// 赞
    let liked: Bool
    /// 关注
    let followed: Bool
    /// 收藏
    let favorited: Bool
    
    init(json: JSON) {
        liked = json["liked"].boolValue
        followed = json["followed"].boolValue
        favorited = json["favorited"].boolValue
    }
}
