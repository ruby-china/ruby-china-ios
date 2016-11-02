import UIKit

class ErrorView: UIView {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var retryButton: UIButton!
    
    var error: Error? {
        didSet {
            retryButton.tintColor = PRIMARY_COLOR
            retryButton.setTitle("retry".localized, for: .normal)
            titleLabel.text = error?.title
            messageLabel.text = error?.message
        }
    }
}
