//
//  TopicCell.swift
//  ruby-china-ios
//
//  Created by 柯磊 on 16/10/12.
//  Copyright © 2016年 ruby-china. All rights reserved.
//

import UIKit
import SnapKit
import Kingfisher
import FontAwesome_swift

private let kContentPadding = UIEdgeInsetsMake(10, 15, 10, 15)
private let kTitleTextSize: CGFloat = 14
private let kTextSize: CGFloat = 12
private let kTextFont = UIFont.systemFontOfSize(kTextSize)
private let kTitleTextFont = UIFont.systemFontOfSize(kTitleTextSize)
private let kAvatarSize = CGSize(width: 32, height: 32)
private let kButtonTitleColor = UIColor(red: 171.0 / 255.0, green: 168.0 / 255.0, blue: 166.0 / 255.0, alpha: 1)

class TopicCell: UITableViewCell {
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(avatarImageView)
        self.contentView.addSubview(avatarMaskImageView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(repliesCountLabel)
        self.contentView.addSubview(nodeButton)
        self.contentView.addSubview(separateLabel)
        self.contentView.addSubview(userNameButton)
        setupConstraints()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var data: Topic? {
        didSet {
            if let data = data {
                avatarImageView.kf_setImageWithURL(data.user.avatarUrl, optionsInfo: [
                    .BackgroundDecode,
                    .Transition(ImageTransition.Fade(1))
                ])
                titleLabel.attributedText = titleAttributedText(data)
                repliesCountLabel.text = data.repliesCount > 0 ? "\(data.repliesCount)" : nil
                nodeButton.setTitle(data.nodeName, forState: .Normal)
                userNameButton.setTitle(data.user.login, forState: .Normal)
            } else {
                avatarImageView.kf_setImageWithURL(nil)
                titleLabel.attributedText = nil
                repliesCountLabel.text = nil
                nodeButton.setTitle(nil, forState: .Normal)
                userNameButton.setTitle(nil, forState: .Normal)
            }
        }
    }
    
    var onUserClick: ((data: Topic?) -> ())?
    var onNodeClick: ((data: Topic?) -> ())?
    
    func userAction() {
        if let action = onUserClick {
            action(data: data)
        }
    }
    
    func nodeAction() {
        if let action = onNodeClick {
            action(data: data)
        }
    }
    
    private func setupConstraints() {
        avatarImageView.snp_makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(kContentPadding)
            make.size.equalTo(kAvatarSize)
        }
        avatarMaskImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(avatarImageView)
        }
        repliesCountLabel.snp_makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(kContentPadding)
            make.width.equalTo(30)
        }
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp_right).offset(10)
            make.top.equalToSuperview().inset(kContentPadding)
            make.right.equalTo(repliesCountLabel.snp_left)
        }
        nodeButton.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom)
            make.bottom.equalToSuperview()
        }
        separateLabel.snp_makeConstraints { (make) in
            make.left.equalTo(nodeButton.snp_right)
            make.centerY.equalTo(nodeButton)
        }
        userNameButton.snp_makeConstraints { (make) in
            make.left.equalTo(separateLabel.snp_right)
            make.centerY.equalTo(nodeButton)
        }
    }
    
    private func titleAttributedText(data: Topic) -> NSAttributedString {
        let attributes = [NSFontAttributeName : kTitleTextFont]
        let attributedString = NSMutableAttributedString(string: data.title, attributes: attributes)
        if data.excellent {
            let attributes = [NSFontAttributeName : UIFont.fontAwesomeOfSize(kTitleTextSize),
                              NSForegroundColorAttributeName : PRIMARY_COLOR]
            let diamondString = " \(String.fontAwesomeIconWithName(.Diamond))"
            let diamondAttributed = NSAttributedString(string: diamondString, attributes: attributes)
            attributedString.appendAttributedString(diamondAttributed)
        }
        return attributedString
    }
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
        view.backgroundColor = UIColor(white: 0.85, alpha: 1)
        view.userInteractionEnabled = true
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(userAction)))
        return view
    }()
    private lazy var avatarMaskImageView: UIImageView = {
        let view = UIImageView()
        view.image = UIImage(named: "avatar-mask")!.imageWithRenderingMode(.AlwaysTemplate)
        view.tintColor = UIColor.whiteColor()
        return view
    }()
    private lazy var titleLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(white: 0.13, alpha: 1)
        view.numberOfLines = 0
        return view
    }()
    private lazy var repliesCountLabel: UILabel = {
        let view = UILabel()
        view.textColor = UIColor(white: 0.4, alpha: 1)
        view.font = kTextFont
        view.textAlignment = .Right
        return view
    }()
    private lazy var nodeButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = kTextFont
        view.setTitleColor(kButtonTitleColor, forState: .Normal)
        view.addTarget(self, action: #selector(nodeAction), forControlEvents: .TouchUpInside)
        return view
    }()
    private lazy var separateLabel: UILabel = {
        let view = UILabel()
        view.font = kTextFont
        view.textColor = kButtonTitleColor
        view.text = " • "
        return view
    }()
    private lazy var userNameButton: UIButton = {
        let view = UIButton()
        view.titleLabel?.font = kTextFont
        view.setTitleColor(kButtonTitleColor, forState: .Normal)
        view.addTarget(self, action: #selector(userAction), forControlEvents: .TouchUpInside)
        return view
    }()
    
}
