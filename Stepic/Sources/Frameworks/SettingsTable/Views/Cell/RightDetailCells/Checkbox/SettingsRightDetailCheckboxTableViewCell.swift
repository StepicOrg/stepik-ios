import UIKit

protocol SettingsRightDetailCheckboxCellDelegate: AnyObject {
    func settingsCell(
        _ cell: SettingsRightDetailCheckboxTableViewCell,
        checkboxValueChanged isOn: Bool
    )
}

final class SettingsRightDetailCheckboxTableViewCell: SettingsTableViewCell<SettingsRightDetailCheckboxCellView> {
    weak var delegate: SettingsRightDetailCheckboxCellDelegate?
    var uniqueIdentifier: UniqueIdentifierType?

    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            self.elementView.handleAccessoryTypeUpdate(self.accessoryType)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.elementView.onCheckBoxValueChanged = { [weak self] isOn in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.settingsCell(strongSelf, checkboxValueChanged: isOn)
        }
    }
}
