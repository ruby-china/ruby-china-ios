//
//  RootTopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class RootTopicsViewController: TopicsViewController {
    private var disappearTime: NSDate?
    
//    private lazy var filterSegment: UISegmentedControl = {
//        let filterSegment = UISegmentedControl(items: ["default".localized, "popular".localized, "latest".localized, "jobs".localized])
//        filterSegment.selectedSegmentIndex = 0
//        filterSegment.addTarget(self, action: #selector(filterChangedAction), forControlEvents: .ValueChanged)
//        return filterSegment
//    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.title = "title topics".localized
//        navigationItem.titleView = filterSegment
        
        let items = [
            UIBarButtonItem(image: UIImage(named: "new"), style: .Plain, target: self, action: #selector(newTopicAction)),
            UIBarButtonItem(image: UIImage(named: "search"), style: .Plain, target: self, action: #selector(searchAction)),
            UIBarButtonItem(image: UIImage(named: "filter"), style: .Plain, target: self, action: #selector(filterAction)),
        ]
        navigationItem.rightBarButtonItems = items
        
        addObserver()
        
        load(listType: .last_actived, nodeID: 0, offset: 0)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkRefreshContent()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetDisappearTime()
    }
    
}

// MARK: - action methods

extension RootTopicsViewController {
    
//    func filterChangedAction(sender: UISegmentedControl) {
//        var listType: TopicsService.ListType
//        var nodeID = 0
//        switch sender.selectedSegmentIndex {
//        case 1:
//            listType = TopicsService.ListType.excellent
//        case 2:
//            listType = TopicsService.ListType.last_actived
//        case 3:
//            listType = TopicsService.ListType.last_actived
//            nodeID = 25
//        default:
//            listType = TopicsService.ListType.popular
//        }
//        load(listType: listType, nodeID: nodeID, offset: 0)
//    }
    
    func filterAction() {
        
    }
    
    func searchAction() {
        
    }
    
    func newTopicAction() {
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/new", withAction: .Replace)
    }
    
}

// MARK: - private methods

extension RootTopicsViewController {
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.checkRefreshContent()
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.resetDisappearTime()
        }
    }
    
    private func resetDisappearTime() {
        disappearTime = NSDate()
    }
    
    private func checkRefreshContent() {
        guard let time = disappearTime else {
            return
        }
        disappearTime = nil
        
        if -time.timeIntervalSinceNow > (60 * 60 * 2.0) {
            self.tableView.mj_header.beginRefreshing()
        }
    }
}
