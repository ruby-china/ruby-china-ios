//
//  RootTopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/15.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import AMScrollingNavbar

class RootTopicsViewController: TopicsViewController {
    
    fileprivate lazy var hideWebViewController: WebViewController = {
        let vc = WebViewController(path: "/topics")
        return vc
    }()
    fileprivate var disappearTime: Date?
    fileprivate var filterData = TopicsFilterViewController.NodeData.listType(.last_actived)
    fileprivate var listType = TopicsService.ListType.popular
    fileprivate lazy var badgeLabel: UILabel = {
        let view = UILabel(frame: CGRect(x: 0, y: 0, width: 18, height: 18))
        view.clipsToBounds = true
        view.layer.cornerRadius = view.bounds.height / 2.0
        view.backgroundColor = UIColor.red
        view.textColor = UIColor.white
        view.textAlignment = .center
        view.font = UIFont.systemFont(ofSize: 13, weight: .medium)
        view.isHidden = true
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let notificationsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 30, height: 44))
        notificationsButton.setImage(UIImage(named: "notifications")?.imageWithColor(PRIMARY_COLOR), for: UIControlState())
        notificationsButton.addTarget(self, action: #selector(notificationsAction), for: .touchUpInside)
        let notificationsView = UIView(frame: notificationsButton.frame)
        notificationsView.addSubview(notificationsButton)
        notificationsView.addSubview(badgeLabel)
        badgeLabel.center.x = notificationsButton.frame.maxX - 3
        badgeLabel.frame.origin.y = notificationsButton.center.y - badgeLabel.frame.height
        let notificationsItem = UIBarButtonItem(customView: notificationsView)
        
        navigationItem.rightBarButtonItems = [
            UIBarButtonItem.fixNavigationSpacer(),
            notificationsItem,
            UIBarButtonItem.narrowButtonItem(image: UIImage(named: "search"), target: self, action: #selector(searchAction)),
            UIBarButtonItem.narrowButtonItem(image: UIImage(named: "filter"), target: self, action: #selector(filterAction)),
        ]
        
        // Turbolinks.VisitableViewController 第一个实例显示很慢
        // hideWebViewController 是为解决此问题而生
        // 启动应用时实例化一个看不见的 Turbolinks.VisitableViewController 以便之后的 Turbolinks.VisitableViewController 显示快些
        addChildViewController(hideWebViewController)
        view.addSubview(hideWebViewController.view)
        hideWebViewController.view.frame = CGRect(x: -view.bounds.width, y: 0, width: 100, height: 100)
        
        addObserver()
        
        resetTitle(filterData)
        reloadTopics(filterData)
        refreshBadgeLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkRefreshContent()
        OAuth2.shared.refreshUnreadNotifications()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resetDisappearTime()
    }
    
    override func loadTopics(offset: Int, limit: Int, callback: @escaping (APICallbackResponse, [Topic]?) -> ()) {
        TopicsService.list(listType, node_id: nodeID, offset: offset, limit: limit, callback: callback)
    }
}

// MARK: - action methods
@objc 
extension RootTopicsViewController {
    
    func filterAction() {
        let vc = TopicsFilterViewController.show()
        vc.selectedData = filterData
        vc.onChangeSelect = { [weak self] (sender) in
            guard let `self` = self, let data = sender.selectedData else {
                return
            }
            self.filterData = data
            self.resetTitle(data)
            self.reloadTopics(data)
            sender.close()
        }
    }
    
    func searchAction() {
        let vc = SearchViewController()
        vc.onCancel = { sender in
            sender.dismiss(animated: true, completion: nil)
        }
        
        let nc = ScrollingNavigationController(rootViewController: vc)
        self.present(nc, animated: true, completion: nil)
    }
    
    func notificationsAction() {
        if !OAuth2.shared.isLogined {
            SignInViewController.show()
        } else {
            navigationController?.pushViewController(NotificationsViewController(path: "/notifications"), animated: true)
        }
    }
    
}

// MARK: - private methods

extension RootTopicsViewController {
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self](notification) in
            self?.checkRefreshContent()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationWillResignActive, object: nil, queue: nil) { [weak self](notification) in
            self?.resetDisappearTime()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.userUnreadNotificationChanged, object: nil, queue: nil) { [weak self](notification) in
            self?.refreshBadgeLabel()
        }
    }
    
    fileprivate func refreshBadgeLabel() {
        let count = OAuth2.shared.unreadNotificationCount
        badgeLabel.isHidden = count <= 0
        badgeLabel.text = "\(min(99, count))"
    }
    
    fileprivate func resetTitle(_ filterData: TopicsFilterViewController.NodeData) {
        switch filterData {
        case let .listType(type):
            navigationItem.title = type == .last_actived ? "title topics".localized : filterData.getName()
        case let .node(_, name):
            navigationItem.title = name
        }
        
        tabBarController?.title = navigationItem.title
    }
    
    fileprivate func load(listType: TopicsService.ListType, nodeID: Int, offset: Int) {
        self.listType = listType
        self.nodeID = nodeID
        self.tableView.mj_header.beginRefreshing()
    }
    
    fileprivate func reloadTopics(_ filterData: TopicsFilterViewController.NodeData) {
        switch filterData {
        case let .listType(type):
            load(listType: type, nodeID: 0, offset: 0)
        case let .node(id, _):
            load(listType: .last_actived, nodeID: id, offset: 0)
        }
    }
    
    fileprivate func resetDisappearTime() {
        disappearTime = Date()
    }
    
    fileprivate func checkRefreshContent() {
        guard let time = disappearTime else {
            return
        }
        disappearTime = nil
        
        if -time.timeIntervalSinceNow > (60 * 60 * 2.0) {
            self.tableView.mj_header.beginRefreshing()
        }
    }
}
