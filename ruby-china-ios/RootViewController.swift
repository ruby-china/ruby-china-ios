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
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        SideMenuManager.menuAddPanGestureToPresent(toView: view)
    }
    
    private func setupViewControllers() {
        let topicsController = ApplicationController()
        topicsController.rootPath = "/topics"
        topicsController.tabBarItem = UITabBarItem(title: "讨论", image: UIImage(named: "topic"), tag: 0)
        
        let pagesController = ApplicationController()
        pagesController.rootPath = "/wiki"
        pagesController.tabBarItem = UITabBarItem(title: "Wiki", image: UIImage(named: "wiki"), tag: 1)
        
        let favoritesController = ApplicationController()
        favoritesController.rootPath = "/topics/favorites"
        favoritesController.tabBarItem = UITabBarItem(title: "收藏", image: UIImage(named: "favorites"), tag: 2)
        
        let notificationsController = ApplicationController()
        notificationsController.rootPath = "/notifications"
        notificationsController.tabBarItem = UITabBarItem(title: "通知", image: UIImage(named: "notifications"), tag: 99)
        
        
        
        viewControllers = [topicsController, pagesController, favoritesController, notificationsController]
    }
    
    func displaySideMenu() {
        if let sideMenuController = SideMenuManager.menuLeftNavigationController {
            presentViewController(sideMenuController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSideMenu()
        setupViewControllers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displaySideMenu), name: NOTICE_DISPLAY_MENU, object: nil)
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        
    }
}