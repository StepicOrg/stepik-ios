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
        self.selectionStyle = .none
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

final class SettingsInputCellGroup: UniqueIdentifiable {
    private let cells = NSHashTable<SettingsInputTableViewCell<TableInputTextField>>.weakObjects()

    private(set) var uniqueIdentifier: UniqueIdentifierType

    init(uniqueIdentifier: UniqueIdentifierType) {
        self.uniqueIdentifier = uniqueIdentifier
    }

    /// Add cell and arrange placeholder in each cell
    func addInputCell(_ cell: SettingsInputTableViewCell<TableInputTextField>) {
        self.cells.add(cell)

        let maxPlaceholderWidth = self.cells.allObjects.map { $0.elementView.placeholderWidth }.max() ?? 0
        self.cells.allObjects.forEach { $0.elementView.placeholderMinimalWidth = maxPlaceholderWidth }
    }
}
