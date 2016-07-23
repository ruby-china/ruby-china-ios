import UIKit
import Turbolinks
import SafariServices
import WebKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    var navigationController = ApplicationController()
    var session = Session()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        window?.rootViewController = navigationController
        return true
    }
}
