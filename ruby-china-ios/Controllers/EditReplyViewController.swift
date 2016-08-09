import UIKit
import WebKit

class EditReplyViewController: PopupWebViewController {
    var doneButton: UIBarButtonItem?    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionDone))
        
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func actionDone() {
        webView.evaluateJavaScript("$('form[tb=\"edit-reply\"] .btn-primary').click()", completionHandler: nil)
    }
}


