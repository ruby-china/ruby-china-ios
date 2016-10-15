//
//  RootTopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class RootTopicsViewController: TopicsViewController {
    
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
        
        filterChangedAction(filterSegment)
    }
    
    func filterChangedAction(sender: UISegmentedControl) {
        var listType: TopicsService.ListType
        var nodeID = 0
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
        load(listType: listType, nodeID: nodeID, offset: 0)
    }
    
    func newTopicAction() {
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/new", withAction: .Replace)
    }
    
}
