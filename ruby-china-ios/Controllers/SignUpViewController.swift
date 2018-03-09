//
//  SignUpViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 2016/12/1.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SignUpViewController: PopupWebViewController {
    
    @discardableResult static func show() -> SignUpViewController {
        let controller = SignUpViewController(path: "/account/sign_up")
        NotificationCenter.default.post(name: NSNotification.Name.userSignout, object: nil)
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
        return controller
    }
    
    override func doDidFinished(toURL: URL) {
        super.doDidFinished(toURL: toURL)
        DispatchQueue.main.async {
            self.clearSession()
            RBHUD.success("sign up success tips".localized)
        }
    }
    
}
