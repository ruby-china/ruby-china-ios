import UIKit
import WebKit
import Turbolinks
import SafariServices
import SideMenu
import Router

class ApplicationController: UINavigationController {
    private let webViewProcessPool = WKProcessPool()
    
    var menuButton = UIBarButtonItem()
    
    var filterSegment = UISegmentedControl()
    
    lazy var mainStoryboard: UIStoryboard = {
        return UIStoryboard.init(name: "Main", bundle: nil)
    }()
    lazy var sideMenuController: SideMenuNavigationController? = {
        return self.mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuController") as?SideMenuNavigationController
    }()
    lazy var sideMenuTableViewController: SideMenuViewController? = {
        return self.mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuTableViewController") as? SideMenuViewController
    }()
    
    var rootPath = "/topics"
    
    let router = Router()
    
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
        
        initRouter()
        
        menuButton = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .Plain, target: self, action: #selector(ApplicationController.actionSideMenu))
        
        newButton = UIBarButtonItem.init(image: UIImage.init(named: "send"), style: .Plain, target: self, action: #selector(ApplicationController.actionNewTopic))
        
        filterSegment = UISegmentedControl.init(items: ["默认","精选", "最新", "招聘"])
        filterSegment.selectedSegmentIndex = 0
        filterSegment.addTarget(self, action: #selector(actionFilterChanged), forControlEvents: .ValueChanged)
        
        interactivePopGestureRecognizer?.delegate = self
        
        actionToPath(rootPath, withAction: .Restore)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        initSideMenu()
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
    
    func initRouter() {
        router.bind("/account/edit") { (req) in
            self.presentEditAccountController()
        }
        
        router.bind("/topics/new") { (req) in
            self.presentEditTopicController("/topics/new")
        }
        
        router.bind("/topics/:id/edit") { (req) in
            self.presentEditTopicController("/topics/\(req.param("id")!)/edit")
        }
        
        router.bind("/account/sign_in") { (req) in
            self.presentLoginController()
        }
        
        router.bind("/topics/:topic_id/replies/:id/edit") { (req) in
            let path = "/topics/\(req.param("topic_id")!)/replies/\(req.param("id")!)/edit"
            self.presentEditReplyController(path)
        }
    }
    
    func actionSideMenu() {
        if (sideMenuController != nil) {
            presentViewController(sideMenuController!, animated: true, completion: nil)
        }
    }
    
    func actionNewTopic() {
        actionToPath("/topics/new", withAction: .Replace)
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
        let matched = router.match(NSURL.init(string: path)!)
        var realAction = action
        
        if ((matched == nil)) {
            if (session.webView.URL?.path == path) {
                // 如果要访问的地址是相同的，直接 Replace，而不是创建新的页面
                realAction = .Replace
            }
        
            presentVisitableForSession(session, path: path, withAction: realAction)
        }
    }
    
    func initSideMenu() {
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
        presentViewController(navController, animated: true, completion: nil)
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

extension ApplicationController: EditReplyViewControllerDelegate {
    func editReplyViewDidFinished(controller: EditReplyViewController, toURL url: NSURL) {
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

extension ApplicationController: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(gestureRecognizer: UIGestureRecognizer) -> Bool {
        if (viewControllers.count > 1) {
            return true
        }
        return false
    }
}