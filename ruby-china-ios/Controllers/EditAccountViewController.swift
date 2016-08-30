import UIKit
import WebKit

class EditAccountViewController: PopupWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "保存", style: .Plain, target: self, action: #selector(actionSubmit))
    }
    
    func actionSubmit() {
        visitableView.webView?.evaluateJavaScript("$('form.edit_user').first().submit()", completionHandler: nil)
    }
}
