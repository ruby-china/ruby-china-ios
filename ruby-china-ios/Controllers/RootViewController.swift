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
    private let kTopicsTag = 0
    private let kWikiTag = 1
    private let kFavoritesTag = 2
    private let kNotificationsTag = 99
    private var isDidAppear = false
    private var needDisplayNotifications = false
    
    private func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = UIStoryboard(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sideMenuController") as? UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .ViewSlideOut
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        // SideMenu 不要手势，用处不大
        // SideMenuManager.menuAddPanGestureToPresent(toView: )
    }
    
    private func createSideMenuBarButton(image: UIImage?) -> UIBarButtonItem {
        return UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(displaySideMenu))
    }
    
    private func setupViewControllers() {
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
            viewController.tabBarItem.image = oldImage?.imageWithColor(BLACK_COLOR)?.imageWithRenderingMode(.AlwaysOriginal)
        })
    }
    
    func displaySideMenu() {
        let presentSideMenuController = {
            if let sideMenuController = SideMenuManager.menuLeftNavigationController {
                self.presentViewController(sideMenuController, animated: true, completion: nil)
            }
        }
        
        presentSideMenuController()
    }
    
    func actionMenuClicked(note: NSNotification) {
        let path = note.userInfo![NOTICE_MENU_CLICKED_PATH] as! String
        
        if let url = NSURL(string: path), host = url.host where host != NSURL(string: ROOT_URL)!.host! {
            TurbolinksSessionLib.sharedInstance.safariOpen(url)
        } else {
            TurbolinksSessionLib.sharedInstance.actionToPath(path, withAction: .Advance)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = createSideMenuBarButton(UIImage(named: "menu"))
        delegate = self
        setupSideMenu()
        setupViewControllers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displaySideMenu), name: NOTICE_DISPLAY_MENU, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(actionMenuClicked), name: NOTICE_MENU_CLICKED, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateLoginState), name: USER_CHANGED, object: nil)
        
        resetNavigationItem(viewControllers![selectedIndex])
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        isDidAppear = true
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            app.refreshUnreadNotificationCount()
        }
        
        if needDisplayNotifications {
            needDisplayNotifications = false
            displayNotifications()
        }
    }
    
    private func presentSignInViewController(onDidAuthenticate: () -> Void) {
        let controller = SignInViewController()
        controller.onDidAuthenticate = { sender in
            onDidAuthenticate()
        }
        let navController = ThemeNavigationController(rootViewController: controller)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    private func resetNavigationItem(viewController: UIViewController) {
        navigationItem.title = viewController.navigationItem.title
        navigationItem.titleView = viewController.navigationItem.titleView
        navigationItem.rightBarButtonItem = viewController.navigationItem.rightBarButtonItem
    }
    
    func updateLoginState() {
        if let viewController = selectedViewController where OAuth2.shared.currentUser == nil {
            switch viewController.tabBarItem.tag {
            case kFavoritesTag, kNotificationsTag:
                let topicsController = viewControllers![0]
                selectedViewController = topicsController
                resetNavigationItem(topicsController)
            default: break
            }
        }
        
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            app.refreshUnreadNotificationCount()
        }
    }
    
    func displayNotifications() {
        if !isDidAppear {
            needDisplayNotifications = true
            return
        }
        
        if presentedViewController != nil {
            dismissViewControllerAnimated(false, completion: nil)
        }
        if let viewController = navigationController?.viewControllers.last where viewController != self {
            navigationController?.popToViewController(self, animated: false)
        }
        
        guard let notificationsController = viewControllers!.last as? NotificationsViewController else {
            return
        }
        if selectedViewController == notificationsController {
            return
        }
        if tabBarController(self, shouldSelectViewController: notificationsController) {
            selectedViewController = notificationsController
            resetNavigationItem(notificationsController)
        }
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let tag = viewController.tabBarItem.tag
        if (tag == kFavoritesTag || tag == kNotificationsTag) && !OAuth2.shared.isLogined {
            presentSignInViewController() {
                self.selectedViewController = viewController
                self.resetNavigationItem(viewController)
            }
            return false
        }
        
        if let webViewController = viewController as? WebViewController where webViewController == selectedViewController {
            TurbolinksSessionLib.sharedInstance.visitableDidRequestRefresh(webViewController)
        }
        return true
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController) {
        resetNavigationItem(viewController)
    }
}
