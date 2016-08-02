import UIKit
import Turbolinks
import WebKit

class WebViewController: VisitableViewController {
    var navController = ApplicationController()
    
    var cleanNotificationButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButtons()
        
        visitableView.allowsPullToRefresh = true
        visitableView.webView?.UIDelegate = self
        visitableView.webView?.navigationDelegate = self
        
        navController = self.navigationController as! ApplicationController
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if (navController.viewControllers.count == 1) {
            navigationItem.leftBarButtonItem = navController.menuButton
        }
        
        if (navController.rootPath == "/topics") {
            if (navigationController?.viewControllers.count == 1) {
                navigationItem.titleView = navController.filterSegment
                navigationItem.rightBarButtonItem = navController.newButton
            }            
        }
        
        if (navController.rootPath == "/notifications") {
            UIApplication.sharedApplication().applicationIconBadgeNumber = 0
            navigationItem.rightBarButtonItem = cleanNotificationButton
        }
    }
    
    func initButtons() {
        cleanNotificationButton = UIBarButtonItem.init(image: UIImage.init(named: "trash"), style: .Plain, target: self, action: #selector(actionCleanNotifications))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func visitableDidRender() {
        navigationItem.title = ""
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
    
    func actionCleanNotifications() {
        visitableView.webView?.evaluateJavaScript("$('#btn-remove-all').click();", completionHandler: { (obj, err) in
            self.visitableView.webView?.reload()
            OAuth2.shared.refreshUnreadNotifications({ (count) in
            });
        })
    }
    
    
    
}

extension WebViewController: WKNavigationDelegate {
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        if (navController.rootPath == "/notifications") {
            OAuth2.shared.refreshUnreadNotifications({ (count) in
            });
        }
    }
}

extension WebViewController: WKUIDelegate {
    // MARK: - WKUIDelegate
    // 这个方法是在HTML中调用了JS的alert()方法时，就会回调此API。
    // 注意，使用了`WKWebView`后，在JS端调用alert()就不会在HTML
    // 中显示弹出窗口。因此，我们需要在此处手动弹出ios系统的alert。
    func webView(webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: () -> Void) {
        let alert = UIAlertController(title: "提示", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // We must call back js
            completionHandler()
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: (Bool) -> Void) {
        let alert = UIAlertController(title: "Ruby China", message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // 点击完成后，可以做相应处理，最后再回调js端
            completionHandler(true)
        }))
        alert.addAction(UIAlertAction(title: "取消", style: .Cancel, handler: { (_) -> Void in
            // 点击取消后，可以做相应处理，最后再回调js端
            completionHandler(false)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    func webView(webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: (String?) -> Void) {
        let alert = UIAlertController(title: prompt, message: defaultText, preferredStyle: .Alert)
        
        alert.addTextFieldWithConfigurationHandler { (textField: UITextField) -> Void in
            textField.textColor = UIColor.redColor()
        }
        alert.addAction(UIAlertAction(title: "确定", style: .Default, handler: { (_) -> Void in
            // 处理好之前，将值传到js端
            completionHandler(alert.textFields![0].text!)
        }))
        
        self.presentViewController(alert, animated: true, completion: nil)
    }
}

