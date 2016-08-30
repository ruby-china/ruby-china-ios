import UIKit
import WebKit

class EditReplyViewController: PopupWebViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .Plain, target: self, action: #selector(actionDone))
    }
    
    func actionDone() {
        visitableView.webView?.evaluateJavaScript("$('form[tb=\"edit-reply\"] .btn-primary').click()", completionHandler: nil)
    }
}

