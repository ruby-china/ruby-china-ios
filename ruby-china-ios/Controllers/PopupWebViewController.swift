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

class PopupWebViewController: UIViewController {
    var webViewConfiguration: WKWebViewConfiguration?
    weak var delegate: PopupWebViewControllerDelegate?
    var path = ""

    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "\(ROOT_URL)\(path)?access_token=\(OAuth2.shared.accessToken)")!))
    }
    
    func  actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension PopupWebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL.path != path {
                dismissViewControllerAnimated(true, completion: nil)
                delegate?.popupWebViewControllerDidFinished(self, toURL: URL)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}