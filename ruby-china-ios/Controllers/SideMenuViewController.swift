//
//  SideMenuViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/23.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import Router

class SideMenuViewController: UITableViewController {
    private lazy var router = Router()
    
    private var menuItems = ["", "个人资料设置", "记事本", "登出"]
    private var menuItemIcons = [UIImage(named: "profile"), UIImage(named: "edit-user"), UIImage(named: "notes"), UIImage(named: "logout")]
    private var menuItemPaths = ["", "/account/edit", "/notes", "/logout"]
    
    private var menuItemsWithoutLogin = ["登录", "注册新账号"]
    private var menuItemPathsWithoutLogin = ["/account/sign_in", "/account/sign_up"]
    private var menuItemIconsWithoutLogin = [UIImage(named: "login"), UIImage(named: "profile")]
    
    private let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    private let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ruby China"
    
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateLoginState), name: USER_CHANGED, object: nil);
        updateLoginState()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initRouter()
    }
    
    func initRouter() {
        router.bind("/logout") { (req) in
            OAuth2.shared.logout()
        }
        router.bind("/register") { (req) in
            
        }
        
        
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return 1;
        default:
            if OAuth2.shared.isLogined {
                return menuItems.count;
            } else {
                return menuItemsWithoutLogin.count;
            }
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        var items = menuItemsWithoutLogin
        var itemIcons = menuItemIconsWithoutLogin
        if OAuth2.shared.isLogined {
            items = menuItems
            itemIcons = menuItemIcons
        }
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = items[indexPath.row]
            cell.imageView?.image = itemIcons[indexPath.row]
        case 1:
            cell.textLabel!.text = "Version: \(version).\(build)"
            cell.imageView?.image = nil
        default: break;
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            var itemPaths = menuItemPathsWithoutLogin
            if OAuth2.shared.isLogined {
                itemPaths = menuItemPaths
            }
            let path = itemPaths[indexPath.row]
            actionWithPath(path)
        case 1:
            UIApplication.sharedApplication().openURL(NSURL(string: PROJECT_URL)!)
        default: break;
        }
    }
    
    func updateLoginState() {
        if OAuth2.shared.isLogined {
            if let user = OAuth2.shared.currentUser {
                menuItems[0] = user.login
                menuItemPaths[0] = "/\(user.login)"
                downloadUserAvatar({ [weak self] (avatar) in
                    guard let `self` = self else {
                        return
                    }
                    let avatarImage = avatar.drawRectWithRoundedCorner(radius: 11, CGSizeMake(22, 22)).imageWithRenderingMode(UIImageRenderingMode.AlwaysOriginal)
                    self.menuItemIcons[0] = avatarImage
                    self.tableView.reloadData()
                })
            }
        } else {
            menuItemIcons[0] = UIImage(named: "profile")
        }
        
        self.tableView.reloadData()
    }
    
    func actionWithPath(path: String) {
        let matchedRoute = router.match(NSURL.init(string: path)!)
        if (matchedRoute == nil) {
            navigationController?.dismissViewControllerAnimated(true, completion: {
                NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_MENU_CLICKED, object: self, userInfo: [NOTICE_MENU_CLICKED_PATH: path])
            })
        }
    }
    
    func actionProfile() {
        actionWithPath("/account/edit")
    }
    
    func actionNewTopic() {
        actionWithPath("/topics/new")
    }
    
    func actionLogin() {
        actionWithPath("/account/sign_in")
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
}