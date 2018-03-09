//
//  RootViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import SideMenu
import AMScrollingNavbar

class RootViewController: UITabBarController {
    
    fileprivate var isDidAppear = false
    fileprivate var needDisplayNotifications = false
    
    fileprivate func setupSideMenu() {
        SideMenuManager.default.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideMenuController") as? UISideMenuNavigationController
        SideMenuManager.default.menuFadeStatusBar = false
        SideMenuManager.default.menuPresentMode = .viewSlideOut
        SideMenuManager.default.menuAnimationBackgroundColor = UIColor.gray
    }
    
    fileprivate func setupViewControllers() {
        let topicsController = RootTopicsViewController()
        viewControllers = [topicsController]
    }
    
    @objc func displaySideMenu() {
        let presentSideMenuController = {
            if let sideMenuController = SideMenuManager.default.menuLeftNavigationController {
                self.present(sideMenuController, animated: true, completion: nil)
            }
        }
        
        presentSideMenuController()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBar.isHidden = true
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem.fixNavigationSpacer(),
            UIBarButtonItem.narrowButtonItem(image: UIImage(named: "menu"), target: self, action: #selector(displaySideMenu))
        ]
        delegate = self
        setupSideMenu()
        setupViewControllers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginState), name: NSNotification.Name.userChanged, object: nil)
        
        resetNavigationItem(viewControllers![selectedIndex])
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isDidAppear = true
        
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.refreshUnreadNotificationCount()
        }
        
        if needDisplayNotifications {
            needDisplayNotifications = false
            displayNotifications()
        }
    }
    
    fileprivate func resetNavigationItem(_ viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        navigationItem.titleView = viewController.navigationItem.titleView
        navigationItem.rightBarButtonItems = viewController.navigationItem.rightBarButtonItems
    }
    
    @objc func updateLoginState() {
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.refreshUnreadNotificationCount()
        }
    }
    
    func displayNotifications() {
        if !isDidAppear {
            needDisplayNotifications = true
            return
        }
        if !OAuth2.shared.isLogined {
            return
        }
        
        if presentedViewController != nil {
            dismiss(animated: false, completion: nil)
        }
        if let viewController = navigationController?.viewControllers.last {
            if viewController is NotificationsViewController {
                return
            }
            if viewController != self {
                _ = navigationController?.popToViewController(self, animated: false)
            }
        }
        
        navigationController?.pushViewController(NotificationsViewController(path: "/notifications"), animated: true)
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        resetNavigationItem(viewController)
    }
}
