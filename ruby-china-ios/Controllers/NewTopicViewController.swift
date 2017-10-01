import UIKit
import WebKit

class NewTopicViewController: PopupWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "submit".localized, style: .plain, target: self, action: #selector(actionDone))
    }
    
    @objc func actionDone() {
        visitableView.webView?.evaluateJavaScript("$('form[tb=\"edit-topic\"]').submit()", completionHandler: nil)
    }
}
