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

    private func setupSideMenu() {
        SideMenuManager.menuLeftNavigationController = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewControllerWithIdentifier("sideMenuController") as? UISideMenuNavigationController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuPresentMode = .ViewSlideOut
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        // SideMenu 不要手势，用处不大
        // SideMenuManager.menuAddPanGestureToPresent(toView: )
    }
    
    private func downloadUserAvatar(onComplate: (avatar: UIImage) -> Void) {
        let downloadTask = NSURLSession.sharedSession().dataTaskWithURL(OAuth2.shared.currentUser!.avatarUrl) { (data, response, error) in
            if let error = error {
                print(error)
                return
            }
            if let data = data {
                onComplate(avatar: UIImage(data: data)!)
            }
        }
        downloadTask.resume()
    }
    
    private func createSideMenuBarButton(image: UIImage?) -> UIBarButtonItem {
        return UIBarButtonItem(image: image, style: .Plain, target: self, action: #selector(displaySideMenu))
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
            viewController.navigationItem.leftBarButtonItem = createSideMenuBarButton(UIImage(named: "profile"))
            TurbolinksSessionLib.sharedInstance.visit(viewController)
            let nvc = UINavigationController(rootViewController: viewController)
            nvc.view.backgroundColor = UIColor.whiteColor()
            return nvc
        }
    }
    
    func displaySideMenu() {
        let presentSideMenuController = {
            if let sideMenuController = SideMenuManager.menuLeftNavigationController {
                self.presentViewController(sideMenuController, animated: true, completion: nil)
            }
        }
        
        if (!OAuth2.shared.isLogined) {
            presentSignInViewController(presentSideMenuController)
        } else {
            presentSideMenuController()
        }
    }
    
    func actionMenuClicked(note: NSNotification) {
        let path = note.userInfo![NOTICE_MENU_CLICKED_PATH] as! String;
        TurbolinksSessionLib.sharedInstance.actionToPath(path, withAction: .Advance)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        delegate = self
        setupSideMenu()
        setupViewControllers()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(displaySideMenu), name: NOTICE_DISPLAY_MENU, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(actionMenuClicked), name: NOTICE_MENU_CLICKED, object: nil);
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateLoginState), name: USER_CHANGED, object: nil);
        
        updateLoginState()
    }
    
    private func presentSignInViewController(onDidAuthenticate: () -> Void) {
        let controller = SignInViewController()
        controller.onDidAuthenticate = { sender in
            onDidAuthenticate()
        }
        let navController = UINavigationController(rootViewController: controller)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    func updateLoginState() {
        var avatarImage = UIImage(named: "profile")
        if OAuth2.shared.currentUser != nil {
            downloadUserAvatar({ [weak self] (avatar) in
                guard let `self` = self else {
                    return
                }
                avatarImage = avatar.drawRectWithRoundedCorner(radius: 15, CGSizeMake(30, 30)).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                
                self.updateUserAvatarImage(avatarImage!)
            })
        } else {
            self.updateUserAvatarImage(avatarImage!)
        }
    }
    
    func updateUserAvatarImage(image: UIImage) {
        dispatch_async(dispatch_get_main_queue(), {
            self.viewControllers?.forEach({ (navigationController) in
                guard let nc = navigationController as? UINavigationController else {
                    return
                }
                nc.viewControllers.first?.navigationItem.leftBarButtonItem = self.createSideMenuBarButton(image)
            })
        })
    }
}

extension RootViewController: UITabBarControllerDelegate {
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        let tag = viewController.tabBarItem.tag
        if (tag == kFavoritesTag || tag == kNotificationsTag) && !OAuth2.shared.isLogined {
            presentSignInViewController() {
                self.selectedViewController = viewController
            }
            return false
        }
        return true
    }
}