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
    private var menuItemPaths: [String]!
    private var menuItemIcons: [UIImage]!
    private var menuItemIconColors = [
        UIColor(red: 94 / 255.0, green: 151 / 255.0, blue: 246 / 255.0, alpha: 1),
        UIColor(red: 156 / 255.0, green: 204 / 255.0, blue: 101 / 255.0, alpha: 1),
        UIColor(red: 224 / 255.0, green: 96 / 255.0, blue: 85 / 255.0, alpha: 1),
        UIColor(red: 79 / 255.0, green: 195 / 255.0, blue: 247 / 255.0, alpha: 1),
    ]
    
    private let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ruby China"
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(updateLoginState), name: USER_CHANGED, object: nil)
        updateLoginState()
        
        tableView.backgroundColor = SIDEMENU_BG_COLOR
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initRouter()
    }
    
    func initRouter() {
        router.bind("/logout") { (req) in
            OAuth2.shared.logout()
        }
        router.bind("/account/sign_up") { (req) in
            let url = NSURL(string: "\(ROOT_URL)/account/sign_up")!
            UIApplication.sharedApplication().openURL(url)
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
            cell.imageView?.tintColor = menuItemIconColors[indexPath.row]
        case 1:
            if indexPath.row == 0 {
                cell.textLabel!.text = "copyright".localized
                cell.imageView?.image = UIImage(named: "copyright")!.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.tintColor = UIColor(red: 246 / 255.0, green: 191 / 255.0, blue: 50 / 255.0, alpha: 1)
            } else {
                cell.textLabel!.text = "Version \(APP_VERSION).\(build)"
                cell.imageView?.image = UIImage(named: "versions")!.imageWithRenderingMode(.AlwaysTemplate)
                cell.imageView?.tintColor = UIColor(red: 87 / 255.0, green: 187 / 255.0, blue: 138 / 255.0, alpha: 1)
            }
        default: break
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
        default: break
        }
    }
    
    func updateLoginState() {
        if let user = OAuth2.shared.currentUser where OAuth2.shared.isLogined {
            menuItems = [user.login, "edit account".localized, "notes".localized, "sign out".localized]
            menuItemIcons = [
                UIImage(named: "profile")!.imageWithRenderingMode(.AlwaysTemplate),
                UIImage(named: "edit-user")!.imageWithRenderingMode(.AlwaysTemplate),
                UIImage(named: "notes")!.imageWithRenderingMode(.AlwaysTemplate),
                UIImage(named: "logout")!.imageWithRenderingMode(.AlwaysTemplate),
            ]
            menuItemPaths = ["/\(user.login)", "/account/edit", "/notes", "/logout"]
            
            downloadUserAvatar({ [weak self] (avatar) in
                guard let `self` = self else {
                    return
                }
                guard let avatarImage = avatar.drawRectWithRoundedCorner(radius: 11, CGSizeMake(22, 22)) else {
                    return
                }
                self.menuItemIcons[0] = avatarImage
                self.tableView.reloadData()
            })
        } else {
            menuItems = ["sign in".localized, "sign up".localized]
            menuItemIcons = [
                UIImage(named: "login")!.imageWithRenderingMode(.AlwaysTemplate),
                UIImage(named: "profile")!.imageWithRenderingMode(.AlwaysTemplate),
            ]
            menuItemPaths = ["/account/sign_in", "/account/sign_up"]
        }
        
        self.tableView.reloadData()
    }
    
    func actionWithPath(path: String) {
        let matchedRoute = router.match(NSURL(string: path)!)
        if (matchedRoute == nil) {
            dismissViewControllerAnimated(true, completion: {
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
                if let avatar = UIImage(data: data) {
                    onComplate(avatar: avatar)
                }
            }
        }
        downloadTask.resume()
    }
}
