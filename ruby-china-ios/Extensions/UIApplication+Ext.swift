//
//  UIApplication+Ext.swift
//  hlios-ios
//
//  Created by kelei on 16/7/27.
//  Copyright © 2016年 Huacnlee. All rights reserved.
//

import UIKit

extension UIApplication {
    /**
     获取应用当前看到的ViewController
     
     - returns: 正在显示的ViewController
     */
    static func currentViewController() -> UIViewController? {
        let viewController = UIApplication.sharedApplication().keyWindow!.rootViewController!
        return findBestViewController(viewController)
    }
    static private func findBestViewController(viewController: UIViewController) -> UIViewController {
        if let vc = viewController.presentedViewController {
            // Return presented view controller
            return findBestViewController(vc)
        } else if let svc = viewController as? UISplitViewController where svc.viewControllers.count > 0 {
            // Return right hand side
            return findBestViewController(svc.viewControllers.last!)
        } else if let nc = viewController as? UINavigationController where nc.viewControllers.count > 0 {
            // Return top view
            return findBestViewController(nc.viewControllers.last!)
        } else if let tbc = viewController as? UITabBarController, let vc = tbc.selectedViewController {
            // Return visible view
            return findBestViewController(vc)
        }
        // Unknown view controller type, return last child view controller
        return viewController;
    }
    
}
