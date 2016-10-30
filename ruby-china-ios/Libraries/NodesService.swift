//
//  NodesService.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import SwiftyJSON

class NodesService {
    
    /// 获取节点列表
    ///
    /// - parameter callback: 完成时回调
    static func list(_ callback: @escaping (_ response: APICallbackResponse, _ result: JSON?) -> ()) {
        APIRequest.shared.get("/api/v3/nodes.json", parameters: nil, callback: callback)
    }
    
    /// 获取节点详情
    ///
    /// - parameter nodeID:   节点ID
    /// - parameter callback: 完成时回调
    static func info(_ nodeID: Int, callback: @escaping (_ response: APICallbackResponse, _ result: Node?) -> ()) {
        APIRequest.shared.get("/api/v3/nodes/\(nodeID).json", parameters: nil) { (response, result) in
            if let _ = result , result!["node"].isEmpty == false {
                callback(response, Node(json: result!["node"]))
            } else {
                callback(response, nil)
            }
        }
    }
    
}
