import UIKit
import WebKit
import Turbolinks
import SafariServices

class ApplicationController: UINavigationController {
    private let URL = NSURL(string: "http://192.168.0.75:3000/topics")!
    private let URL_NOTIFICATIONS = NSURL(string: "http://192.168.0.75:3000/notifications")!
    private let webViewProcessPool = WKProcessPool()
    var menuButton = UIBarButtonItem()
    var notificationsButton = UIBarButtonItem()
    
    private var application: UIApplication {
        return UIApplication.sharedApplication()
    }
    
    private lazy var webViewConfiguration: WKWebViewConfiguration = {
        let configuration = WKWebViewConfiguration()
//        configuration.userContentController.addScriptMessageHandler(self, name: "ruby-china")
        configuration.processPool = self.webViewProcessPool
        configuration.applicationNameForUserAgent = "ruby-china-turbolinks"
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
        
        menuButton = UIBarButtonItem.init(image: UIImage.init(named: "menu"), style: .Plain, target: self, action: #selector(ApplicationController.actionNotifications))
        
        notificationsButton = UIBarButtonItem.init(image: UIImage.init(named: "box"), style: .Plain, target: self, action: #selector(ApplicationController.actionNotifications))
        
        presentVisitableForSession(session, URL: URL)
    }
    
    private func presentVisitableForSession(session: Session, URL: NSURL, action: Action = .Advance) {
        let visitable = WebViewController(URL: URL)
        
        if action == .Advance {
            pushViewController(visitable, animated: true)
        } else if action == .Replace {
            popViewControllerAnimated(false)
            pushViewController(visitable, animated: false)
        }
        
        session.visit(visitable)
    }

    func actionNotifications() {
        presentVisitableForSession(session, URL: URL_NOTIFICATIONS)
    }
}

extension ApplicationController: SessionDelegate {
    func session(session: Session, didProposeVisitToURL URL: NSURL, withAction action: Action) {
        if URL.path == "/numbers" {
//            presentNumbersViewController()
        } else {
            presentVisitableForSession(session, URL: URL, action: action)
        }
    }
    
    func session(session: Session, didFailRequestForVisitable visitable: Visitable, withError error: NSError) {
        NSLog("ERROR: %@", error)
//        guard let viewController = visitable as? VisitableViewController, errorCode = ErrorCode(rawValue: error.code) else { return }
//
//        switch errorCode {
//        case .HTTPFailure:
//            let statusCode = error.userInfo["statusCode"] as! Int
//            switch statusCode {
////            case 401:
////                presentAuthenticationController()
//            case 404:
//                viewController.presentError(.HTTPNotFoundError)
//            default:
//                viewController.presentError(Error(HTTPStatusCode: statusCode))
//            }
//        case .NetworkFailure:
//            viewController.presentError(.NetworkError)
//        }
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

//extension ApplicationController: AuthenticationControllerDelegate {
//    func authenticationControllerDidAuthenticate(authenticationController: AuthenticationController) {
//        session.reload()
//        dismissViewControllerAnimated(true, completion: nil)
//    }
//}

extension ApplicationController: WKScriptMessageHandler {
    func userContentController(userContentController: WKUserContentController, didReceiveScriptMessage message: WKScriptMessage) {
        if let message = message.body as? String {
            let alertController = UIAlertController(title: "Ruby China", message: message, preferredStyle: .Alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            presentViewController(alertController, animated: true, completion: nil)
        }
    }
}