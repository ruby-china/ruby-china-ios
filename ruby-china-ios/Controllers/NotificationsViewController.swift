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
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "trash"), style: .Plain, target: self, action: #selector(cleanNotificationsAction))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.cleanBadge()
        reloadVisitable()
    }
    
    func cleanNotificationsAction() {
        visitableView.webView?.evaluateJavaScript("$('#btn-remove-all').click();") { [weak self](obj, err) in
            self?.cleanBadge()
            self?.visitableView.webView?.reload()
        }
    }
    
    func cleanBadge() {
        if let app = UIApplication.sharedApplication().delegate as? AppDelegate {
            app.setBadge(0)
        }
    }
}
