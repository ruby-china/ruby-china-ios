//
//  TopicDetailsViewController.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/25.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit

class TopicDetailsViewController: WebViewController {
    
    private var topicID: Int!;
    private var followButton: ImageTitleView!
    private var likeButton: ImageTitleView!
    private var favorited: Bool = false
    
    
    convenience init(topicID: Int) {
        self.init(path: "/topics/\(topicID)")
        self.topicID = topicID
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        addMoreButton()
        addTopicActionButton()
        loadTopicActionButtonStatus()
    }
    
    override func reloadByLoginStatusChanged() {
        super.reloadByLoginStatusChanged()
        if isViewLoaded() {
            loadTopicActionButtonStatus()
        }
    }
    
}

// MARK: - action

extension TopicDetailsViewController {
    
    func topicAction(sender: AnyObject) {
        if !OAuth2.shared.isLogined {
            SignInViewController.show()
            return
        }
        guard let id = topicID else {
            return
        }
        guard let tap = sender as? UITapGestureRecognizer, button = tap.view as? ImageTitleView else {
            return
        }
        
        func callback1(response: APICallbackResponse) {
            callback2(response, likesCount: nil)
        }
        func callback2(response: APICallbackResponse, likesCount: Int?) {
            guard let code = response.response?.statusCode where code == 200 else {
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
    
    override func moreAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        let favoriteTitle = (favorited ? "cancel favorites" : "favorites").localized
        let favoriteAction = UIAlertAction(title: favoriteTitle, style: .Default) { [weak self] action in
            if !OAuth2.shared.isLogined {
                SignInViewController.show()
                return
            }
            
            guard let `self` = self, id = self.topicID else {
                return
            }
            
            if self.favorited {
                TopicsService.unfavorite(id) { [weak self] (response) in
                    if let code = response.response?.statusCode where code == 200 {
                        self?.favorited = false
                    }
                }
            } else {
                TopicsService.favorite(id) { [weak self] (response) in
                    if let code = response.response?.statusCode where code == 200 {
                        self?.favorited = true
                    }
                }
            }
        }
        sheet.addAction(favoriteAction)
        
        let shareAction = UIAlertAction(title: "share".localized, style: .Default) { [weak self] action in
            self?.shareAction()
        }
        sheet.addAction(shareAction)
        
        let cancelAction = UIAlertAction(title: "cancel".localized, style: .Cancel, handler: nil)
        sheet.addAction(cancelAction)
        self.presentViewController(sheet, animated: true, completion: nil)
    }
    
}

// MARK: - private

private let uncheckedTag = 0;
private let checkedTag = 1;

extension TopicDetailsViewController {
    
    private func createButton(icon icon: UIImage?, target: AnyObject, action: Selector) -> ImageTitleView {
        let button = ImageTitleView()
        button.titleLabel.font = UIFont.systemFontOfSize(11)
        button.titleLabel.text = title
        button.titleLabel.textColor = NAVBAR_TINT_COLOR
        button.titleLabel.textAlignment = .Center
        button.imageView.image = icon?.imageWithColor(NAVBAR_TINT_COLOR)
        button.frame = CGRect(x: 0, y: 0, width: 44, height: button.imageView.image!.size.height + button.titleLabel.font.lineHeight)
        button.addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
        return button
    }
    
    private func addTopicActionButton() {
        var rightBarButtonItems = navigationItem.rightBarButtonItems ?? [UIBarButtonItem.fixNavigationSpacer()]
        followButton = createButton(icon: UIImage(named: "invisible"), target: self, action: #selector(topicAction(_:)))
        likeButton = createButton(icon: UIImage(named: "like"), target: self, action: #selector(topicAction(_:)))
        rightBarButtonItems += [
            UIBarButtonItem(customView: followButton),
            UIBarButtonItem(customView: likeButton),
        ]
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    private func loadTopicActionButtonStatus() {
        guard let id = topicID where OAuth2.shared.isLogined else {
            self.setButton(followButton, checked: false)
            self.setButton(likeButton, checked: false)
            return
        }
        TopicsService.detail(id) { [weak self] (response, topic, topicMeta) in
            guard let code = response.response?.statusCode where code == 200 else {
                return
            }
            guard let `self` = self, topic = topic, meta = topicMeta else {
                return
            }
            
            self.favorited = meta.favorited
            self.setButton(self.followButton, checked: meta.followed)
            self.setButton(self.likeButton, checked: meta.liked, likesCount: topic.likesCount)
        }
    }
    
    private func setButton(button: ImageTitleView, checked: Bool, likesCount: Int? = nil) {
        var checkedImageNamed, uncheckedImageNamed: String!
        var checkedTitle, uncheckedTitle: String!
        if button == followButton {
            checkedImageNamed = "invisible-filled"
            uncheckedImageNamed = "invisible"
            checkedTitle = "followed".localized
            uncheckedTitle = "follow".localized
        } else if button == likeButton {
            checkedImageNamed = "like-filled"
            uncheckedImageNamed = "like"
            checkedTitle = "\(likesCount ?? 0)\("n like".localized)"
            uncheckedTitle = checkedTitle
        } else {
            return
        }
        
        button.tag = checked ? checkedTag : uncheckedTag
        let image = UIImage(named: checked ? checkedImageNamed : uncheckedImageNamed)?.imageWithColor(NAVBAR_TINT_COLOR)
        button.imageView.image = image
        button.titleLabel.text = checked ? checkedTitle : uncheckedTitle
        if checked {
            button.showImageZoomAnimation()
        }
    }
}
