//
//  RootViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import SideMenu

class RootViewController: UITabBarController {
    private func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sideMenuController") as? UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .ViewSlideOut
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        // SideMenu 不要手势，用处不大
        // SideMenuManager.menuAddPanGestureToPresent(toView: )
    }
    
    private func createSideMenuBarButton() -> UIBarButtonItem {
        return UIBarButtonItem(image: UIImage(named: "profile"), style: .Plain, target: self, action: #selector(displaySideMenu))
    }
    
    private func setupViewControllers() {
        let topicsController = TopicsViewController(path: "/topics")
        topicsController.tabBarItem = UITabBarItem(title: "讨论", image: UIImage(named: "topic"), tag: 0)
        
        let pagesController = WebViewController(path: "/wiki")
        pagesController.tabBarItem = UITabBarItem(title: "Wiki", image: UIImage(named: "wiki"), tag: 1)
        
        let favoritesController = WebViewController(path: "/topics/favorites")
        favoritesController.tabBarItem = UITabBarItem(title: "收藏", image: UIImage(named: "favorites"), tag: 2)
        
        let notificationsController = NotificationsViewController(path: "/notifications")
        notificationsController.tabBarItem = UITabBarItem(title: "通知", image: UIImage(named: "notifications"), tag: 99)
        
        let vcs: [WebViewController] = [topicsController, pagesController, favoritesController, notificationsController]
        viewControllers = vcs.map { (viewController) -> UINavigationController in
            viewController.navigationItem.leftBarButtonItem = createSideMenuBarButton()
            TurbolinksSessionLib.sharedInstance.visit(viewController)
            let nvc = UINavigationController(rootViewController: viewController)
            nvc.view.backgroundColor = UIColor.whiteColor()
            return nvc
        }
    }
    
    func displaySideMenu() {
        if let sideMenuController = SideMenuManager.menuLeftNavigationController {
            presentViewController(sideMenuController, animated: true, completion: nil)
        }
    }
    
    func actionMenuClicked(note: NSNotification) {
        let path = note.userInfo![NOTICE_MENU_CLICKED_PATH] as! String;
        TurbolinksSessionLib.sharedInstance.actionToPath(path, withAction: .Advance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        setupViewControllers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displaySideMenu), name: NOTICE_DISPLAY_MENU, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(actionMenuClicked), name: NOTICE_MENU_CLICKED, object: nil);
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
}