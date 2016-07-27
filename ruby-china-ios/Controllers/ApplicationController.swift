import UIKit
import WebKit
import Turbolinks
import SafariServices
import SideMenu

class ApplicationController: UINavigationController {    
    private let webViewProcessPool = WKProcessPool()
    
    var menuButton = UIBarButtonItem()
    
    var filterSegment = UISegmentedControl()
    
    var mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    var sideMenuController: SideMenuNavigationController?
    var sideMenuTableViewController: SideMenuViewController?
    
    var rootPath = "/topics"
    
    var newButton = UIBarButtonItem()
    
    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = self.webViewProcessPool
        configuration.userContentController.addScriptMessageHandler(self, name: "ruby-china-turbolinks")
        configuration.applicationNameForUserAgent = USER_AGENT
        return configuration
    }()
    
    private lazy var session: Session = {
        let session = Session(webViewConfiguration: self.webViewConfiguration)
        session.delegate = self
        return session
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationBar.tintColor = UIColor.blackColor()
        
        initSideMenu()
        
        menuButton = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .Plain, target: self, action: #selector(ApplicationController.actionSideMenu))
        
        newButton = UIBarButtonItem.init(image: UIImage.init(named: "send"), style: .Plain, target: self, action: #selector(ApplicationController.actionNewTopic))
        
        filterSegment = UISegmentedControl.init(items: ["默认","精选", "最新", "招聘"])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(actionFilterChanged), forControlEvents: .ValueChanged)
        
        actionToPath(rootPath, withAction: .Restore)
    }
    
    private func presentVisitableForSession(session: Session, path: String, withAction action: Action = .Advance) {
        var url = NSURL(string: "\(ROOT_URL)\(path)")
        
        if (OAuth2.shared.isLogined) {
            url = NSURL(string: "\(ROOT_URL)\(path)?access_token=\(OAuth2.shared.accessToken)")
        }
        
        if (action == .Restore && topViewController != nil) {
            let visitable = topViewController as! WebViewController
            visitable.visitableURL = url
            session.reload()
        } else {
        
            let visitable = WebViewController(URL: url!)
            if action == .Advance {
                pushViewController(visitable, animated: true)
            } else if action == .Replace {
                popViewControllerAnimated(false)
                pushViewController(visitable, animated: false)
            } else {
                pushViewController(visitable, animated: false)
            }
    
            session.visit(visitable)
        }
    }

    func actionNotifications() {
        presentVisitableForSession(session, path: "/notifications")
    }
    
    func actionSideMenu() {
        if (sideMenuController != nil) {
            presentViewController(sideMenuController!, animated: true, completion: nil)
        }
    }
    
    func actionNewTopic() {
        presentNewTopicController()
    }
    
    func actionFilterChanged() {
        switch filterSegment.selectedSegmentIndex {
        case 1:
            actionToPath("/topics/popular", withAction: .Restore)
        case 2:
            actionToPath("/topics/last", withAction: .Restore)
        case 3:
            actionToPath("/jobs", withAction: .Restore)
        default:
            actionToPath("/topics", withAction: .Restore)
        }
    }
    
    func actionToPath(path: String, withAction action: Action) {
        if path == "/account/sign_in" {
            presentLoginController()
        } else if (path == "/topics/new") {
            presentNewTopicController()
        } else if (path == "/account/edit") {
            presentEditAccountController()
        }else {
            presentVisitableForSession(session, path: path, withAction: action)
        }
    }
    
    func initSideMenu() {
        sideMenuController = mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuController") as?SideMenuNavigationController
        sideMenuTableViewController = mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuTableViewController") as? SideMenuViewController
        SideMenuManager.menuLeftNavigationController = sideMenuController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        SideMenuManager.menuAddPanGestureToPresent(toView: navigationBar)
//        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ApplicationController.menuClicked(_:)), name: "menuClicked", object: nil)
    }
    
    func menuClicked(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let path = userInfo["path"] as! String
        
        self.actionToPath(path, withAction: .Restore)
    }
    
    private func presentLoginController() {
        let controller = SignInViewController()
        controller.delegate = self
        
        let navController = UINavigationController(rootViewController: controller)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    private func presentNewTopicController() {
        if (!OAuth2.shared.isLogined) {
            presentLoginController()
            return
        }
        
        let controller = NewTopicViewController()
        controller.delegate = self
        controller.webViewConfiguration = webViewConfiguration
        
        let navController = UINavigationController(rootViewController: controller)
        presentViewController(navController, animated: true, completion: nil)
    }
    
    private func presentEditAccountController() {
        let controller = EditAccountViewController()
        controller.webViewConfiguration = webViewConfiguration
        
        let navController = UINavigationController(rootViewController: controller)
        presentViewController(navController, animated: true, completion: nil)
    }
}

extension ApplicationController: SessionDelegate {
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

extension ApplicationController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> ()) {
        let url = navigationAction.request.URL
        if (url?.host != NSURL(string: ROOT_URL)?.host) {
            // 外部网站, open in SafariView
            let safariViewController = SFSafariViewController(URL: url!)
            presentViewController(safariViewController, animated: true, completion: nil)
        } else {
            actionToPath((url?.path)!, withAction: .Advance)
        }
        decisionHandler(.Cancel)
    }
}


extension ApplicationController: SignInViewControllerDelegate {
    func signInViewControllerDidAuthenticate(controller: SignInViewController) {
        // 重新载入之前的页面
        if (session.webView.URL?.path != nil ){
            actionToPath((session.webView.URL?.path)!, withAction: .Restore)
        } else {
            session.reload()
        }
    }
}

extension ApplicationController: NewTopicViewControllerDelegate {
    func newTopicViewDidFinished(controller: NewTopicViewController, toURL url: NSURL) {
        actionToPath(url.path!, withAction: .Advance)
    }
}

extension ApplicationController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Ruby China", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}