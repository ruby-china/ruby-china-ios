import UIKit
import WebKit

class EditAccountViewController: PopupWebViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "save".localized, style: .plain, target: self, action: #selector(actionSubmit))
    }
    
    @objc func actionSubmit() {
        visitableView.webView?.evaluateJavaScript("$('form.edit_user').first().submit()", completionHandler: nil)
    }
}
