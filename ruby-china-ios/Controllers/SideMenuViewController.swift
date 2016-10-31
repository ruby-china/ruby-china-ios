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
    
    struct ItemData {
        let name: String
        let image: UIImage
        let imageColor: UIColor
        let actionURL: URL
    }
    
    fileprivate lazy var router: Router = {
        let router = Router()
        router.bind("/logout") { (req) in
            OAuth2.shared.logout()
        }
        router.bind("/account/sign_up") { (req) in
            if let url = URL(string: "\(ROOT_URL)\(req.route.route)") {
                UIApplication.shared.openURL(url)
            }
        }
        return router
    }()
    
    fileprivate var userItems = [ItemData]()
    fileprivate let userImageColors = [
        UIColor(red: 94 / 255.0, green: 151 / 255.0, blue: 246 / 255.0, alpha: 1),
        UIColor(red: 156 / 255.0, green: 204 / 255.0, blue: 101 / 255.0, alpha: 1),
        UIColor(red: 224 / 255.0, green: 96 / 255.0, blue: 85 / 255.0, alpha: 1),
        UIColor(red: 79 / 255.0, green: 195 / 255.0, blue: 247 / 255.0, alpha: 1),
        ]
    fileprivate lazy var appItems: [ItemData] = {
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        return [
            ItemData(
                name: "copyright".localized,
                image: UIImage(named: "copyright")!.withRenderingMode(.alwaysTemplate),
                imageColor: UIColor(red: 246 / 255.0, green: 191 / 255.0, blue: 50 / 255.0, alpha: 1),
                actionURL: URL(string: COPYRIGHT_URL)!
            ),
            ItemData(
                name: "Version \(APP_VERSION) (build \(build))",
                image: UIImage(named: "versions")!.withRenderingMode(.alwaysTemplate),
                imageColor: UIColor(red: 87 / 255.0, green: 187 / 255.0, blue: 138 / 255.0, alpha: 1),
                actionURL: URL(string: PROJECT_URL)!
            )
        ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ruby China"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginState), name: NSNotification.Name(rawValue: USER_CHANGED), object: nil)
        updateLoginState()
        
        tableView.backgroundColor = SIDEMENU_BG_COLOR
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0: return userItems.count
        case 1: return appItems.count
        default: return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let itemData = indexPath.section == 0 ? userItems[indexPath.row] : appItems[indexPath.row]
        cell.textLabel!.text = itemData.name
        cell.imageView?.image = itemData.image
        cell.imageView?.tintColor = itemData.imageColor
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemData = indexPath.section == 0 ? userItems[indexPath.row] : appItems[indexPath.row]
        action(forURL: itemData.actionURL)
    }
    
}

// MARK: - action

extension SideMenuViewController {
    
    func updateLoginState() {
        if let user = OAuth2.shared.currentUser , OAuth2.shared.isLogined {
            userItems = [
                ItemData(
                    name: user.login,
                    image: UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[0],
                    actionURL: URL(string: "\(ROOT_URL)/\(user.login)")!
                ),
                ItemData(
                    name: "edit account".localized,
                    image: UIImage(named: "edit-user")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[1],
                    actionURL: URL(string: "\(ROOT_URL)/account/edit")!
                ),
                ItemData(
                    name: "notes".localized,
                    image: UIImage(named: "notes")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[2],
                    actionURL: URL(string: "\(ROOT_URL)/notes")!
                ),
                ItemData(
                    name: "sign out".localized,
                    image: UIImage(named: "logout")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[3],
                    actionURL: URL(string: "\(ROOT_URL)/logout")!
                )
            ]
            
            // 下载用户头像
            let avatarSize = CGSize(width: 22, height: 22)
            let imageProcessor = RoundCornerImageProcessor(cornerRadius: avatarSize.width * 0.5, targetSize: avatarSize)
            KingfisherManager.shared.retrieveImage(with: user.avatarUrl, options: [.processor(imageProcessor)], progressBlock: nil, completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                guard let `self` = self, let avatarImage = image else {
                    return
                }
                let oldData = self.userItems[0]
                let newData = ItemData(name: oldData.name, image: avatarImage, imageColor: oldData.imageColor, actionURL: oldData.actionURL)
                self.userItems[0] = newData
                self.tableView.reloadData()
            })
        } else {
            userItems = [
                ItemData(
                    name: "sign in".localized,
                    image: UIImage(named: "login")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[0],
                    actionURL: URL(string: "\(ROOT_URL)/account/sign_in")!
                ),
                ItemData(
                    name: "sign up".localized,
                    image: UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
                    imageColor: userImageColors[1],
                    actionURL: URL(string: "\(ROOT_URL)/account/sign_up")!
                )
            ]
        }
        
        self.tableView.reloadData()
    }
    
}

// MARK: - private

extension SideMenuViewController {
    
    fileprivate func action(forURL url: URL) {
        guard let host = url.host else {
            return
        }
        if host != URL(string: ROOT_URL)!.host! {
            UIApplication.shared.openURL(url)
        } else if router.match(URL(string: url.path)!) == nil {
            dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Notification.Name(rawValue: NOTICE_MENU_CLICKED), object: self, userInfo: [NOTICE_MENU_CLICKED_PATH: url.path])
            })
        }
    }
    
}
