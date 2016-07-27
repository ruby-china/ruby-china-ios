import UIKit
import Turbolinks

class WebViewController: VisitableViewController {
    var navController = ApplicationController()
    
    var cleanNotificationButton = UIBarButtonItem()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        initButtons()
        
        visitableView.allowsPullToRefresh = true
        
        navController = self.navigationController as! ApplicationController
        
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        
        if (navController.viewControllers.count == 1) {
            navigationItem.leftBarButtonItem = navController.menuButton
        }
        
        if (navController.rootPath == "/topics") {
            if (navigationController?.viewControllers.count == 1) {
                navigationItem.titleView = navController.filterSegment
                navigationItem.rightBarButtonItem = navController.newButton
            }            
        }
        
        if (navController.rootPath == "/notifications") {
            navigationItem.rightBarButtonItem = cleanNotificationButton
        }
    }
    
    func initButtons() {
        cleanNotificationButton = UIBarButtonItem.init(image: UIImage.init(named: "trash"), style: .Plain, target: self, action: nil)
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

