import UIKit

protocol SettingsLargeInputCellDelegate: class {
    func settingsCell(
        elementView: UITextView,
        didReportTextChange text: String,
        identifiedBy uniqueIdentifier: UniqueIdentifierType?
    )
}

final class SettingsLargeInputTableViewCell<T: UITextView>: SettingsTableViewCell<T>, UITextViewDelegate {
    weak var delegate: SettingsLargeInputCellDelegate?
    var uniqueIdentifier: UniqueIdentifierType?

    /// Called when cell height should be update
    var onHeightUpdate: (() -> Void)?

    override func didMoveToSuperview() {
        super.didMoveToSuperview()
        self.selectionStyle = .none
        self.elementView.delegate = self
    }

    // MARK: UITextViewDelegate

    func textViewDidChange(_ textView: UITextView) {
        self.onHeightUpdate?()
        self.delegate?.settingsCell(
            elementView: self.elementView,
            didReportTextChange: textView.text,
            identifiedBy: self.uniqueIdentifier
        )
    }

    func textViewDidEndEditing(_ textView: UITextView) {
        self.onHeightUpdate?()
        self.delegate?.settingsCell(
            elementView: self.elementView,
            didReportTextChange: textView.text,
            identifiedBy: self.uniqueIdentifier
        )
    }
}
