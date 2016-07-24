import UIKit
import WebKit
import Turbolinks
import SafariServices
import SideMenu

class ApplicationController: UINavigationController {
    #if DEBUG
    let ROOT_URL = "http://127.0.0.1:3000"
    #else
    let ROOT_URL = "https://ruby-china.org"
    #endif
    let USER_AGENT = "turbolinks-app, ruby-china, official"
    
    private let webViewProcessPool = WKProcessPool()
    
    var menuButton = UIBarButtonItem()
    var notificationsButton = UIBarButtonItem()
    var mainStoryboard = UIStoryboard.init(name: "Main", bundle: nil)
    var sideMenuController: SideMenuNavigationController?
    var sideMenuTableViewController: SideMenuViewController?
    
    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = self.webViewProcessPool
        configuration.userContentController.addScriptMessageHandler(self, name: "ruby-china-turbolinks")
        configuration.applicationNameForUserAgent = self.USER_AGENT
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
        
        notificationsButton = UIBarButtonItem.init(image: UIImage.init(named: "box"), style: .Plain, target: self, action: #selector(ApplicationController.actionNotifications))
        
        actionToPath("/topics", withAction: .Restore)
    }
    
    private func presentVisitableForSession(session: Session, path: String, withAction action: Action = .Advance) {
        let visitable = WebViewController(URL: NSURL(string: "\(ROOT_URL)\(path)")!)
        
        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewControllerAnimated(false)
            pushViewController(visitable, animated: false)
        } else {
            viewControllers.removeAll()
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }

    func actionNotifications() {
        presentVisitableForSession(session, path: "/notifications")
    }
    
    func actionSideMenu() {
//        presentViewController(SideMenuManager.menuLeftNavigationController!, animated: true, completion: nil)
        presentViewController(sideMenuController!, animated: true, completion: nil)
    }
    
    func actionToPath(path: String, withAction action: Action) {
        presentVisitableForSession(session, path: path, withAction: action)
    }
    
    func initSideMenu() {
        sideMenuController = mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuController") as?SideMenuNavigationController
        sideMenuTableViewController = mainStoryboard.instantiateViewControllerWithIdentifier("sideMenuTableViewController") as? SideMenuViewController
        SideMenuManager.menuLeftNavigationController = sideMenuController
        SideMenuManager.menuFadeStatusBar = false
        SideMenuManager.menuAnimationBackgroundColor = UIColor.grayColor()
        SideMenuManager.menuAddPanGestureToPresent(toView: navigationBar)
        SideMenuManager.menuAddScreenEdgePanGesturesToPresent(toView: view)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(ApplicationController.menuClicked(_:)), name: "menuClicked", object: nil)
    }
    
    func menuClicked(notification: NSNotification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let path = userInfo["path"] as! String
        actionToPath(path, withAction: .Restore)
        
        sideMenuController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    private func presentLoginController() {
        let controller = LoginViewController()
        controller.delegate = self
        controller.webViewConfiguration = webViewConfiguration
        controller.URL = NSURL(string: "\(ROOT_URL)/account/sign_in")
        controller.title = "登录"
        
        let authNavigationController = UINavigationController(rootViewController: controller)
        presentViewController(authNavigationController, animated: true, completion: nil)
    }
}

extension ApplicationController: SessionDelegate {
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        let path = URL.path
        if path == "/account/sign_in" {
            presentLoginController()
        } else {
            presentVisitableForSession(session, path: URL.path!, withAction: action)
        }
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
    
    func session(session: Session, openExternalURL URL: NSURL) {
        let safariViewController = SFSafariViewController(URL: URL)
        presentViewController(safariViewController, animated: true, completion: nil)
    }
}

extension ApplicationController: LoginViewControllerDelegate {
    func loginViewControllerDidAuthenticate(controller: LoginViewController) {
        session.reload()
        dismissViewControllerAnimated(true, completion: nil)
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

