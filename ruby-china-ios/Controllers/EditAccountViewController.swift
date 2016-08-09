import UIKit
import WebKit


class EditAccountViewController: PopupWebViewController {
    var doneButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    
    override func viewDidLoad() {
        path = "/account/edit"
        title = "个人设置"
        
        closeButton = UIBarButtonItem.init(title: "关闭", style: .Plain, target: self, action: #selector(actionClose))
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionSubmit))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
        
        super.viewDidLoad()
    }
    
    func actionSubmit() {
        webView.evaluateJavaScript("$('form.edit_user').first().submit()", completionHandler: nil)
    }
}