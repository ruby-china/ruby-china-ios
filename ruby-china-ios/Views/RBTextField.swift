//
//  RBTextField.swift
//  ruby-china-ios
//
//  Created by Jason Lee on 16/7/26.
//  Copyright © 2016年 ruby-china. All rights reserved.
//
import UIKit

@IBDesignable
class RBTextField : UITextField {
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        setupView()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupView()
    }
    
    func setupView(){
        
        self.borderStyle = UITextBorderStyle.None
        let border = CALayer()
        let borderWidth: CGFloat = 1
        border.borderColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.15).CGColor
        border.frame = CGRectMake(0, self.frame.size.height - borderWidth, self.frame.size.width, self.frame.size.height)
        border.borderWidth = borderWidth
        self.layer.addSublayer(border)
        
    }
}
