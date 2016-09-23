import UIKit
import Turbolinks
import Router

class WebViewController: VisitableViewController {
    private(set) var currentPath = ""
    private lazy var router = Router()
    private var pageTitle = ""
    
    convenience init(path: String) {
        self.init()
        self.visitableURL = urlWithPath(path)
        self.currentPath = path
        self.initRouter()
        self.addObserver()
    }
    
    private func urlWithPath(path: String) -> NSURL {
        var urlString = ROOT_URL + path
        if let accessToken = OAuth2.shared.accessToken {
            urlString += "?access_token=" + accessToken
        }
        
        return NSURL(string: urlString)!
    }
    
    private func initRouter() {
        self.navigationItem.rightBarButtonItem = nil
        router.bind("/topics") { (req) in
            self.pageTitle = "title topics".localized
        }
        router.bind("/topics/node:id") { (req) in
            self.pageTitle = "title node".localized
        }
        router.bind("/topics/last") { (req) in
            self.pageTitle = "title last topics".localized
        }
        router.bind("/topics/popular") { (req) in
            self.pageTitle = "title popular topics".localized
        }
        router.bind("/jobs") { (req) in
            self.pageTitle = "title jobs".localized
        }
        router.bind("/account/edit") { (req) in
            self.pageTitle = "title edit account".localized
        }
        router.bind("/notifications") { (req) in
            self.pageTitle = "title notifications".localized
        }
        router.bind("/notes") { (req) in
            self.pageTitle = "title notes".localized
        }
        router.bind("/notes/:id") { (req) in
            self.pageTitle = "title note details".localized
        }
        router.bind("/topics/favorites") { (req) in
            self.pageTitle = "title favorites".localized
        }
        router.bind("/topics/new") { (req) in
            self.pageTitle = "title new topic".localized
        }
        router.bind("/topics/:id") { (req) in
            self.pageTitle = "title topic details".localized
            self.addPopupMenuButton()
        }
        router.bind("/topics/:id/edit") { (req) in
            self.pageTitle = "title edit topic".localized
        }
        router.bind("/topics/:topic_id/replies/:id/edit") { (req) in
            self.pageTitle = "title edit reply".localized
        }
        
        router.bind("/wiki") { (req) in
            self.pageTitle = "title wiki".localized
        }
        
        router.bind("/wiki/:id") { (req) in
            self.pageTitle = "title wiki details".localized
            self.addPopupMenuButton()
        }
    }
    
    private func addPopupMenuButton() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "dropdown"), style: .Plain, target: self, action: #selector(self.showTopicContextMenu))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadByLoginStatusChanged), name: NOTICE_SIGNIN_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserverForName(NOTICE_SIGNOUT, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            let js = "document.cookie = '_homeland_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';";
            self.visitableView.webView?.evaluateJavaScript(js, completionHandler: nil)
            self.reloadByLoginStatusChanged()
        }
    }
    
    func reloadByLoginStatusChanged() {
        visitableURL = urlWithPath(currentPath)
        if isViewLoaded() {
            reloadVisitable()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TurbolinksSessionLib.sharedInstance.visit(self)
        router.match(NSURL(string: self.currentPath)!)
        navigationController?.topViewController?.title = pageTitle
    }
    
    override func visitableDidRender() {
        if let urlPath = self.visitableView?.webView?.URL?.path, url = NSURL(string: urlPath) {
            router.match(url)
        }
        // 覆盖 visitableDidRender，避免设置 title
        navigationController?.topViewController?.title = pageTitle
    }
    
    func showTopicContextMenu() {
        guard let webView = self.visitableView.webView, title = webView.title, url = webView.URL else {
            return
        }
        
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "share".localized, style: .Default, handler: { action in
            let components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false)
            components?.query = nil
            components?.fragment = nil
            print(components?.URL)
            self.share(title, url: (components?.URL)!)
        })
        sheet.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .Cancel, handler: nil)
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
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
    }
    
    func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
    
    private func share(textToShare: String, url: NSURL) {
        let objectsToShare = [textToShare, url]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
