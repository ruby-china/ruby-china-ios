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
import SKPhotoBrowser

class TurbolinksSessionLib: NSObject {
    static let shared: TurbolinksSessionLib = {
        return TurbolinksSessionLib()
    }()
    
    func visit(_ visitable: Visitable) {
        session.visit(visitable)
        visitable.visitableView.webView?.uiDelegate = self
    }
    
    func visitableDidRequestRefresh(_ visitable: Visitable) {
        session.visitableDidRequestRefresh(visitable)
    }
    
    fileprivate lazy var router: Router = {
        let router = Router()
        router.bind("/account/edit") { req in
            self.presentEditAccountController(req.route.route)
        }
        router.bind("/topics/new") { req in
            self.presentEditTopicController(req.route.route)
        }
        router.bind("/topics/node:id") { req in
            if let idString = req.param("id"), let nodeID = Int(idString) {
                self.pushNodeTopicsController(nodeID)
            }
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
        
        router.bind("/topics/:id") { req in
            if let idString = req.param("id"), let id = Int(idString),
                let navigationController = UIApplication.currentViewController()?.navigationController {
                let vc = TopicDetailsViewController(topicID: id, topicPath: req.url.absoluteString)
                navigationController.pushViewController(vc, animated: true)
            }
        }
        return router
    }()
    
    fileprivate var application: UIApplication {
        return UIApplication.shared
    }
    
    fileprivate let kMessageHandlerName = "NativeApp"
    
    fileprivate lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.userContentController.add(self, name: self.kMessageHandlerName)
        configuration.applicationNameForUserAgent = USER_AGENT
        configuration.processPool = WKProcessPool()
        return configuration
    }()
    
    fileprivate lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    func action(_ action: Action, path: String) {
        if let _ = router.match(URL(string: path)!) {
            return
        }
        
        var realAction = action
        // 检查 parentViewController 是因为 topmostVisitable 可能已被移除，但因 session 持有 topmostVisitable，所以导致其被移除后未被释放
        if let vc = session.topmostVisitable as? WebViewController, let _ = vc.parent , session.webView.url?.path == path {
            // 如果要访问的地址是相同的，直接 Restore，而不是创建新的页面
            realAction = .Restore
        }
        
        if (realAction == .Restore) {
            guard let topWebViewController = session.topmostVisitable as? WebViewController else {
                return
            }
            
            var urlString = ROOT_URL + path
            if let accessToken = OAuth2.shared.accessToken {
                urlString += "?access_token=" + accessToken
            }
            topWebViewController.visitableURL = URL(string: urlString)!
            session.reload()
        } else {
            guard let navigationController = UIApplication.currentViewController()?.navigationController else {
                return
            }
            
            let visitable = WebViewController(path: path)
            if realAction == .Advance {
                navigationController.pushViewController(visitable, animated: true)
            } else if realAction == .Replace {
                navigationController.popViewController(animated: false)
                navigationController.pushViewController(visitable, animated: false)
            } else {
                navigationController.pushViewController(visitable, animated: false)
            }
        }
    }
    
    func safariOpen(_ url: URL) {
        let safariViewController = SFSafariViewController(url: url)
        UIApplication.currentViewController()?.present(safariViewController, animated: true, completion: nil)
    }
    
    fileprivate func presentLoginController() {
        SignInViewController.show().delegate = self
    }
    
