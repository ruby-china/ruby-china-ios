//
//  SignUpViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 2016/12/1.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class SignUpViewController: PopupWebViewController {
    
    static func show(withSuperController: UIViewController) {
        let controller = SignUpViewController(path: "/account/sign_up")
        let navController = ThemeNavigationController(rootViewController: controller)
        withSuperController.present(navController, animated: true, completion: nil)
    }
    
    override func doDidFinished(toURL: URL) {
        super.doDidFinished(toURL: toURL)
        // 清除 Session
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: NSNotification.Name(NOTICE_SIGNOUT), object: nil)
            RBHUD.success("sign up success tips".localized)
        }
    }
    
}
