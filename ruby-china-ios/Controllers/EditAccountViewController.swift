import UIKit
import WebKit


class EditAccountViewController: UIViewController {
    var webViewConfiguration: WKWebViewConfiguration?
    var doneButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    
    lazy var webView: WKWebView = {
        let configuration = self.webViewConfiguration ?? WKWebViewConfiguration()
        let webView = WKWebView(frame: CGRectZero, configuration: configuration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "个人设置"
        
        closeButton = UIBarButtonItem.init(title: "关闭", style: .Plain, target: self, action: #selector(actionClose))
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionSubmit))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        
        view.addSubview(webView)
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options: [], metrics: nil, views: [ "view": webView ]))
        
        webView.loadRequest(NSURLRequest(URL: NSURL(string: "\(ROOT_URL)/account/edit?access_token=\(OAuth2.shared.accessToken)")!))
    }
    
    func actionSubmit() {
        webView.evaluateJavaScript("$('form.edit_user').first().submit()", completionHandler: nil)

    }
    
    func actionClose() {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

extension EditAccountViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, decidePolicyForNavigationAction navigationAction: WKNavigationAction, decisionHandler: (WKNavigationActionPolicy) -> Void) {
        if (navigationAction.request.HTTPMethod == "GET") {
            if let URL = navigationAction.request.URL where URL.path == "/account/edit"  {
                dismissViewControllerAnimated(true, completion: nil)
                decisionHandler(.Cancel)
                return
            }
        }
        
        decisionHandler(.Allow)
    }
}
