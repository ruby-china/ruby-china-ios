import UIKit

#if DEBUG1
    let ROOT_URL = "http://localhost:3000"
    let OAUTH_CLIENT_ID = "1c58e228"
    let OAUTH_SECRET = "6d2c9cbef3e4baa56e1cf1d0db41d213105221aeff01281ac7009d21af810c58"
#else
    let ROOT_URL = "https://ruby-china.org"
    let OAUTH_CLIENT_ID = "1c58e228"
    let OAUTH_SECRET = "6d2c9cbef3e4baa56e1cf1d0db41d213105221aeff01281ac7009d21af810c58"
#endif

let COPYRIGHT_URL = "https://github.com/ruby-china/ruby-china-ios/blob/master/LICENSE.md"
let PROJECT_URL = "https://github.com/ruby-china/ruby-china-ios"

let APP_VERSION = Bundle.main.infoDictionary!["CFBundleShortVersionString"] as! String
let USER_AGENT = "turbolinks-app, ruby-china, official, iOS, version:" + APP_VERSION

// Blue Theme
//let NAVBAR_BG_COLOR = UIColor(red:0.25, green:0.32, blue:0.71, alpha:1.0)
//let NAVBAR_BORDER_COLOR = UIColor(red:0.25, green:0.32, blue:0.61, alpha:1.0)
//let NAVBAR_TINT_COLOR = UIColor(red:1.00, green:1.00, blue:0.93, alpha:1.0)
//let TABBAR_BG_COLOR = UIColor(red:0.88, green:0.96, blue:1.00, alpha:1.0)

// Red Theme
let BLACK_COLOR = UIColor(red: 0.04, green: 0.02, blue: 0.02, alpha: 1.0)
let PRIMARY_COLOR = UIColor(red: 0, green: 0, blue: 0, alpha: 1.0)
let SIDEMENU_NAVBAR_BG_COLOR = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
let SIDEMENU_BG_COLOR = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1.0)

let NAVBAR_BG_COLOR = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)
let NAVBAR_BORDER_COLOR = UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1.0)
let NAVBAR_TINT_COLOR = UIColor(red: 1.00, green: 1.00, blue: 0.98, alpha: 1.0)
let TABBAR_BG_COLOR = UIColor(red: 1, green: 1, blue: 1, alpha: 1.0)

