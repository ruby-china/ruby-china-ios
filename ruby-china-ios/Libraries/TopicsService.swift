//
//  TopicsService.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/9.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class TopicsService {

    enum ListType: String {
        /// 活跃的
        case last_actived
        /// 最近的
        case recent
        /// 无回复的
        case no_reply
        /// 受欢迎的
        case popular
        /// 精华
        case excellent
    }
    
    /// 获取帖子列表
    ///
    /// - parameter type:    排序类型
    /// - parameter node_id: 节点编号，传大于 0 时返回该节点的帖子
    /// - parameter offset:  分页起始位置
    /// - parameter limit:   分页大小，范围 1..150
    static func list(type: ListType = .last_actived, node_id: Int = 0, offset: Int = 0, limit: Int = 20, callback: (statusCode: Int?, result: [Topic]?) -> ()) {
        
        var parameters = [String: AnyObject]()
        parameters["type"] = type.rawValue
        parameters["offset"] = offset
        parameters["limit"] = limit
        if node_id > 0 {
            parameters["node_id"] = node_id
        }
        
        APIRequest.shared.get("/api/v3/topics.json", parameters: parameters) { (statusCode, result) in
            var topics: [Topic]? = nil
            
            guard let _ = result, topicList = result!["topics"].array where topicList.count > 0 else {
                callback(statusCode: statusCode, result: topics)
                return
            }
            
            topics = [Topic]()
            for topicJSON in topicList {
                topics!.append(Topic(json: topicJSON))
            }
            
            callback(statusCode: statusCode, result: topics)
        }
    }
    
}
