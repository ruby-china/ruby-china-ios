import UIKit
import Turbolinks
import Router

class WebViewController: VisitableViewController {
    var currentPath = "" {
        didSet {
            visitableURL = urlWithPath(currentPath)
        }
    }
    private lazy var router: Router = {
        let router = Router()
        router.bind("/topics") { [weak self] (req) in
            self?.pageTitle = "title topics".localized
        }
        router.bind("/topics/last") { [weak self] (req) in
            self?.pageTitle = "title last topics".localized
        }
        router.bind("/topics/popular") { [weak self] (req) in
            self?.pageTitle = "title popular topics".localized
        }
        router.bind("/jobs") { [weak self] (req) in
            self?.pageTitle = "title jobs".localized
        }
        router.bind("/account/edit") { [weak self] (req) in
            self?.pageTitle = "title edit account".localized
        }
        router.bind("/notifications") { [weak self] (req) in
            self?.pageTitle = "title notifications".localized
        }
        router.bind("/notes") { [weak self] (req) in
            self?.pageTitle = "title notes".localized
        }
        router.bind("/notes/:id") { [weak self] (req) in
            self?.pageTitle = "title note details".localized
        }
        router.bind("/topics/favorites") { [weak self] (req) in
            self?.pageTitle = "title favorites".localized
        }
        router.bind("/topics/new") { [weak self] (req) in
            self?.pageTitle = "title new topic".localized
        }
        router.bind("/topics/:id/edit") { [weak self] (req) in
            self?.pageTitle = "title edit topic".localized
        }
        router.bind("/topics/:topic_id/replies/:id/edit") { [weak self] (req) in
            self?.pageTitle = "title edit reply".localized
        }
        
        router.bind("/wiki") { [weak self] (req) in
            self?.pageTitle = "title wiki".localized
        }
        router.bind("/wiki/:id") { [weak self] (req) in
            self?.pageTitle = "title wiki details".localized
            self?.addMoreButton()
        }
        
        router.bind("/search") { [weak self] (req) in
            self?.pageTitle = "title search".localized
        }
        return router
    }()
    
    private var pageTitle = ""
    
    private lazy var errorView: ErrorView = {
        let view = NSBundle.mainBundle().loadNibNamed("ErrorView", owner: self, options: nil)!.first as! ErrorView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), forControlEvents: .TouchUpInside)
        return view
    }()
    
    convenience init(path: String) {
        self.init()
        currentPath = path
        visitableURL = urlWithPath(path)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TurbolinksSessionLib.sharedInstance.visit(self)
        
        router.match(NSURL(string: currentPath)!)
        navigationItem.title = pageTitle
        
        addObserver()
    }
    
    override func visitableDidRender() {
        // 覆盖 visitableDidRender，避免设置 title
        navigationItem.title = pageTitle
    }
    
}

// MARK: - public

extension WebViewController {
    
    func addMoreButton() {
        var rightBarButtonItems = self.navigationItem.rightBarButtonItems ?? [UIBarButtonItem.fixNavigationSpacer()]
        let menuButton = UIBarButtonItem.narrowButtonItem(image: UIImage(named: "dropdown"), target: self, action: #selector(self.showTopicContextMenu))
        rightBarButtonItems.append(menuButton)
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    func presentError(error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
    }
    
}

// MARK: - action

extension WebViewController {
    
    func reloadByLoginStatusChanged() {
        visitableURL = urlWithPath(currentPath)
        if isViewLoaded() {
            reloadVisitable()
        }
    }
    
    func retry(sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
    
    func showTopicContextMenu() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "share".localized, style: .Default, handler: { [weak self] action in
            guard let `self` = self,
                webView = self.visitableView.webView,
                title = webView.title,
                url = webView.URL,
                components = NSURLComponents(URL: url, resolvingAgainstBaseURL: false) else {
                    return
            }
            components.query = nil
            components.fragment = nil
            self.share(title, url: components.URL!)
        })
        sheet.addAction(shareAction)
        let moveToFooterAction = UIAlertAction(title: "move to footer".localized, style: .Default, handler: { [weak self] action in
            guard let `self` = self, scrollView = self.visitableView.webView?.scrollView else {
                return
            }
            let offset = CGPoint(x: 0, y: scrollView.contentSize.height - scrollView.frame.height)
            if offset.y < 0 {
                return
            }
            scrollView.setContentOffset(offset, animated: true)
        })
        sheet.addAction(moveToFooterAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .Cancel, handler: nil)
        sheet.addAction(cancelAction)
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
}

// MARK: - private

extension WebViewController {
    
    private func urlWithPath(path: String) -> NSURL {
        var urlString = ROOT_URL + path
        if let accessToken = OAuth2.shared.accessToken {
            let char = urlString.rangeOfString("?") == nil ? "?" : "&"
            urlString += "\(char)access_token=\(accessToken)"
        }
        
        return NSURL(string: urlString)!
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
    
    private func share(textToShare: String, url: NSURL) {
        let objectsToShare = [textToShare, url]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.presentViewController(activityViewController, animated: true, completion: nil)
    }
}
