//
//  FavoriteTopicsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/11/2.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import Alamofire

class FavoriteTopicsViewController: TopicsViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "favorites".localized
        tableView.mj_header.beginRefreshing()
        
        NotificationCenter.default.addObserver(self, selector: #selector(favoriteChangedAction), name: NSNotification.Name.userFavoriteChanged, object: nil)
    }
    
    override func loadTopics(offset: Int, limit: Int, callback: @escaping (APICallbackResponse, [Topic]?) -> ()) {
        if let user = OAuth2.shared.currentUser {
            UsersService.favorites(userLogin: user.login, offset: offset, limit: limit, callback: callback)
        } else {
            let result = Result<Data>.failure(NSError(domain: "customize", code: -1, userInfo: [NSLocalizedDescriptionKey: "not sign in".localized]))
            let response = APICallbackResponse(request: nil, response: nil, data: nil, result: result)
            callback(response, nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        return .delete
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if let topic = topicList?.remove(at: indexPath.row), editingStyle == .delete {
            TopicsService.unfavorite(topic.id)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    @objc func favoriteChangedAction() {
        var limit = topicList == nil ? defaultLimit : topicList!.count
        limit = max(defaultLimit, limit)
        load(offset: 0, limit: limit)
    }
}
