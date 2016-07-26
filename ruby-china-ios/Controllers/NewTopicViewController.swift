import UIKit
import WebKit

protocol NewTopicViewControllerDelegate: class {
    func newTopicViewDidFinished(controller: NewTopicViewController, toURL url: NSURL)
}

class NewTopicViewController: UIViewController {
    var URL = NSURL(string: "\(ROOT_URL)/topics/new?access_token=\(OAuth2.shared.accessToken!)")
    var webViewConfiguration: WKWebViewConfiguration?
    var doneButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    weak var delegate: NewTopicViewControllerDelegate?
    
    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        webView.navigationDelegate = self
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "创建新话题"
        
        
        doneButton = UIBarButtonItem.init(title: "发布", style: .Plain, target: self, action: #selector(actionDone))
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        if let URL = self.URL {
            webView.loadRequest(NSURLRequest(URL: URL))
        }
    }
    
    func actionDone() {
        webView.evaluateJavaScript("$('form#new_topic').submit()", completionHandler: nil)
    }
    
    func actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension NewTopicViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL != self.URL {
                dismissViewControllerAnimated(true, completion: nil)
                delegate?.newTopicViewDidFinished(self, toURL: URL)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}
