import UIKit
import Turbolinks
import Router

class WebViewController: VisitableViewController {
    private var currentPath = ""
    private lazy var router = Router()
    
    convenience init(path: String) {
        self.init()
        self.visitableURL = urlWithPath(path)
        self.currentPath = path
        self.initRouter()
        self.addObserver()
    }

    private func urlWithPath(path: String) -> NSURL {
        var urlString = "\(ROOT_URL)\(path)"
        if (OAuth2.shared.isLogined) {
            urlString += "?access_token=\(OAuth2.shared.accessToken)"
        }
        
        return NSURL(string: urlString)!
    }
    
    private func initRouter() {
        self.navigationItem.rightBarButtonItem = nil
        router.bind("/topics/last") { (req) in

        }
        router.bind("/topics/favorites") { (req) in

        }
        router.bind("/topics/:id") { (req) in
            let menuButton = UIBarButtonItem(image:  UIImage(named: "dropdown"), style: .Plain, target: self, action: #selector(self.showTopicContextMenu))
            self.navigationItem.rightBarButtonItem = menuButton
        }
    }
    
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserverForName(NOTICE_SIGNIN_SUCCESS, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            self.visitableURL = self.urlWithPath(self.currentPath)
            if self.isViewLoaded() {
                self.reloadVisitable()
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        TurbolinksSessionLib.sharedInstance.visit(self)
        router.match(NSURL.init(string: self.currentPath)!)
    }

    override func visitableDidRender() {
        // 不要显示 title
        navigationController?.title = ""
    }

    func showTopicContextMenu() {
        guard let webView = self.visitableView.webView, title = webView.title, url = webView.URL else {
            return
        }
        
        let sheet = UIAlertController(title: "操作", message: "", preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "分享", style: .Default, handler: { action in
            self.share(title, url: url)
        })
        sheet.addAction(shareAction)

        let cancelAction = UIAlertAction(title: "取消", style: .Cancel, handler: nil)
        sheet.addAction(cancelAction)
        self.presentViewController(sheet, animated: true, completion: nil)
    }

    lazy var errorView: ErrorView = {
        let view = NSBundle.mainBundle().loadNibNamed("ErrorView", owner: self, options: nil).first as! ErrorView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), forControlEvents: .TouchUpInside)
        return view
    }()

    func presentError(error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        installErrorViewConstraints()
    }

    func installErrorViewConstraints() {
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": errorView ]))
    }

    func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }


    func hideTabBar(tabBarHidden hidden: Bool) {
        if hidden {
            self.hidesBottomBarWhenPushed = true
        } else {
            self.hidesBottomBarWhenPushed = false
        }
    }

    private func share(textToShare: String, url: NSURL) {
        let objectsToShare = [textToShare, url]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
