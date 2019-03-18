import UIKit

protocol SettingsInputCellDelegate: class {
    func settingsCell(
        elementView: UITextField,
        didReportTextChange text: String?,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    )
}

final class SettingsInputTableViewCell<T: UITextField>: SettingsTableViewCell<T> {
    weak var delegate: SettingsInputCellDelegate?
    var uniqueIdentifier: UniqueIdentifierType?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.elementView.addTarget(self, action: #selector(self.textFieldDidChange(_:)), for: .editingChanged)
    }

    @objc
    private func textFieldDidChange(_ textField: UITextField) {
        self.delegate?.settingsCell(
            elementView: self.elementView,
            didReportTextChange: textField.text,
            identifiedBy: self.uniqueIdentifier
        )
    }
}
