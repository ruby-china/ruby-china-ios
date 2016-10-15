//
//  TopicsTableViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/13.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import DGElasticPullToRefresh
import UITableView_FDTemplateLayoutCell

class TopicsTableViewController: UITableViewController {

    private let kCellReuseIdentifier = "TOPIC_CELL"
    
    private var isLoading = false
    private var hasNext = true
    private var listType = TopicsService.ListType.popular
    private var nodeID = 0
    private var topicList: [Topic]?
    
    private lazy var filterSegment: UISegmentedControl = {
        let filterSegment = UISegmentedControl(items: ["default".localized, "popular".localized, "latest".localized, "jobs".localized])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChangedAction), forControlEvents: .ValueChanged)
        return filterSegment
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.titleView = filterSegment
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new"), style: .Plain, target: self, action: #selector(newTopicAction))
        
        clearsSelectionOnViewWillAppear = true
        
        tableView.registerClass(TopicCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        tableView.separatorColor = UIColor(white: 0.94, alpha: 1)
        tableView.tableFooterView = UIView()
        tableView.separatorInset = UIEdgeInsetsZero
        
        let loadingView = DGElasticPullToRefreshLoadingViewCircle()
        loadingView.tintColor = NAVBAR_TINT_COLOR
        tableView.dg_addPullToRefreshWithActionHandler({ [weak self] () -> Void in
            guard let `self` = self else {
                return
            }
            self.filterChangedAction(self.filterSegment)
        }, loadingView: loadingView)
        tableView.dg_setPullToRefreshFillColor(NAVBAR_BG_COLOR)
        tableView.dg_setPullToRefreshBackgroundColor(tableView.backgroundColor!)
        
        filterChangedAction(filterSegment)
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
    
    func filterChangedAction(sender: UISegmentedControl) {
        nodeID = 0
        switch sender.selectedSegmentIndex {
        case 1:
            listType = TopicsService.ListType.excellent
        case 2:
            listType = TopicsService.ListType.last_actived
        case 3:
            listType = TopicsService.ListType.last_actived
            nodeID = 25
        default:
            listType = TopicsService.ListType.popular
        }
        load(offset: 0)
    }
    
    func newTopicAction() {
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/new", withAction: .Replace)
    }
    
    private func load(offset offset: Int) {
        if !hasNext { return}
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
            self.tableView.dg_stopLoading()
        })
    }
    
}
