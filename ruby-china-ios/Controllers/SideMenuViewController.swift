//
//  SideMenuViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/23.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import Router
import Kingfisher

class SideMenuViewController: UITableViewController {
    fileprivate lazy var router = Router()
    
    fileprivate var menuItems: [String]!
    fileprivate var menuItemPaths: [String]!
    fileprivate var menuItemIcons: [UIImage]!
    fileprivate var menuItemIconColors = [
        UIColor(red: 94 / 255.0, green: 151 / 255.0, blue: 246 / 255.0, alpha: 1),
        UIColor(red: 156 / 255.0, green: 204 / 255.0, blue: 101 / 255.0, alpha: 1),
        UIColor(red: 224 / 255.0, green: 96 / 255.0, blue: 85 / 255.0, alpha: 1),
        UIColor(red: 79 / 255.0, green: 195 / 255.0, blue: 247 / 255.0, alpha: 1),
    ]
    
    fileprivate let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ruby China"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginState), name: NSNotification.Name(rawValue: USER_CHANGED), object: nil)
        updateLoginState()
        
        tableView.backgroundColor = SIDEMENU_BG_COLOR
        
        tableView.delegate = self
        tableView.dataSource = self
        
        initRouter()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return menuItems.count
        case 1:
            return 2
        default:
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            cell.textLabel!.text = menuItems[(indexPath as NSIndexPath).row]
            cell.imageView?.image = menuItemIcons[(indexPath as NSIndexPath).row]
            cell.imageView?.tintColor = menuItemIconColors[(indexPath as NSIndexPath).row]
        case 1:
            if (indexPath as NSIndexPath).row == 0 {
                cell.textLabel!.text = "copyright".localized
                cell.imageView?.image = UIImage(named: "copyright")!.withRenderingMode(.alwaysTemplate)
                cell.imageView?.tintColor = UIColor(red: 246 / 255.0, green: 191 / 255.0, blue: 50 / 255.0, alpha: 1)
            } else {
                cell.textLabel!.text = "Version \(APP_VERSION) (build \(build))"
                cell.imageView?.image = UIImage(named: "versions")!.withRenderingMode(.alwaysTemplate)
                cell.imageView?.tintColor = UIColor(red: 87 / 255.0, green: 187 / 255.0, blue: 138 / 255.0, alpha: 1)
            }
        default: break
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch (indexPath as NSIndexPath).section {
        case 0:
            let path = menuItemPaths[(indexPath as NSIndexPath).row]
            actionWithPath(path)
        case 1:
            if (indexPath as NSIndexPath).row == 0 {
                actionWithPath(COPYRIGHT_URL)
            } else {
                UIApplication.shared.openURL(URL(string: PROJECT_URL)!)
            }
        default: break
        }
    }
    
}

// MARK: - action

extension SideMenuViewController {
    
    func updateLoginState() {
        if let user = OAuth2.shared.currentUser , OAuth2.shared.isLogined {
            menuItems = [user.login, "edit account".localized, "notes".localized, "sign out".localized]
            menuItemIcons = [
                UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
                UIImage(named: "edit-user")!.withRenderingMode(.alwaysTemplate),
                UIImage(named: "notes")!.withRenderingMode(.alwaysTemplate),
                UIImage(named: "logout")!.withRenderingMode(.alwaysTemplate),
            ]
            menuItemPaths = ["/\(user.login)", "/account/edit", "/notes", "/logout"]
            
            KingfisherManager.shared.retrieveImage(with: user.avatarUrl, options: nil, progressBlock: nil, completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                guard let `self` = self, let avatarImage = image?.drawRectWithRoundedCorner(radius: 11, CGSize(width: 22, height: 22)) else {
                    return
                }
                self.menuItemIcons[0] = avatarImage
                self.tableView.reloadData()
            })
        } else {
            menuItems = ["sign in".localized, "sign up".localized]
            menuItemIcons = [
                UIImage(named: "login")!.withRenderingMode(.alwaysTemplate),
                UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
            ]
            menuItemPaths = ["/account/sign_in", "/account/sign_up"]
        }
        
        self.tableView.reloadData()
    }
    
}

// MARK: - private

extension SideMenuViewController {
    
    fileprivate func initRouter() {
        router.bind("/logout") { (req) in
            OAuth2.shared.logout()
        }
        router.bind("/account/sign_up") { (req) in
            if let url = URL(string: "\(ROOT_URL)/account/sign_up") {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    fileprivate func actionWithPath(_ path: String) {
        let matchedRoute = router.match(URL(string: path)!)
        if (matchedRoute == nil) {
            dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: NOTICE_MENU_CLICKED), object: self, userInfo: [NOTICE_MENU_CLICKED_PATH: path])
            })
        }
    }
    
}
