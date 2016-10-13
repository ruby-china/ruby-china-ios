//
//  TopicsTableViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/13.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicsTableViewController: UITableViewController {

    private let kCellReuseIdentifier = "TOPIC_CELL"
    private var topicList: [Topic]? {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterSegment = UISegmentedControl(items: ["default".localized, "popular".localized, "latest".localized, "jobs".localized])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChangedAction), forControlEvents: .ValueChanged)
        navigationItem.titleView = filterSegment
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "new"), style: .Plain, target: self, action: #selector(newTopicAction))
        
        self.clearsSelectionOnViewWillAppear = true
        
        self.tableView.registerClass(TopicCell.self, forCellReuseIdentifier: kCellReuseIdentifier)
        self.tableView.separatorColor = UIColor(white: 0.94, alpha: 1)
        self.tableView.tableFooterView = UIView()
        self.tableView.separatorInset = UIEdgeInsetsZero
        
        filterChangedAction(filterSegment)
    }

    // MARK: - Table view data source

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.topicList == nil ? 0 : self.topicList!.count
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let data = self.topicList![indexPath.row]
        return TopicCell.cellHeight(data)
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kCellReuseIdentifier, forIndexPath: indexPath) as! TopicCell
        cell.data = self.topicList![indexPath.row]
        return cell
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let data = self.topicList![indexPath.row]
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/\(data.id)", withAction: .Advance)
    }
    
    func filterChangedAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            TopicsService.list(TopicsService.ListType.excellent, node_id: 0, offset: 0, limit: 20, callback: { [weak self] (statusCode, result) in
                self?.topicList = result
            })
        case 2:
            TopicsService.list(TopicsService.ListType.last_actived, node_id: 0, offset: 0, limit: 20, callback: { [weak self] (statusCode, result) in
                self?.topicList = result
            })
//        case 3:
//            TurbolinksSessionLib.sharedInstance.actionToPath("/jobs", withAction: .Restore)
        default:
            TopicsService.list(TopicsService.ListType.popular, node_id: 0, offset: 0, limit: 20, callback: { [weak self] (statusCode, result) in
                self?.topicList = result
            })
        }
    }
    
    func newTopicAction() {
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/new", withAction: .Replace)
    }
    
}
