import UIKit
import WebKit

class NewTopicViewController: PopupWebViewController {
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "提交", style: .Plain, target: self, action: #selector(actionDone))
    }
    
    func actionDone() {
        visitableView.webView?.evaluateJavaScript("$('form[tb=\"edit-topic\"]').submit()", completionHandler: nil)
    }
}
