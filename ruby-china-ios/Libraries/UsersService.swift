//
//  UsersService.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/11/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class UsersService {
    
    /// 获取当前登录用户信息
    ///
    /// - Parameter callback: 完成时回调
    static func me(callback: @escaping (APICallbackResponse, User?) -> ()) {
        APIRequest.shared.get("/api/v3/users/me.json", parameters: nil) { (response, result) in
            if let result = result, !result.isEmpty {
                let userJSON = result["user"]
                callback(response, User(json: userJSON))
            } else {
                callback(response, nil)
            }
        }
    }
    
    /// 获取指定用户收藏的话题列表
    ///
    /// - Parameters:
    ///   - userID: 用户ID
    ///   - offset: 分页起始位置
    ///   - limit: 分页大小，范围 1..150
    ///   - callback: 完成时回调
    static func favorites(userLogin: String, offset: Int = 0, limit: Int = 20, callback: @escaping (APICallbackResponse, [Topic]?) -> ()) {
        var parameters = [String: AnyObject]()
        parameters["offset"] = offset as AnyObject?
        parameters["limit"] = limit as AnyObject?
        APIRequest.shared.get("/api/v3/users/\(userLogin)/favorites.json", parameters: parameters) { (response, result) in
            guard let _ = result, let topicList = result!["topics"].array , topicList.count > 0 else {
                callback(response, nil)
                return
            }
            
            let topics = topicList.map { Topic(json: $0) }
            callback(response, topics)
        }
    }
    
}
