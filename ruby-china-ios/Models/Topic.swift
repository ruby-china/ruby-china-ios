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
    let deleted: Bool
    
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
    }
}
