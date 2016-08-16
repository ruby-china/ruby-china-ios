//
//  SideMenuViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/23.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SideMenuViewController: UITableViewController {
    private let menuItems = ["个人资料设置", "记事本"]
    private let menuItemIcons = ["profile", "notes"]
    private let menuItemPaths = ["/account/edit", "/notes"]
    
    private let version = NSBundle.mainBundle().infoDictionary!["CFBundleShortVersionString"] as! String
    private let build = NSBundle.mainBundle().infoDictionary!["CFBundleVersion"] as! String
    
    private var loginButton: UIBarButtonItem!
    private var logoutButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginButton = UIBarButtonItem.init(image: UIImage.init(named: "login"), style: .Plain, target: self, action: #selector(actionLogin))
        loginButton.tintColor = UIColor.blackColor()
        
        logoutButton = UIBarButtonItem.init(image: UIImage.init(named: "logout"), style: .Plain, target: self, action: #selector(actionLogout))
        logoutButton.tintColor = UIColor.blackColor()
        
        uploadLoginState()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? menuItems.count : 1
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath)
        
        switch indexPath.section {
        case 0:
            cell.textLabel!.text = menuItems[indexPath.row]
            cell.imageView?.image = UIImage.init(named: menuItemIcons[indexPath.row])
        case 1:
            cell.textLabel!.text = "Version: \(version).\(build)"
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
            UIApplication.sharedApplication().openURL(NSURL(string: PROJECT_URL)!)
        default: break;
        }
    }
    
    func uploadLoginState() {
        if OAuth2.shared.isLogined {
            title = OAuth2.shared.currentUser?.name
            
            navigationItem.rightBarButtonItem = logoutButton
        } else {
            title = "Ruby China"
            
            navigationItem.rightBarButtonItem = loginButton
        }
    }
    
    func actionWithPath(path: String) {
        navigationController?.dismissViewControllerAnimated(true, completion: {
            NSNotificationCenter.defaultCenter().postNotificationName(NOTICE_MENU_CLICKED, object: self, userInfo: [NOTICE_MENU_CLICKED_PATH: path])
        })
    }
    
    func actionLogout() {
        OAuth2.shared.logout()
        uploadLoginState()
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
}