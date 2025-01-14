import MEGADesignToken
import UIKit

@objc protocol SharedItemsTableViewCellDelegate {
    func didTapInfoButton(sender: UIButton)
}

final class SharedItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbnailImageView: UIImageView!
    @IBOutlet weak var nameLabel: MEGALabel!
    @IBOutlet weak var labelView: UIView!
    @IBOutlet weak var labelImageView: UIImageView!
    @IBOutlet weak var favouriteView: UIView!
    @IBOutlet weak var favouriteImageView: UIImageView!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var permissionsButton: UIButton!
    @IBOutlet weak var infoButton: UIButton!
    @IBOutlet weak var contactVerifiedImageView: UIImageView!
    
    @IBOutlet weak var descriptionLabel: UILabel!

    @objc var delegate: (any SharedItemsTableViewCellDelegate)?
    
    @objc var nodeHandle: UInt64 = 0
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateAppearance()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        infoButton.isHidden = editing
    }
    
    @IBAction func infoButtonTouchUpInside(_ sender: UIButton) {
        delegate?.didTapInfoButton(sender: sender)
    }
    
    // Pragma mark: - Private
    
    private func updateAppearance() {
        nameLabel.tintColor = TokenColors.Text.primary
        infoLabel.textColor = TokenColors.Text.secondary
        backgroundColor = TokenColors.Background.page
        infoButton.tintColor = TokenColors.Icon.secondary
        descriptionLabel.textColor = TokenColors.Text.secondary
    }

    @objc func setNodeDescription(_ desc: String?) {
        descriptionLabel?.text = desc
    }
}
