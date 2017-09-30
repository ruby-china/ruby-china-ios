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
import Turbolinks

protocol PopupWebViewControllerDelegate: class {
    func popupWebViewControllerDidFinished(_ controller: PopupWebViewController, toURL url: URL?)
}

class PopupWebViewController: WebViewController {
    weak var delegate: PopupWebViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "close".localized, style: .plain, target: self, action: #selector(actionClose))
    }
    
    @objc func actionClose() {
        dismiss(animated: true, completion: nil)
    }
    
    func doDidFinished(toURL: URL) {
        dismiss(animated: true, completion: nil)
        delegate?.popupWebViewControllerDidFinished(self, toURL: toURL)
    }
    
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {
        if URL.path != self.currentPath {
            doDidFinished(toURL: URL)
            return
        }
    }
}

extension PopupWebViewController: WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.httpMethod == "GET") {
            if let URL = navigationAction.request.url , URL.path != self.currentPath {
                doDidFinished(toURL: URL)
                decisionHandler(.cancel)
                return
            }
        }
        
        decisionHandler(.allow)
    }
    
}
