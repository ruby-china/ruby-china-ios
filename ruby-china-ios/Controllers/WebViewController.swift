import UIKit
import Turbolinks

class WebViewController: VisitableViewController {
    convenience init(path: String) {
        var urlString = "\(ROOT_URL)\(path)"
        if (OAuth2.shared.isLogined) {
            urlString += "?access_token=\(OAuth2.shared.accessToken)"
        }
        self.init(URL: NSURL(string: urlString)!)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        TurbolinksSessionLib.sharedInstance.visit(self)
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
}
