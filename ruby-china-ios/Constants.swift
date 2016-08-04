import UIKit

#if DEBUG
let ROOT_URL = "http://localhost:3000"
let OAUTH_CLIENT_ID = "1b034acf"
let OAUTH_SECRET = "2d44bae75daaa88f2b8226a0205318b6ccf79b09e80fbfb461d191001d7b3c7b"
#else
let ROOT_URL = "https://ruby-china.org"
let OAUTH_CLIENT_ID = "1b034acf"
let OAUTH_SECRET = "2d44bae75daaa88f2b8226a0205318b6ccf79b09e80fbfb461d191001d7b3c7b"
#endif

let USER_AGENT = "turbolinks-app, ruby-china, official"

let BLACK = UIColor(red:0.20, green:0.20, blue:0.20, alpha:1.0)
let BLACK_LIGHT = UIColor.grayColor()
let RED = UIColor(red:0.92, green:0.33, blue:0.14, alpha:1.0)


// - 消息定义
/// 显示侧栏
let NOTICE_DISPLAY_MENU = "NOTICE_DISPLAY_MENU"
/// 侧栏菜单项被点击
let NOTICE_MENU_CLICKED = "NOTICE_MENU_CLICKED"
/// 侧栏菜单项被点击通知 userInfo中的信息
let NOTICE_MENU_CLICKED_PATH = "PATH"