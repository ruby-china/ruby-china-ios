//
//  BasePopupWebViewController.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/8/9.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Foundation

import UIKit
import WebKit

protocol PopupWebViewControllerDelegate: class {
    func popupWebViewControllerDidFinished(controller: PopupWebViewController, toURL url: NSURL?)
}

class PopupWebViewController: WebViewController {
    weak var delegate: PopupWebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "关闭", style: .Plain, target: self, action:  #selector(actionClose))
    }
    
    func  actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PopupWebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL.path != self.currentPath {
                dismissViewControllerAnimated(true, completion: nil)
                delegate?.popupWebViewControllerDidFinished(self, toURL: URL)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}