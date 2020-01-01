//
//  NodeTopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/11/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class NodeTopicsViewController: TopicsViewController {
    
    convenience init(nodeID: Int) {
        self.init()
        self.nodeID = nodeID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NodesService.info(nodeID) { [weak self] (statusCode, result) in
            self?.title = result == nil ? "title node".localized : result!.name;
        }
        
        tableView.mj_header?.beginRefreshing()
    }

    override func loadTopics(offset: Int, limit: Int, callback: @escaping (APICallbackResponse, [Topic]?) -> ()) {
        TopicsService.list(.last_actived, node_id: nodeID, offset: offset, limit: limit, callback: callback)
    }
    
}
