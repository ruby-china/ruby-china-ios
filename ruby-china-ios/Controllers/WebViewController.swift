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
            self.pageTitle = "话题列表"
        }
        router.bind("/topics/node:id") { (req) in
            self.pageTitle = "节点"
        }
        router.bind("/topics/last") { (req) in
            self.pageTitle = "最新话题"
        }
        router.bind("/topics/popular") { (req) in
            self.pageTitle = "话题精选"
        }
        router.bind("/jobs") { (req) in
            self.pageTitle = "招聘"
        }
        router.bind("/account/edit") { (req) in
            self.pageTitle = "个人设置"
        }
        router.bind("/notifications") { (req) in
            self.pageTitle = "通知中心"
        }
        router.bind("/notes") { (req) in
            self.pageTitle = "记事本"
        }
        router.bind("/notes/:id") { (req) in
            self.pageTitle = "记事本"
        }
        router.bind("/topics/favorites") { (req) in
            self.pageTitle = "我的收藏"
        }
        router.bind("/topics/new") { (req) in
            self.pageTitle = "创建新话题"
        }
        router.bind("/topics/:id") { (req) in
            self.pageTitle = "阅读话题"
            self.addPopupMenuButton()
        }
        router.bind("/topics/:id/edit") { (req) in
            self.pageTitle = "编辑话题"
        }
        router.bind("/topics/:topic_id/replies/:id/edit") { (req) in
            self.pageTitle = "修改回帖"
        }
        
        router.bind("/wiki") { (req) in
            self.pageTitle = "Wiki"
        }
        
        router.bind("/wiki/:id") { (req) in
            self.pageTitle = "阅读 Wiki"
            self.addPopupMenuButton()
        }
    }
    
    private func addPopupMenuButton() {
        let menuButton = UIBarButtonItem(image: UIImage(named: "dropdown"), style: .Plain, target: self, action: #selector(self.showTopicContextMenu))
        self.navigationItem.rightBarButtonItem = menuButton
    }
    
    private func addObserver() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadByLoginStatusChanged), name: NOTICE_SIGNIN_SUCCESS, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(reloadByLoginStatusChanged), name: NOTICE_SIGNOUT, object: nil)
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
        router.match(NSURL.init(string: self.currentPath)!)
        navigationController?.topViewController?.title = pageTitle
    }
    
    override func visitableDidRender() {
        router.match(NSURL.init(string: (self.visitableView?.webView?.URL?.path)!)!)
        // 覆盖 visitableDidRender，避免设置 title
        navigationController?.topViewController?.title = pageTitle
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
