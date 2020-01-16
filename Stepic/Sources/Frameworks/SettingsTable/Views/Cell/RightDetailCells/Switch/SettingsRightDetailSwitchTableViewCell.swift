import UIKit

protocol SettingsRightDetailSwitchCellDelegate: AnyObject {
    func settingsCell(
        _ cell: SettingsRightDetailSwitchTableViewCell,
        switchValueChanged isOn: Bool
    )
}

final class SettingsRightDetailSwitchTableViewCell: SettingsTableViewCell<SettingsRightDetailSwitchCellView> {
    weak var delegate: SettingsRightDetailSwitchCellDelegate?
    var uniqueIdentifier: UniqueIdentifierType?

    override var accessoryType: UITableViewCell.AccessoryType {
        didSet {
            self.elementView.handleAccessoryTypeUpdate(self.accessoryType)
        }
    }

    override func didMoveToSuperview() {
        super.didMoveToSuperview()

        self.selectionStyle = .none
        self.elementView.onSwitchValueChanged = { [weak self] isOn in
            guard let strongSelf = self else {
                return
            }

            strongSelf.delegate?.settingsCell(strongSelf, switchValueChanged: isOn)
        }
    }
}
