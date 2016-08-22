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

    func visitableDidRequestRefresh(visitable: Visitable) {
        session.visitableDidRequestRefresh(visitable)
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
    
    private let kMessageHandlerName = "NativeApp"
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.addScriptMessageHandler(self, name: self.kMessageHandlerName)
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
            var urlString = ROOT_URL + path
            if let accessToken = OAuth2.shared.accessToken {
                urlString += "?access_token=" + accessToken
            }
            topWebViewController.visitableURL = NSURL(string: urlString)!
            session.reload()
        } else {
            let visitable = WebViewController(path: path)

            if action == .Advance {
                visitable.hideTabBar(tabBarHidden: topNavigationController?.viewControllers.count >= 1)
                topWebViewController.navigationController?.pushViewController(visitable, animated: true)
            } else if action == .Replace {
                topWebViewController.navigationController?.popViewControllerAnimated(false)
                topWebViewController.navigationController?.pushViewController(visitable, animated: false)
            } else {
                visitable.hideTabBar(tabBarHidden: topNavigationController?.viewControllers.count >= 1)
                topWebViewController.navigationController?.pushViewController(visitable, animated: false)
            }
        }
    }

    func actionToPath(path: String, withAction action: Action) {
        let matched = router.match(NSURL.init(string: path)!)
        var realAction = action

        if ((matched == nil)) {
            if (session.webView.URL?.path == path) {
                // 如果要访问的地址是相同的，直接 Restore，而不是创建新的页面
                realAction = .Restore
            }

            presentVisitableForSession(path, withAction: realAction)
        }
    }

    private func presentLoginController() {
        let controller = SignInViewController()
        controller.delegate = self

        let navController = ThemeNavigationController(rootViewController: controller)
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

        let navController = ThemeNavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }

    private func presentProfileController(path: String) {
        let controller = ProfileViewController()
        controller.delegate = self
        controller.webViewConfiguration = webViewConfiguration
        controller.path = path

        let navController = ThemeNavigationController(rootViewController: controller)
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

        let navController = ThemeNavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }

    private func presentEditAccountController() {
        let controller = EditAccountViewController()
        controller.webViewConfiguration = webViewConfiguration

        let navController = ThemeNavigationController(rootViewController: controller)
        topNavigationController?.presentViewController(navController, animated: true, completion: nil)
    }
}

extension TurbolinksSessionLib: SessionDelegate {
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        let path = URL.path
        actionToPath(path!, withAction: action)
    }

    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let viewController = visitable as? WebViewController, errorCode = ErrorCode(rawValue: error.code) else { return }

        switch errorCode {
        case .HTTPFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 302, 401:
                OAuth2.shared.logout()
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
    func signInViewControllerDidAuthenticate(sender: SignInViewController) {
        // 重新载入之前的页面
        session.reload()
    }
}

extension TurbolinksSessionLib: PopupWebViewControllerDelegate {
    func popupWebViewControllerDidFinished(controller: PopupWebViewController, toURL url: NSURL?) {
        if (url == nil) {
            session.reload()
            return
        }

        if (controller.path == "topics/new") {
            actionToPath(url!.path!, withAction: .Advance)
        } else {
            session.reload()
        }
    }
}

// MARK: - WKScriptMessageHandler

extension TurbolinksSessionLib: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if message.name != kMessageHandlerName {
            return
        }
        guard let dic = message.body as? [String: AnyObject] else {
            return
        }
        // window.webkit.messageHandlers.NativeApp.postMessage({func: "alert_success", message: "成功"})
        if let funcName = dic["func"] as? String, message = dic["message"] as? String {
            if funcName == "alert_success" {
                RBHUD.success(message)
            } else {
                RBHUD.error(message)
            }
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
