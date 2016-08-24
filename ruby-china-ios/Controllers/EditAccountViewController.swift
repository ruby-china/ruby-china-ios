import UIKit
import WebKit


class EditAccountViewController: PopupWebViewController {
    var doneButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "个人设置"
        
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionSubmit))
        navigationItem.rightBarButtonItem = doneButton
        
    }
    
    func actionSubmit() {
        visitableView.webView?.evaluateJavaScript("$('form.edit_user').first().submit()", completionHandler: nil)
    }
}