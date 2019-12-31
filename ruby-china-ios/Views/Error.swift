struct RCError: Error {
    static let HTTPNotFoundError = RCError(title: "内容不存在", message: "抱歉，遇到错误，无法打开这个内容。")
    static let NetworkError = RCError(title: "暂时无法连接", message: "暂时无法连接到服务器，请检查你的网络状况是否正常，或 Ruby China 网站是不是暂时出问题了，然后重试。")
    static let UnknownError = RCError(title: "Unknown Error", message: "An unknown error occurred.")
    
    let title: String
    let message: String
    
    init(title: String, message: String) {
        self.title = title
        self.message = message
    }
    
    init(HTTPStatusCode: Int) {
        self.title = "Server Error"
        self.message = "The server returned an HTTP \(HTTPStatusCode) response."
    }
}
