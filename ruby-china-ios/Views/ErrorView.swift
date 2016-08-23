import UIKit

class ErrorView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var retryButton: UIButton!
    
    var error: Error? {
        didSet {
            retryButton.tintColor = PRIMARY_COLOR
            titleLabel.text = error?.title
            messageLabel.text = error?.message
        }
    }
}