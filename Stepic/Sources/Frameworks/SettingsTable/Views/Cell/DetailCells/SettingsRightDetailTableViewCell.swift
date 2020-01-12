import UIKit

final class SettingsRightDetailTableViewCell: SettingsTableViewCell<SettingsRightDetailCellView> {
    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            self.elementView.handleAccessoryTypeUpdate(self.accessoryType)
        }
    }
}
