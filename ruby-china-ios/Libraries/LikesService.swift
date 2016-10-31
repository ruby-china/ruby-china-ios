//
//  LikesService.swift
//  ruby-china-ios
//
//  Created by kelei on 16/10/19.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

class LikesService {
    
    /// 赞接口的类型
    ///
    /// - topic: 帖子
    /// - reply: 回复
    enum LikeType: String {
        case topic, reply
    }
    
    /// 赞
    ///
    /// - parameter type:     关联类型
    /// - parameter id:       关联ID
    /// - parameter callback: 完成时回调
    static func like(_ type: LikeType, id: Int, callback: @escaping (APICallbackResponse, Int?) -> ()) {
        let parameters: [String : AnyObject] = ["obj_type": type.rawValue as AnyObject, "obj_id": id as AnyObject]
        APIRequest.shared.post("/api/v3/likes", parameters: parameters) { (response, result) in
            let count = result == nil ? nil : result!["count"].int
            callback(response, count)
        }
    }
    
    /// 取消赞
    ///
    /// - parameter type:     关联类型
    /// - parameter id:       关联ID
    /// - parameter callback: 完成时回调
    static func unlike(_ type: LikeType, id: Int, callback: @escaping (APICallbackResponse, Int?) -> ()) {
        let parameters: [String : AnyObject] = ["obj_type": type.rawValue as AnyObject, "obj_id": id as AnyObject]
        APIRequest.shared.delete("/api/v3/likes", parameters: parameters) { (response, result) in
            let count = result == nil ? nil : result!["count"].int
            callback(response, count)
        }
    }
    
}
