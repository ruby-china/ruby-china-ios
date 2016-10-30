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
    fileprivate let kTopicsTag = 0
    fileprivate let kWikiTag = 1
    fileprivate let kFavoritesTag = 2
    fileprivate let kNotificationsTag = 99
    fileprivate var isDidAppear = false
    fileprivate var needDisplayNotifications = false
    
    fileprivate func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "sideMenuController") as? UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .viewSlideOut
        SideMenuManager.menuAnimationBackgroundColor = UIColor.gray
    }
    
    fileprivate func setupViewControllers() {
        let topicsController = RootTopicsViewController()
        topicsController.tabBarItem = UITabBarItem(title: "topics".localized, image: UIImage(named: "topic"), tag: kTopicsTag)
        
        let pagesController = WebViewController(path: "/wiki")
        pagesController.tabBarItem = UITabBarItem(title: "wiki".localized, image: UIImage(named: "wiki"), tag: kWikiTag)
        
        let favoritesController = WebViewController(path: "/topics/favorites")
        favoritesController.tabBarItem = UITabBarItem(title: "favorites".localized, image: UIImage(named: "favorites"), tag: kFavoritesTag)
        
        let notificationsController = NotificationsViewController(path: "/notifications")
        notificationsController.tabBarItem = UITabBarItem(title: "notifications".localized, image: UIImage(named: "notifications"), tag: kNotificationsTag)
        
        viewControllers = [topicsController, pagesController, favoritesController, notificationsController]
        viewControllers?.forEach({ (viewController) in
            let oldImage = viewController.tabBarItem.image
            viewController.tabBarItem.image = oldImage?.imageWithColor(BLACK_COLOR)?.withRenderingMode(.alwaysOriginal)
        })
    }
    
    func displaySideMenu() {
        let presentSideMenuController = {
            if let sideMenuController = SideMenuManager.menuLeftNavigationController {
                self.present(sideMenuController, animated: true, completion: nil)
            }
        }
        
        presentSideMenuController()
    }
    
    func actionMenuClicked(_ note: Notification) {
        let path = (note as NSNotification).userInfo![NOTICE_MENU_CLICKED_PATH] as! String
        
        if let url = URL(string: path), let host = url.host , host != URL(string: ROOT_URL)!.host! {
            TurbolinksSessionLib.sharedInstance.safariOpen(url)
        } else {
            TurbolinksSessionLib.sharedInstance.actionToPath(path, withAction: .Advance)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItems = [
            UIBarButtonItem.fixNavigationSpacer(),
            UIBarButtonItem.narrowButtonItem(image: UIImage(named: "menu"), target: self, action: #selector(displaySideMenu))
        ]
        delegate = self
        setupSideMenu()
        setupViewControllers()
        
        NotificationCenter.default.addObserver(self, selector: #selector(displaySideMenu), name: NSNotification.Name(rawValue: NOTICE_DISPLAY_MENU), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(actionMenuClicked), name: NSNotification.Name(rawValue: NOTICE_MENU_CLICKED), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginState), name: NSNotification.Name(rawValue: USER_CHANGED), object: nil)
        
        resetNavigationItem(viewControllers![selectedIndex])
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
    
    func updateLoginState() {
        if let viewController = selectedViewController , OAuth2.shared.currentUser == nil {
            switch viewController.tabBarItem.tag {
            case kFavoritesTag, kNotificationsTag:
                let topicsController = viewControllers![0]
                selectedViewController = topicsController
                resetNavigationItem(topicsController)
            default: break
            }
        }
        
        if let app = UIApplication.shared.delegate as? AppDelegate {
            app.refreshUnreadNotificationCount()
        }
    }
    
    func displayNotifications() {
        if !isDidAppear {
            needDisplayNotifications = true
            return
        }
        
        if presentedViewController != nil {
            dismiss(animated: false, completion: nil)
        }
        if let viewController = navigationController?.viewControllers.last , viewController != self {
            _ = navigationController?.popToViewController(self, animated: false)
        }
        
        guard let notificationsController = viewControllers!.last as? NotificationsViewController else {
            return
        }
        if selectedViewController == notificationsController {
            return
        }
        if tabBarController(self, shouldSelect: notificationsController) {
            selectedViewController = notificationsController
            resetNavigationItem(notificationsController)
        }
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        let tag = viewController.tabBarItem.tag
        if (tag == kFavoritesTag || tag == kNotificationsTag) && !OAuth2.shared.isLogined {
            SignInViewController.show().onDidAuthenticate = { [weak self] (sender) in
                self?.selectedViewController = viewController
                self?.resetNavigationItem(viewController)
            }
            return false
        }
        
        if let webViewController = viewController as? WebViewController , webViewController == selectedViewController {
            TurbolinksSessionLib.sharedInstance.visitableDidRequestRefresh(webViewController)
        }
        return true
    }
    
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        resetNavigationItem(viewController)
    }
}
