import Foundation
import UIKit
import AdFitSDK

class AdfitNativeView : UIView, AdFitNativeAdRenderable {
    @IBOutlet weak var titleLabel: UILabel?
    @IBOutlet weak var profileLabel: UILabel?
    @IBOutlet weak var actionButton: UIButton?
    @IBOutlet weak var iconImageView: UIImageView?
    @IBOutlet weak var mediaView: AdFitMediaView?
    
    // MARK: - AdFitNativeAdRenderable
    func adTitleLabel() -> UILabel? {
        return titleLabel
    }
    
    func adCallToActionButton() -> UIButton? {
        return actionButton
    }
    
    func adProfileNameLabel() -> UILabel? {
        return profileLabel
    }
    
    func adProfileIconView() -> UIImageView? {
        return iconImageView
    }
    
    func adMediaView() -> AdFitMediaView? {
        return mediaView
    }
}
