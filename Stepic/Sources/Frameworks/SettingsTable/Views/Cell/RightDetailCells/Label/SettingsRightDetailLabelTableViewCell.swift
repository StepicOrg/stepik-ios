import UIKit

final class SettingsRightDetailLabelTableViewCell: SettingsTableViewCell<SettingsRightDetailLabelCellView> {
    var uniqueIdentifier: UniqueIdentifierType?

    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            self.elementView.handleAccessoryTypeUpdate(self.accessoryType)
        }
    }
}
