import UIKit
import WebKit

protocol EditReplyViewControllerDelegate: class {
    func editReplyViewDidFinished(controller: EditReplyViewController, toURL url: NSURL)
}

class EditReplyViewController: PopupWebViewController {
    var doneButton: UIBarButtonItem?
    var closeButton: UIBarButtonItem?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        doneButton = UIBarButtonItem.init(title: "保存", style: .Plain, target: self, action: #selector(actionDone))
        closeButton = UIBarButtonItem.init(barButtonSystemItem: .Cancel, target: self, action: #selector(actionClose))
        
        navigationController?.navigationBar.tintColor = UIColor.blackColor()
        navigationItem.leftBarButtonItem = closeButton
        navigationItem.rightBarButtonItem = doneButton
    }
    
    func actionDone() {
        webView.evaluateJavaScript("$('form[tb=\"edit-reply\"] .btn-primary').click()", completionHandler: nil)
    }
}


