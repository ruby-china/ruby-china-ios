//
//  NotificationsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/8/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class NotificationsViewController: WebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage.init(named: "trash"), style: .Plain, target: self, action: #selector(cleanNotificationsAction))
    }
    
    func cleanNotificationsAction() {
        visitableView.webView?.evaluateJavaScript("$('#btn-remove-all').click();", completionHandler: { (obj, err) in
            self.visitableView.webView?.reload()
            OAuth2.shared.refreshUnreadNotifications()
        })
    }
}
