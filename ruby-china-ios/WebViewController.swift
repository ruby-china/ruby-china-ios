import UIKit
import Turbolinks

class WebViewController: VisitableViewController {
    var navController = ApplicationController()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navController = self.navigationController as! ApplicationController
        
        if (navController.viewControllers.count == 1) {
            navigationItem.leftBarButtonItem = navController.menuButton
        }
        navigationItem.rightBarButtonItem = navController.notificationsButton
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func visitableDidRender() {
        title = ""
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
}

