//
//  TopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicsViewController: WebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterSegment = UISegmentedControl(items: ["默认","精选", "最新", "招聘"])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChangedAction), forControlEvents: .ValueChanged)
        navigationItem.titleView = filterSegment
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "new"), style: .Plain, target: self, action: #selector(newTopicAction))
    }
    
    func filterChangedAction(sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 1:
            TurbolinksSessionLib.sharedInstance.actionToPath("/topics/popular", withAction: .Restore)
        case 2:
            TurbolinksSessionLib.sharedInstance.actionToPath("/topics/last", withAction: .Restore)
        case 3:
            TurbolinksSessionLib.sharedInstance.actionToPath("/jobs", withAction: .Restore)
        default:
            TurbolinksSessionLib.sharedInstance.actionToPath("/topics", withAction: .Restore)
        }
    }
    
    func newTopicAction() {
        TurbolinksSessionLib.sharedInstance.actionToPath("/topics/new", withAction: .Replace)
    }
}
