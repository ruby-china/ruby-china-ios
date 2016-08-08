import UIKit
import Turbolinks
import Router

class WebViewController: VisitableViewController {
    var currentPath = ""
    lazy var router = Router()

    convenience init(path: String) {
        var urlString = "\(ROOT_URL)\(path)"
        if (OAuth2.shared.isLogined) {
            urlString += "?access_token=\(OAuth2.shared.accessToken)"
        }

        let url = NSURL(string: urlString)!

        self.init(URL: url)

        self.initRouter()
        self.currentPath = path
    }

    func initRouter() {
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

    override func viewDidLoad() {
        super.viewDidLoad()

        TurbolinksSessionLib.sharedInstance.visit(self)
        router.match(NSURL.init(string: self.currentPath)!)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        visitableDelegate?.visitableViewWillAppear(self)
    }

    override func visitableDidRender() {
        if navigationController?.viewControllers.count > 1 {
            navigationItem.title = visitableView.webView?.title
        } else {
            navigationItem.title = ""
        }
    }


    func showTopicContextMenu() {
        let sheet = UIAlertController(title: "操作", message: "", preferredStyle: .ActionSheet)
        let shareAction = UIAlertAction(title: "分享", style: .Default, handler: { action in
            self.share((self.visitableView.webView?.title)!, url: (self.visitableView.webView?.URL?.absoluteString)!, image: UIImage.init(), sourceView: self.visitableView)
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
            self.extendedLayoutIncludesOpaqueBars = true
        } else {
            self.hidesBottomBarWhenPushed = false
            self.extendedLayoutIncludesOpaqueBars = false
        }
    }

    private func share(textToShare: String, url: String, image: UIImage, sourceView: UIView) {
        let objectsToShare = [textToShare, url, image]
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)


        self.presentViewController(activityViewController, animated: true, completion: nil)

    }
}
