//
//  NodesService.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//


class NodesService {
    
    /// 获取节点列表
    ///
    /// - parameter callback: 完成时回调
    static func list(callback: (statusCode: Int?, result: [Node]?) -> ()) {
        APIRequest.shared.get("/api/v3/nodes.json", parameters: nil) { (statusCode, result) in
            guard let _ = result, nodeList = result!["nodes"].array where nodeList.count > 0 else {
                callback(statusCode: statusCode, result: nil)
                return
            }
            
            var nodes = [Node]()
            for nodeJSON in nodeList {
                nodes.append(Node(json: nodeJSON))
            }
            
            callback(statusCode: statusCode, result: nodes)
        }
    }
    
    
    /// 获取节点详情
    ///
    /// - parameter nodeID:   节点ID
    /// - parameter callback: 完成时回调
    static func info(nodeID: Int, callback: (statusCode: Int?, result: Node?) -> ()) {
        APIRequest.shared.get("/api/v3/nodes/\(nodeID).json", parameters: nil) { (statusCode, result) in
            if let _ = result where result!["node"].isEmpty == false {
                callback(statusCode: statusCode, result: Node(json: result!["node"]))
            } else {
                callback(statusCode: statusCode, result: nil)
            }
        }
    }
}
