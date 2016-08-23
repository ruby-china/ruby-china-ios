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
    
    private var menuItems: [String]!
    private var menuItemIcons: [UIImage]!
    private var menuItemPaths: [String]!
    
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
        case 0:
            return menuItems.count
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = menuItems[indexPath.row]
            cell.imageView?.image = menuItemIcons[indexPath.row]
        case 1:
            if indexPath.row == 0 {
                cell.textLabel!.text = "Copyright"
                cell.imageView?.image = UIImage(named: "copyright")
            } else {
                cell.textLabel!.text = "Version \(version).\(build)"
                cell.imageView?.image = UIImage(named: "versions")
            }
        default: break;
        }
        
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case 0:
            let path = menuItemPaths[indexPath.row]
            actionWithPath(path)
        case 1:
            if indexPath.row == 0 {
                actionWithPath(COPYRIGHT_URL)
            } else {
                UIApplication.sharedApplication().openURL(NSURL(string: PROJECT_URL)!)
            }
        default: break;
        }
    }
    
    func updateLoginState() {
        if OAuth2.shared.isLogined {
            if let user = OAuth2.shared.currentUser {
                menuItems = [user.login, "个人资料设置", "记事本", "登出"]
                menuItemIcons = [UIImage(named: "profile")!, UIImage(named: "edit-user")!, UIImage(named: "notes")!, UIImage(named: "logout")!]
                menuItemPaths = ["/\(user.login)", "/account/edit", "/notes", "/logout"]
                
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
            menuItems = ["登录", "注册新账号"]
            menuItemIcons = [UIImage(named: "login")!, UIImage(named: "profile")!]
            menuItemPaths = ["/account/sign_in", "/account/sign_up"]
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