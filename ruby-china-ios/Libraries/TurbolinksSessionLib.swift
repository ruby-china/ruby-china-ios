//
//  TurbolinksSessionLib.swift
//  ruby-china-ios
//
//  Created by kelei on 16/7/27.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import Turbolinks
import WebKit
import Router
import SafariServices

class TurbolinksSessionLib: NSObject {
    static let sharedInstance: TurbolinksSessionLib = {
        return TurbolinksSessionLib()
    }()
    
    func visit(visitable: Visitable) {
        session.visit(visitable)
        visitable.visitableView.webView?.UIDelegate = self
    }
    
    private lazy var router: Router = {
        let router = Router()
        router.bind("/account/edit") { _ in
            self.presentEditAccountController()
        }
        router.bind("/topics/new") { _ in
            self.presentEditTopicController("/topics/new")
        }
        router.bind("/topics/:id/edit") { req in
            self.presentEditTopicController("/topics/\(req.param("id")!)/edit")
        }
        router.bind("/account/sign_in") { _ in
            self.presentLoginController()
        }
        router.bind("/topics/:topic_id/replies/:id/edit") { req in
            let path = "/topics/\(req.param("topic_id")!)/replies/\(req.param("id")!)/edit"
            self.presentEditReplyController(path)
        }
        return router
    }()
    
    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addScriptMessageHandler(self, name: "ruby-china-turbolinks")
        configuration.applicationNameForUserAgent = USER_AGENT
        configuration.processPool = WKProcessPool()
        return configuration
    }()
    
    private lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    private var topNavigationController: UINavigationController? {
        if let topWebViewController = session.topmostVisitable as? WebViewController {
            return topWebViewController.navigationController
        }
        return nil
    }
    
    private func presentVisitableForSession(path: String, withAction action: Action = .Advance) {
        
        guard let topWebViewController = session.topmostVisitable as? WebViewController else {
            return
        }
        
        if (action == .Restore) {
            var urlString = "\(ROOT_URL)\(path)"
            if (OAuth2.shared.isLogined) {
                urlString += "?access_token=\(OAuth2.shared.accessToken)"
            }
            topWebViewController.visitableURL = NSURL(string: urlString)!
            session.reload()
        } else {
            let visitable = WebViewController(path: path)
            if action == .Advance {
                topWebViewController.navigationController?.pushViewController(visitable, animated: true)
            } else if action == .Replace {
                topWebViewController.navigationController?.popViewControllerAnimated(false)
                topWebViewController.navigationController?.pushViewController(visitable, animated: false)
            } else {
                topWebViewController.navigationController?.pushViewController(visitable, animated: false)
            }
        }
    }
    
    func actionToPath(path: String, withAction action: Action) {
        let matched = router.match(NSURL.init(string: path)!)
        var realAction = action
        
        if ((matched == nil)) {
            if (session.webView.URL?.path == path) {
                // 如果要访问的地址是相同的，直接 Replace，而不是创建新的页面
                realAction = .Replace
            }
            
            presentVisitableForSession(path, withAction: realAction)
        }
    }
    
    private func presentLoginController() {
        let controller = SignInViewController()
        controller.delegate = self
        
        let navController = UINavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    private func presentEditTopicController(path: String) {
        if (!OAuth2.shared.isLogined) {
            presentLoginController()
            return
        }
        
        let controller = NewTopicViewController()
        controller.delegate = self
        controller.webViewConfiguration = webViewConfiguration
        controller.path = path
        
        let navController = UINavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    private func presentEditReplyController(path: String) {
        if (!OAuth2.shared.isLogined) {
            presentLoginController()
            return
        }
        
        let controller = EditReplyViewController()
        controller.delegate = self
        controller.webViewConfiguration = webViewConfiguration
        controller.path = path
        
        let navController = UINavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }
    
    private func presentEditAccountController() {
        let controller = EditAccountViewController()
        controller.webViewConfiguration = webViewConfiguration
        
        let navController = UINavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }
}

extension TurbolinksSessionLib: SessionDelegate {
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        let path = URL.path
        actionToPath(path!, withAction: action)
    }
    
    func session(session: Session, openExternalURL URL: NSURL) {
        // 外部网站, open in SafariView
        // TODO: 貌似 turbolinks-ios 的 Bug，target="_blank" 的连接无法触发这个事件
        //       https://github.com/turbolinks/turbolinks-ios/issues/51
        let safariViewController = SFSafariViewController(URL: URL)
        topNavigationController?.presentViewController(safariViewController, animated: true, completion: nil)
    }
    
    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let viewController = visitable as? WebViewController, errorCode = ErrorCode(rawValue: error.code) else { return }
        
        switch errorCode {
        case .HTTPFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 401:
                presentLoginController()
            case 302:
                presentLoginController()
            case 404:
                viewController.presentError(.HTTPNotFoundError)
            default:
                viewController.presentError(Error(HTTPStatusCode: statusCode))
            }
        case .NetworkFailure:
            viewController.presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(session: Session) {
        application.networkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(session: Session) {
        application.networkActivityIndicatorVisible = false
    }
    
    func sessionDidLoadWebView(session: Session) {
        session.webView.navigationDelegate = self
    }
}

extension TurbolinksSessionLib: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> ()) {
        let url = navigationAction.request.URL
        if (url?.host != NSURL(string: ROOT_URL)?.host) {
            // 外部网站, open in SafariView
            let safariViewController = SFSafariViewController(URL: url!)
            topNavigationController?.presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            actionToPath((url?.path)!, withAction: .Advance)
        }
        decisionHandler(.Cancel)
    }
}


extension TurbolinksSessionLib: SignInViewControllerDelegate {
    func signInViewControllerDidAuthenticate(controller: SignInViewController) {
        // 重新载入之前的页面
        if (session.webView.URL?.path != nil ){
            actionToPath((session.webView.URL?.path)!, withAction: .Restore)
        } else {
            session.reload()
        }
    }
}

extension TurbolinksSessionLib: NewTopicViewControllerDelegate {
    func newTopicViewDidFinished(controller: NewTopicViewController, toURL url: NSURL) {
        actionToPath(url.path!, withAction: .Advance)
    }
}

extension TurbolinksSessionLib: EditReplyViewControllerDelegate {
    func editReplyViewDidFinished(controller: EditReplyViewController, toURL url: NSURL) {
        actionToPath(url.path!, withAction: .Advance)
    }
}

// MARK: - WKScriptMessageHandler

extension TurbolinksSessionLib: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Ruby China", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            topNavigationController?.presentViewController(alertController, animated: true, completion: nil)
        }
    }
}

// MARK: - WKUIDelegate

extension TurbolinksSessionLib: WKUIDelegate {
    // 这个方法是在HTML中调用了JS的alert()方法时，就会回调此API。
    // 注意，使用了`WKWebView`后，在JS端调用alert()就不会在HTML
    // 中显示弹出窗口。因此，我们需要在此处手动弹出ios系统的alert。
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { _ in
            completionHandler()
        }))
        topNavigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alert = UIAlertController(title: "Ruby China", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { _ in
            completionHandler(false)
        }))
        topNavigationController?.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .Alert)
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.textColor = UIColor.redColor()
        }
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { _ in
            completionHandler(alert.textFields![0].text!)
        }))
        topNavigationController?.presentViewController(alert, animated: true, completion: nil)
    }
}
