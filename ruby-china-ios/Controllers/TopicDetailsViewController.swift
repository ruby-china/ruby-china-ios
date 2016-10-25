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
    private var topicFavoriteButton: ImageTitleView!
    private var topicFollowButton: ImageTitleView!
    private var topicLikeButton: ImageTitleView!
    
    
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
        
        func callback1(statusCode: Int?) {
            callback2(statusCode, likesCount: nil)
        }
        func callback2(statusCode: Int?, likesCount: Int?) {
            guard let code = statusCode where code == 200 else {
                return
            }
            
            let checked = button.tag == uncheckedTag
            self.setButton(button, checked: checked, likesCount: likesCount)
            
            var successMessage = ""
            if button == topicFavoriteButton {
                successMessage = "favorited".localized
            } else if button == topicFollowButton {
                successMessage = "followed".localized
            } else if button == topicLikeButton {
                successMessage = "liked".localized
            } else {
                return
            }
            RBHUD.success(checked ? successMessage : "cancelled".localized)
        }
        
        if button == topicFavoriteButton {
            if button.tag == uncheckedTag {
                TopicsService.favorite(id, callback: callback1)
            } else {
                TopicsService.unfavorite(id, callback: callback1)
            }
        } else if button == topicFollowButton {
            if button.tag == uncheckedTag {
                TopicsService.follow(id, callback: callback1)
            } else {
                TopicsService.unfollow(id, callback: callback1)
            }
        } else if button == topicLikeButton {
            if button.tag == uncheckedTag {
                LikesService.like(.topic, id: id, callback: callback2)
            } else {
                LikesService.unlike(.topic, id: id, callback: callback2)
            }
        }
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
        topicFavoriteButton = createButton(icon: UIImage(named: "bookmark"), target: self, action: #selector(topicAction(_:)))
        topicFollowButton = createButton(icon: UIImage(named: "invisible"), target: self, action: #selector(topicAction(_:)))
        topicLikeButton = createButton(icon: UIImage(named: "like"), target: self, action: #selector(topicAction(_:)))
        rightBarButtonItems += [
            UIBarButtonItem(customView: topicFavoriteButton),
            UIBarButtonItem(customView: topicFollowButton),
            UIBarButtonItem(customView: topicLikeButton),
        ]
        navigationItem.rightBarButtonItems = rightBarButtonItems
    }
    
    private func loadTopicActionButtonStatus() {
        guard let id = topicID where OAuth2.shared.isLogined else {
            self.setButton(self.topicFavoriteButton, checked: false)
            self.setButton(self.topicFollowButton, checked: false)
            self.setButton(self.topicLikeButton, checked: false)
            return
        }
        TopicsService.detail(id) { [weak self] (statusCode, topic, topicMeta) in
            guard let code = statusCode where code == 200 else {
                return
            }
            guard let `self` = self, topic = topic, meta = topicMeta else {
                return
            }
            
            self.setButton(self.topicFavoriteButton, checked: meta.favorited)
            self.setButton(self.topicFollowButton, checked: meta.followed)
            self.setButton(self.topicLikeButton, checked: meta.liked, likesCount: topic.likesCount)
        }
    }
    
    private func setButton(button: ImageTitleView, checked: Bool, likesCount: Int? = nil) {
        var checkedImageNamed, uncheckedImageNamed: String!
        var checkedTitle, uncheckedTitle: String!
        if button == topicFavoriteButton {
            checkedImageNamed = "bookmark-filled"
            uncheckedImageNamed = "bookmark"
            checkedTitle = "已收藏"
            uncheckedTitle = "收藏"
        } else if button == topicFollowButton {
            checkedImageNamed = "invisible-filled"
            uncheckedImageNamed = "invisible"
            checkedTitle = "已关注"
            uncheckedTitle = "关注"
        } else if button == topicLikeButton {
            checkedImageNamed = "like-filled"
            uncheckedImageNamed = "like"
            checkedTitle = "\(likesCount ?? 0)个赞"
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
