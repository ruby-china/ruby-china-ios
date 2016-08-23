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
        let navigationController = ThemeNavigationController(rootViewController: rootViewController)
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

extension UINavigationBar {
    var theme : Bool {
        get { return false }
        set {
            self.barStyle = .Black
            self.translucent = false
            self.tintColor = NAVBAR_TINT_COLOR
            // #F44336
            self.barTintColor = NAVBAR_BG_COLOR
            
            self.backIndicatorImage = UIImage(named: "back")
            self.backIndicatorTransitionMaskImage = UIImage(named: "back")
        }
    }
    
    var bottomBorder : Bool {
        get { return false }
        set {
            // Border bottom line
            let navBorder = UIView(frame: CGRectMake(0,self.frame.size.height-1, self.frame.size.width, 1))
            navBorder.backgroundColor = NAVBAR_BORDER_COLOR
            self.addSubview(navBorder)
            
            // Shadow
            self.layer.shadowOffset = CGSizeMake(0, 0.5)
            self.layer.shadowRadius = 1
            self.layer.shadowColor = UIColor.blackColor().CGColor
            self.layer.shadowOpacity = 0.05
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
            navBorder.backgroundColor = UIColor(red: 0.95, green: 0.92, blue: 0.92, alpha: 1.0)
            self.addSubview(navBorder)
        }
    }
}