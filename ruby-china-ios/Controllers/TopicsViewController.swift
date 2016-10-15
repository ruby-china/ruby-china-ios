//
//  TopicsTableViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/13.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
//import DGElasticPullToRefresh
import UITableView_FDTemplateLayoutCell

class TopicsViewController: UITableViewController {

    private let kCellReuseIdentifier = "TOPIC_CELL"
    
    private var isLoading = false
    private var hasNext = true
    private var listType = TopicsService.ListType.popular
    private var nodeID = 0
    private var topicList: [Topic]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = true
        
        tableView.registerClass(TopicCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        tableView.separatorColor = UIColor(white: 0.94, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
        
//        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
//        loadingView.tintColor = NAVBAR_TINT_COLOR
//        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
//            self?.load(offset: 0)
//        }, loadingView: loadingView)
//        tableView.dg_setPullToRefreshFillColor(NAVBAR_BG_COLOR)
//        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topicList == nil ? 0 : topicList!.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = topicList![indexPath.row]
        return tableView.fd_heightForCellWithIdentifier(kCellReuseIdentifier, configuration: { (cell) in
            if let cell = cell as? TopicCell {
                cell.data = data
            }
        })
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! TopicCell
        cell.data = topicList![indexPath.row]
        cell.onUserClick = { (data) in
            guard let topic = data else {
                return
            }
            TurbolinksSessionLib.sharedInstance.actionToPath("/\(topic.user.login)", withAction: .Advance)
        }
        cell.onNodeClick = { (data) in
            guard let topic = data else {
                return
            }
            TurbolinksSessionLib.sharedInstance.actionToPath("/topics/node\(topic.nodeID)", withAction: .Advance)
        }
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = topicList![indexPath.row]
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/\(data.id)", withAction: .Advance)
    }
    
    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == topicList!.count - 1 {
            load(offset: topicList!.count)
        }
    }
    
}

extension TopicsViewController {
    
    func load(listType listType: TopicsService.ListType, nodeID: Int, offset: Int) {
        self.listType = listType
        self.nodeID = nodeID
        load(offset: offset)
    }
    
    private func load(offset offset: Int) {
        if !hasNext && offset > 0 { return }
        if isLoading { return }
        isLoading = true
        
        let limit = 20
        TopicsService.list(listType, node_id: nodeID, offset: offset, limit: limit, callback: { [weak self] (statusCode, result) in
            guard let `self` = self else {
                return
            }
            self.isLoading = false
            self.hasNext = result == nil ? false : result!.count >= limit
            if self.topicList == nil || offset == 0 {
                self.topicList = result
            } else if let topics = result {
                self.topicList! += topics
            }
            self.tableView.reloadData()
//            self.tableView.dg_stopLoading()
        })
    }
}
