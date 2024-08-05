import UIKit

extension UILabel {
    func hideWithOpacityEffect(duration: TimeInterval = 0.5) {
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }) { _ in
            self.isHidden = true
        }
    }
    
    func showWithOpacityEffect(duration: TimeInterval = 0.5) {
        self.isHidden = false
        self.alpha = 0
        UIView.animate(withDuration: duration) {
            self.alpha = 1
        }
    }
}
