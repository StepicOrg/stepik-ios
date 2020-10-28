import BEMCheckBox
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

final class SettingsCheckBoxCellGroup: UniqueIdentifiable {
    private(set) var uniqueIdentifier: UniqueIdentifierType

    private let checkBoxGroup: BEMCheckBoxGroup

    var mustHaveSelection: Bool {
        get {
            self.checkBoxGroup.mustHaveSelection
        }
        set {
            self.checkBoxGroup.mustHaveSelection = newValue
        }
    }

    init(uniqueIdentifier: UniqueIdentifierType) {
        self.uniqueIdentifier = uniqueIdentifier
        self.checkBoxGroup = BEMCheckBoxGroup()
    }

    func addCheckBoxCell(_ cell: SettingsRightDetailCheckboxTableViewCell) {
        self.checkBoxGroup.addCheckBox(toGroup: cell.elementView.checkBox)
    }

    func containsCheckBoxCell(_ cell: SettingsRightDetailCheckboxTableViewCell) -> Bool {
        self.checkBoxGroup.checkBoxes.contains(cell.elementView.checkBox)
    }

    func setCheckBoxCellSelected(_ cell: SettingsRightDetailCheckboxTableViewCell) {
        self.checkBoxGroup.selectedCheckBox = cell.elementView.checkBox
    }
}
