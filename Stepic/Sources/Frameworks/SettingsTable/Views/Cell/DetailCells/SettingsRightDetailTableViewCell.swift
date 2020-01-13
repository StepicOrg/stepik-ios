import UIKit

final class SettingsRightDetailTableViewCell: SettingsTableViewCell<SettingsRightDetailCellView> {
    var uniqueIdentifier: UniqueIdentifierType?

    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            self.elementView.handleAccessoryTypeUpdate(self.accessoryType)
        }
    }
}
