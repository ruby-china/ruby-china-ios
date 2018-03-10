//
//  TopicDetailsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/25.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicDetailsViewController: WebViewController {
    
    private(set) var topicID: Int!
    fileprivate var followButton: UIButton!
    fileprivate var likeButton: UIButton!
    fileprivate var favorited: Bool = false
    fileprivate var interactivePopDelegate: UIGestureRecognizerDelegate?
    
    convenience init(topicID: Int, topicPath: String? = nil) {
        self.init(path: topicPath ?? "/topics/\(topicID)")
        self.topicID = topicID

        navigationController?.title = "阅读话题"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setToolbars()
        loadTopicActionButtonStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        navigationController?.setToolbarHidden(false, animated: animated)
        interactivePopDelegate = navigationController?.interactivePopGestureRecognizer?.delegate
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.setToolbarHidden(true, animated: animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = interactivePopDelegate
    }
    
    func setToolbars() {
        let statusBarView = UIView(frame: UIApplication.shared.statusBarFrame)
        let statusBarColor = UIColor.white
        statusBarView.backgroundColor = statusBarColor
        view.addSubview(statusBarView)

        let (backItem, _) = UIBarButtonItem.narrowButtonItem2(image: UIImage(named: "back"), target: self, action: #selector(backAction))
        let (moreItem, _) = UIBarButtonItem.narrowButtonItem2(image: UIImage(named: "dropdown"), target: self, action: #selector(moreAction))
        
        let (followItem, followBtn) = UIBarButtonItem.narrowButtonItem2(image: UIImage(named: "invisible"), target: self, action: #selector(topicAction(_:)))
        followButton = followBtn
        
        let (likeItem, likeBtn) = UIBarButtonItem.narrowButtonItem2(image: UIImage(named: "like"), target: self, action: #selector(topicAction(_:)))
        likeBtn.frame.size.width = 50
        likeBtn.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        likeBtn.setTitleColor(PRIMARY_COLOR, for: UIControlState())
        likeButton = likeBtn
        
        let fixedBar = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        
        toolbarItems = [backItem, fixedBar, likeItem, fixedBar, followItem, moreItem]
    }
    
    override func reloadByLoginStatusChanged() {
        super.reloadByLoginStatusChanged()
        if isViewLoaded {
            loadTopicActionButtonStatus()
        }
    }
}

// MARK: - action
@objc
extension TopicDetailsViewController {
    
    override func moreAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let favoriteTitle = (favorited ? "cancel favorites" : "favorites").localized
        let favoriteAction = UIAlertAction(title: favoriteTitle, style: .default) { [weak self] action in
            self?.favoriteAction()
        }
        sheet.addAction(favoriteAction)
        
        let shareAction = UIAlertAction(title: "share".localized, style: .default) { [weak self] action in
            self?.shareAction()
        }
        sheet.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .cancel, handler: nil)
        sheet.addAction(cancelAction)
        self.present(sheet, animated: true, completion: nil)
    }
    
    func topicAction(_ button: UIButton) {
        if !OAuth2.shared.isLogined {
            SignInViewController.show()
            return
        }
        guard let id = topicID else {
            return
        }
        
        func callback1(_ response: APICallbackResponse) {
            callback2(response, likesCount: nil)
        }
        func callback2(_ response: APICallbackResponse, likesCount: Int?) {
            guard let code = response.response?.statusCode , code == 200 else {
                return
            }
            
            let checked = button.tag == uncheckedTag
            self.setButton(button, checked: checked, likesCount: likesCount)
        }
        
        if button == followButton {
            if button.tag == uncheckedTag {
                TopicsService.follow(id, callback: callback1)
            } else {
                TopicsService.unfollow(id, callback: callback1)
            }
        } else if button == likeButton {
            if button.tag == uncheckedTag {
                LikesService.like(.topic, id: id, callback: callback2)
            } else {
                LikesService.unlike(.topic, id: id, callback: callback2)
            }
        }
    }
    
    func favoriteAction() {
        if !OAuth2.shared.isLogined {
            SignInViewController.show()
            return
        }
        
        if favorited {
            TopicsService.unfavorite(topicID) { [weak self] (response) in
                if let code = response.response?.statusCode , code == 200 {
                    self?.favorited = false
                    NotificationCenter.default.post(name: NSNotification.Name.userFavoriteChanged, object: nil)
                }
            }
        } else {
            TopicsService.favorite(topicID) { [weak self] (response) in
                if let code = response.response?.statusCode , code == 200 {
                    self?.favorited = true
                    NotificationCenter.default.post(name: NSNotification.Name.userFavoriteChanged, object: nil)
                }
            }
        }
    }
    
}

// MARK: - private

private let uncheckedTag = 0;
private let checkedTag = 1;

extension TopicDetailsViewController {
    
    fileprivate func loadTopicActionButtonStatus() {
        guard let id = topicID , OAuth2.shared.isLogined else {
            self.setButton(followButton, checked: false)
            self.setButton(likeButton, checked: false)
            return
        }
        TopicsService.detail(id) { [weak self] (response, topic, topicMeta) in
            guard let code = response.response?.statusCode , code == 200 else {
                return
            }
            guard let `self` = self, let topic = topic, let meta = topicMeta else {
                return
            }
            
            self.favorited = meta.favorited
            self.setButton(self.followButton, checked: meta.followed)
            self.setButton(self.likeButton, checked: meta.liked, likesCount: topic.likesCount)
        }
    }
    
    fileprivate func setButton(_ button: UIButton, checked: Bool, likesCount: Int? = nil) {
        var checkedImageNamed, uncheckedImageNamed: String!
        var title: String?
        if button == followButton {
            checkedImageNamed = "invisible-filled"
            uncheckedImageNamed = "invisible"
        } else if button == likeButton {
            checkedImageNamed = "like-filled"
            uncheckedImageNamed = "like"
            title = " \(likesCount ?? 0)"
        } else {
            return
        }
        
        button.tag = checked ? checkedTag : uncheckedTag
        let image = UIImage(named: checked ? checkedImageNamed : uncheckedImageNamed)
        button.setImage(image?.imageWithColor(PRIMARY_COLOR), for: UIControlState())
        button.setTitle(title, for: UIControlState())
        // 选中动画
        if let imageView = button.imageView , checked {
            imageView.transform = CGAffineTransform(scaleX: 0.0, y: 0.0)
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.5, initialSpringVelocity: 20, options: UIViewAnimationOptions.curveLinear, animations: {
                imageView.transform = CGAffineTransform(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
}
