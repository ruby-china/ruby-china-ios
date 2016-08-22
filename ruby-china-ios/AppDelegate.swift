import UIKit
import Turbolinks
import SafariServices
import WebKit
import SideMenu


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    
    private lazy var rootViewController: RootViewController = {
        return RootViewController()
    }()
    
    private func initAppearance() {
        UINavigationBar.appearance().theme = true
        UISegmentedControl.appearance().theme = true
        UITabBar.appearance().theme = true
    }
    
    private var becomeActivePage = String()
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        initAppearance()
        let navigationController = UINavigationController(rootViewController: rootViewController)
        navigationController.view.backgroundColor = UIColor.whiteColor()
        window?.rootViewController = navigationController
        
        let notificationSettings = UIUserNotificationSettings(forTypes: [.Badge, .Sound, .Alert], categories: nil)
        application.registerUserNotificationSettings(notificationSettings)
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - 通知相关
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        let characterSet: NSCharacterSet = NSCharacterSet(charactersInString: "<>")
        
        let deviceTokenString: String = (deviceToken.description as NSString)
            .stringByTrimmingCharactersInSet(characterSet)
            .stringByReplacingOccurrencesOfString( " ", withString: "") as String
        
        print("DeviceToken \(deviceTokenString)")
        
        NSUserDefaults.standardUserDefaults().setValue(deviceTokenString, forKey: "deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
        
        if OAuth2.shared.isLogined {
            DeviseService.create(deviceTokenString)
        }
    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        print("didFailToRegisterForRemoteNotificationsWithError", error)
        
        NSUserDefaults.standardUserDefaults().removeObjectForKey("deviceToken")
        NSUserDefaults.standardUserDefaults().synchronize()
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        becomeActivePage = "notifications"
        
        refreshUnreadNotificationCount()
    }
    
    func applicationDidBecomeActive(application: UIApplication) {
        if (becomeActivePage == "notifications") {
            becomeActivePage = ""
            application.applicationIconBadgeNumber = 0
            rootViewController.selectedIndex = (rootViewController.viewControllers?.count)!
        } else {
            refreshUnreadNotificationCount()
        }
    }
    
    func refreshUnreadNotificationCount() {
        if OAuth2.shared.isLogined {
            OAuth2.shared.refreshUnreadNotifications({ [weak self] (count) in
                self?.setBadge(count)
            })
        } else {
            setBadge(0)
        }
    }
    
    private func setBadge(count: Int) {
        UIApplication.sharedApplication().applicationIconBadgeNumber = count > 0 ? count : 0
        self.rootViewController.tabBar.items?.last?.badgeValue = count > 0 ? "\(count)" : nil
    }
}

let NAVBAR_BG_COLOR = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1.0)
let NAVBAR_BORDER_COLOR = UIColor(red:0.25, green:0.32, blue:0.61, alpha:1.0)
let NAVBAR_TINT_COLOR = UIColor(red:1.00, green:1.00, blue:0.93, alpha:1.0)
let SEGMENT_BG_COLOR = UIColor(red:0.10, green:0.14, blue:0.39, alpha:1.0)
let TABBAR_BG_COLOR = UIColor(red:0.88, green:0.96, blue:1.00, alpha:1.0)

extension UINavigationBar {
    var theme : Bool {
        get { return false }
        set {
            self.barStyle = .Black
            self.translucent = false
            self.tintColor = NAVBAR_TINT_COLOR
            // #F44336
            self.barTintColor = NAVBAR_BG_COLOR

            // Border bottom line
            let navBorder = UIView(frame: CGRectMake(0,self.frame.size.height-1, self.frame.size.width, 1))
            navBorder.backgroundColor = NAVBAR_BORDER_COLOR
            self.addSubview(navBorder)
            
            // Shadow
//            self.layer.shadowOffset = CGSizeMake(0, 1)
//            self.layer.shadowRadius = 1
//            self.layer.shadowColor = UIColor.blackColor().CGColor
//            self.layer.shadowOpacity = 0.15
        }
    }
}

extension UISegmentedControl {
    var theme : Bool {
        get { return false }
        set {
            self.tintColor = SEGMENT_BG_COLOR
        }
    }
}

extension UITabBar {
    var theme : Bool {
        get { return false }
        set {
            self.barStyle = .Black
            self.translucent = false
            
            self.tintColor = NAVBAR_BG_COLOR
            self.barTintColor = TABBAR_BG_COLOR
            
            // Border top line
            let navBorder = UIView(frame: CGRectMake(0, 0, self.frame.size.width, 1))
            navBorder.backgroundColor = UIColor(red:0, green:0, blue:0, alpha:0.03)
            self.addSubview(navBorder)
            
            // Shadow
//            self.layer.shadowOffset = CGSizeMake(0, -1)
//            self.layer.shadowRadius = 2
//            self.layer.shadowColor = UIColor.blackColor().CGColor
//            self.layer.shadowOpacity = 0.05
        }
    }
}