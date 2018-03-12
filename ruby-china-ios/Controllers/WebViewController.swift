import UIKit
import Turbolinks
import Router

class WebViewController: VisitableViewController {
    var currentPath = "" {
        didSet {
            visitableURL = urlWithPath(currentPath)
        }
    }
    
    fileprivate lazy var router: Router = {
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
        }
        
        router.bind("/search") { [weak self] (req) in
            self?.pageTitle = "title search".localized
        }
        return router
    }()
    
    fileprivate var pageTitle = ""
    
    fileprivate lazy var errorView: ErrorView = {
        let view = Bundle.main.loadNibNamed("ErrorView", owner: self, options: nil)!.first as! ErrorView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.retryButton.addTarget(self, action: #selector(retry(_:)), for: .touchUpInside)
        return view
    }()
    
    convenience init(path: String) {
        self.init()
        currentPath = path
        visitableURL = urlWithPath(path)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        TurbolinksSessionLib.shared.visit(self)
        
        _ = router.match(URL(string: currentPath)!)
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
    
    func presentError(_ error: Error) {
        errorView.error = error
        view.addSubview(errorView)
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
        view.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|[view]|", options: [], metrics: nil, views: ["view": errorView]))
    }
    
    func clearSession() {
        let js = "document.cookie = '_homeland_session=; Path=/; Expires=Thu, 01 Jan 1970 00:00:01 GMT;';";
        visitableView.webView?.evaluateJavaScript(js, completionHandler: nil)
    }
    
}

// MARK: - action
@objc
extension WebViewController {
    
    func reloadByLoginStatusChanged() {
        visitableURL = urlWithPath(currentPath)
        if isViewLoaded {
            reloadVisitable()
        }
    }
    
    func retry(_ sender: AnyObject) {
        errorView.removeFromSuperview()
        reloadVisitable()
    }
    
    func shareAction() {
        guard let webView = self.visitableView.webView,
            let title = webView.title,
            let url = webView.url,
            var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
            return
        }
        components.query = nil
        components.fragment = nil
        if let url = components.url {
            share(title, url: url)
        }
    }
    
    func backAction() {
        navigationController?.popViewController(animated: true)
    }
    
    func moreAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let shareAction = UIAlertAction(title: "share".localized, style: .default, handler: { [weak self] action in
            self?.shareAction()
        })
        sheet.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
}

// MARK: - private

extension WebViewController {
    
    fileprivate func urlWithPath(_ path: String) -> URL {
        let newPath = path.replacingOccurrences(of: "%23", with: "#")
        var urlComponents = URLComponents(string: newPath)!
        
        let rootURLComponents = URLComponents(string: ROOT_URL)!
        urlComponents.scheme = rootURLComponents.scheme
        urlComponents.host = rootURLComponents.host
        urlComponents.port = rootURLComponents.port
        
        if let accessToken = OAuth2.shared.accessToken {
            var queryItems = urlComponents.queryItems ?? [URLQueryItem]()
            if var item = queryItems.filter({ $0.name == "access_token" }).first {
                item.value = accessToken
            } else {
                queryItems.append(URLQueryItem(name: "access_token", value: accessToken))
            }
            urlComponents.queryItems = queryItems
        }
        
        return urlComponents.url!
    }
    
    fileprivate func addObserver() {
        NotificationCenter.default.addObserver(self, selector: #selector(reloadByLoginStatusChanged), name: NSNotification.Name.userSignin, object: nil)
        NotificationCenter.default.addObserver(forName: NSNotification.Name.userSignout, object: nil, queue: nil) { [weak self] (notification) in
            guard let `self` = self else {
                return
            }
            self.clearSession()
            self.reloadByLoginStatusChanged()
        }
    }
    
    fileprivate func share(_ textToShare: String, url: URL) {
        let objectsToShare = [textToShare, url] as [Any]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
    }
}
