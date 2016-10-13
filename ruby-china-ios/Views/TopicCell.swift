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

private let kContentPadding = UIEdgeInsetsMake(10, 15, 10, 15)
private let kTextFont = UIFont.systemFontOfSize(14)
private let kAvatarSize = CGSize(width: 32, height: 32)
private let kTitleLeftMargin: CGFloat = 10
private let kRepliesCountWidth: CGFloat = 30
private let kButtonTitleColor = UIColor(red: 171.0 / 255.0, green: 168.0 / 255.0, blue: 166.0 / 255.0, alpha: 1)

class TopicCell: UITableViewCell {
    
    static private func titleAttributedText(data: Topic) -> NSAttributedString {
        let attributes: [String : AnyObject] = [NSFontAttributeName : kTextFont]
        let attributedString = NSMutableAttributedString(string: data.title, attributes: attributes)
        let attach = NSTextAttachment()
        if data.excellent {
            attach.image = UIImage(named: "diamond");
            attach.bounds = CGRect(x: 0, y: 0, width: 10, height: 10)
            attributedString.appendAttributedString(NSAttributedString(attachment: attach))
        }
        return attributedString
    }
    
    static func cellHeight(data: Topic) -> CGFloat {
        let titleWidth = UIScreen.mainScreen().bounds.size.width
            - kContentPadding.left - kContentPadding.right
            - kAvatarSize.width - kTitleLeftMargin - kRepliesCountWidth
        let title = self.titleAttributedText(data)
        let titleHeight = title.boundingRectWithSize(CGSize(width: titleWidth, height: CGFloat.max), options: .UsesLineFragmentOrigin, context: nil).height
        
        let ret = kContentPadding.top + titleHeight + kTextFont.lineHeight + kContentPadding.bottom
        return ceil(ret)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.contentView.addSubview(avatarImageView)
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
                avatarImageView.kf_setImageWithURL(data.user.avatarUrl)
                titleLabel.attributedText = TopicCell.titleAttributedText(data)
                repliesCountLabel.text = data.repliesCount > 0 ? "\(data.repliesCount)" : nil
                nodeButton.setTitle(data.nodeName, forState: .Normal)
                let userName = data.user.name == nil || data.user.name!.characters.count <= 0 ? data.user.login : data.user.name
                userNameButton.setTitle(userName, forState: .Normal)
            } else {
                avatarImageView.kf_setImageWithURL(nil)
                titleLabel.attributedText = nil
                repliesCountLabel.text = nil
                nodeButton.setTitle(nil, forState: .Normal)
                userNameButton.setTitle(nil, forState: .Normal)
            }
        }
    }
    
    private func setupConstraints() {
        avatarImageView.snp_makeConstraints { (make) in
            make.left.top.equalToSuperview().inset(kContentPadding)
            make.size.equalTo(kAvatarSize)
        }
        repliesCountLabel.snp_makeConstraints { (make) in
            make.top.right.equalToSuperview().inset(kContentPadding)
            make.width.equalTo(kRepliesCountWidth)
        }
        titleLabel.snp_makeConstraints { (make) in
            make.left.equalTo(avatarImageView.snp_right).offset(kTitleLeftMargin)
            make.top.equalToSuperview().inset(kContentPadding)
            make.right.equalTo(repliesCountLabel.snp_left)
        }
        nodeButton.snp_makeConstraints { (make) in
            make.left.equalTo(titleLabel)
            make.top.equalTo(titleLabel.snp_bottom)
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
//     func
    
    private lazy var avatarImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .ScaleAspectFill
        view.clipsToBounds = true
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
        return view
    }()
    
}
