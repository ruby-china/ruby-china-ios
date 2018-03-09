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
        let actionURL: URL?
    }
    
    fileprivate lazy var router: Router = {
        let router = Router()
        router.bind("/logout") { (req) in
            OAuth2.shared.logout()
        }
        return router
    }()
    
    private lazy var datas: [[ItemData]] = {
        var datas = [[ItemData]]()
        
        datas.append([ItemData]())
        let build = Bundle.main.infoDictionary!["CFBundleVersion"] as! String
        datas.append([
            ItemData(
                name: "wiki".localized,
                image: UIImage(named: "wiki")!.withRenderingMode(.alwaysTemplate),
                imageColor: PRIMARY_COLOR,
                actionURL: URL(string: "\(ROOT_URL)/wiki")!
            ),
            ItemData(
                name: "copyright".localized,
                image: UIImage(named: "copyright")!.withRenderingMode(.alwaysTemplate),
                imageColor: PRIMARY_COLOR,
                actionURL: URL(string: COPYRIGHT_URL)!
            ),
            ItemData(
                name: "v\(APP_VERSION) (build \(build))",
                image: UIImage(named: "versions")!.withRenderingMode(.alwaysTemplate),
                imageColor: PRIMARY_COLOR,
                actionURL: nil
            )
        ])
        
        return datas
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Ruby China"
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateLoginState), name: NSNotification.Name(NOTICE_USER_CHANGED), object: nil)
        updateLoginState()
        
        tableView.backgroundColor = SIDEMENU_BG_COLOR
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return datas.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return datas[section].count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let itemData = datas[indexPath.section][indexPath.row]
        cell.textLabel!.text = itemData.name
        cell.imageView?.image = itemData.image
        cell.imageView?.tintColor = itemData.imageColor
        cell.selectionStyle = itemData.actionURL == nil ? .none : .blue
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let itemData = datas[indexPath.section][indexPath.row]
        if let url = itemData.actionURL {
            action(forURL: url)
        }
    }
    
}

// MARK: - action
@objc
extension SideMenuViewController {
    
    func updateLoginState() {
        let kUserSection = 0
        if let user = OAuth2.shared.currentUser , OAuth2.shared.isLogined {
            datas[kUserSection] = [
                ItemData(
                    name: user.login,
                    image: UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/\(user.login)")!
                ),
                ItemData(
                    name: "edit account".localized,
                    image: UIImage(named: "edit-user")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/account/edit")!
                ),
                ItemData(
                    name: "title new topic".localized,
                    image: UIImage(named: "new")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/topics/new")!
                ),
                ItemData(
                    name: "favorites".localized,
                    image: UIImage(named: "favorites")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/topics/favorites")!
                ),
                ItemData(
                    name: "notes".localized,
                    image: UIImage(named: "notes")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/notes")!
                ),
                ItemData(
                    name: "sign out".localized,
                    image: UIImage(named: "logout")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/logout")!
                )
            ]
            
            // 下载用户头像
            let avatarSize = CGSize(width: 44, height: 44)
            let imageProcessor = RoundCornerImageProcessor(cornerRadius: avatarSize.width * 0.5, targetSize: avatarSize)
            KingfisherManager.shared.retrieveImage(with: user.avatarUrl, options: [.processor(imageProcessor)], progressBlock: nil, completionHandler: { [weak self] (image, error, cacheType, imageURL) in
                guard let `self` = self, let image = image, let cgImage = image.cgImage else {
                    return
                }
                let avatarImage = UIImage(cgImage: cgImage, scale: 2, orientation: image.imageOrientation)
                let oldData = self.datas[kUserSection][0]
                let newData = ItemData(name: oldData.name, image: avatarImage, imageColor: oldData.imageColor, actionURL: oldData.actionURL)
                self.datas[kUserSection][0] = newData
                self.tableView.reloadData()
            })
        } else {
            datas[kUserSection] = [
                ItemData(
                    name: "sign in".localized,
                    image: UIImage(named: "login")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/account/sign_in")!
                ),
                ItemData(
                    name: "sign up".localized,
                    image: UIImage(named: "profile")!.withRenderingMode(.alwaysTemplate),
                    imageColor: PRIMARY_COLOR,
                    actionURL: URL(string: "\(ROOT_URL)/account/sign_up")!
                )
            ]
        }
        
        self.tableView.reloadData()
    }
    
}

// MARK: - private
@objc
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
