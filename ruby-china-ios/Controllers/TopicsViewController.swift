//
//  TopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicsViewController: WebViewController {
    private var disappearTime: NSDate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let filterSegment = UISegmentedControl(items: ["默认", "精选", "最新", "招聘"])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(filterChangedAction), forControlEvents: .ValueChanged)
        
        navigationItem.titleView = filterSegment
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "new"), style: .Plain, target: self, action: #selector(newTopicAction))
        
        addObserver()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        autoRefreshContent()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        resetDisappearTime()
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
    
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidBecomeActiveNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.autoRefreshContent()
        }
        NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationWillResignActiveNotification, object: nil, queue: nil) { [weak self](notification) in
            self?.resetDisappearTime()
        }
    }
    
    private func resetDisappearTime() {
        disappearTime = NSDate()
    }
    
    private func autoRefreshContent() {
        guard let disappearTime = disappearTime else {
            return
        }
        if -disappearTime.timeIntervalSinceNow > (60 * 60 * 2.0) {
            TurbolinksSessionLib.sharedInstance.visitableDidRequestRefresh(self)
        }
        self.disappearTime = nil
    }
}