    fileprivate func presentEditTopicController(_ path: String) {
        if (!OAuth2.shared.isLogined) {
            presentLoginController()
            return
        }
        
        let controller = NewTopicViewController(path: path)
        controller.delegate = self
        
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func presentProfileController(_ path: String) {
        let controller = ProfileViewController(path: path)
        controller.delegate = self
        
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func presentEditReplyController(_ path: String) {
        if (!OAuth2.shared.isLogined) {
            presentLoginController()
            return
        }
        
        let controller = EditReplyViewController(path: path)
        controller.delegate = self
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func presentEditAccountController(_ path: String) {
        let controller = EditAccountViewController(path: path)
        controller.delegate = self
        let navController = ThemeNavigationController(rootViewController: controller)
        UIApplication.currentViewController()?.present(navController, animated: true, completion: nil)
    }
    
    fileprivate func presentImageBrowserController(_ url: URL) {
        if (SKCache.sharedCache.imageCache as? CustomImageCache) == nil {
            SKCache.sharedCache.imageCache = CustomImageCache()
        }
        
        let photo = SKPhoto.photoWithImageURL(url.absoluteString)
        photo.shouldCachePhotoURLImage = true
        
        let browser = SKPhotoBrowser(photos: [photo])
        UIApplication.currentViewController()?.present(browser, animated: true, completion: nil)
    }
    
    fileprivate func pushNodeTopicsController(_ nodeID: Int) {
        let controller = TopicsViewController()
        controller.load(listType: .last_actived, nodeID: nodeID, offset: 0)
        UIApplication.currentViewController()?.navigationController?.pushViewController(controller, animated: true)
    }
}

extension TurbolinksSessionLib: SessionDelegate {
    func session(_ session: Session, didProposeVisitToURL URL: Foundation.URL, withAction action: Action) {
        let path = URL.path
        
        if let popupWebViewController = session.topmostVisitable as? PopupWebViewController {
            popupWebViewController.session(session, didProposeVisitToURL: URL, withAction: action)
            return
        }
        
        self.action(action, path: path)
    }
    
    func session(_ session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
        guard let viewController = visitable as? WebViewController, let errorCode = ErrorCode(rawValue: error.code) else { return }
        
        switch errorCode {
        case .httpFailure:
            let statusCode = error.userInfo["statusCode"] as! Int
            switch statusCode {
            case 401:
                if OAuth2.shared.isLogined {
                    presentLoginController()
                }
            case 404:
                viewController.presentError(.HTTPNotFoundError)
            default:
                viewController.presentError(Error(HTTPStatusCode: statusCode))
            }
        case .networkFailure:
            viewController.presentError(.NetworkError)
        }
    }
    
    func sessionDidStartRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = true
    }
    
    func sessionDidFinishRequest(_ session: Session) {
        application.isNetworkActivityIndicatorVisible = false
    }
    
    func sessionDidLoadWebView(_ session: Session) {
        session.webView.navigationDelegate = self
    }
}

extension TurbolinksSessionLib: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> ()) {
        
        // PopupViewController
        if let popupWebViewController = session.topmostVisitable as? PopupWebViewController {
            popupWebViewController.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
            return
        }
        
        // kelei 2016-10-08
        // 帖子中有 Youtube 视频时，会触发此方法。
        // po navigationAction 返回 <WKNavigationAction: 0x7fd0f9422eb0; navigationType = -1; syntheticClickType = 0; request = <NSMutableURLRequest: 0x61800001e700> { URL: https://www.youtube.com/embed/xMFs9DTympQ }; sourceFrame = (null); targetFrame = <WKFrameInfo: 0x7fd0f9401030; isMainFrame = NO; request = (null)>>
        // 所有这里判断一下 navigationType 值来修复进入帖子自动打开 Youtube 网页的问题
        if navigationAction.navigationType.rawValue < 0 {
            decisionHandler(.allow)
            return
        }
        
        if let url = navigationAction.request.url {
            let ext = url.pathExtension.lowercased()
            if (["jpg", "jpeg", "png", "gif"].filter{ ext.hasPrefix($0) }).count > 0 {
                // 查看图片
                presentImageBrowserController(url)
            } else if let host = url.host , host != URL(string: ROOT_URL)!.host! {
                // 外部网站, open in SafariView
                safariOpen(url)
            } else if var newURL = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                newURL.scheme = nil
                newURL.host = nil
                action(.Advance, path: newURL.string!)
            }
        }
        decisionHandler(.cancel)
    }
}

extension TurbolinksSessionLib: SignInViewControllerDelegate {
    func signInViewControllerDidAuthenticate(_ sender: SignInViewController) {
        // 重新载入之前的页面
        session.reload()
    }
}

extension TurbolinksSessionLib: PopupWebViewControllerDelegate {
    func popupWebViewControllerDidFinished(_ controller: PopupWebViewController, toURL url: URL?) {
        if (url == nil) {
            session.reload()
            return
        }
        
        if (controller.currentPath == "topics/new") {
            action(.Advance, path: url!.path)
        } else {
            session.reload()
        }
    }
}

// MARK: - WKScriptMessageHandler

extension TurbolinksSessionLib: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name != kMessageHandlerName {
            return
        }
        guard let dic = message.body as? [String: AnyObject] else {
            return
        }
        // window.webkit.messageHandlers.NativeApp.postMessage({func: "alert_success", message: "成功"})
        if let funcName = dic["func"] as? String, let message = dic["message"] as? String {
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
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler()
        }))
        UIApplication.currentViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: "Ruby China", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .cancel, handler: { _ in
            completionHandler(false)
        }))
        UIApplication.currentViewController()?.present(alert, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .alert)
        alert.addTextField { (textField: UITextField) -> Void in
            textField.textColor = UIColor.red
        }
        alert.addAction(UIAlertAction(title: "确定", style: .default, handler: { _ in
            completionHandler(alert.textFields![0].text!)
        }))
        UIApplication.currentViewController()?.present(alert, animated: true, completion: nil)
    }
}
