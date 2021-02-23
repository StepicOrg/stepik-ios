import SnapKit
import UIKit

protocol SubmissionsSearchBarDelegate: UISearchBarDelegate {}

final class SubmissionsSearchBar: UISearchBar {
    enum Appearance {
        static let searchFieldPositionAdjustment = UIOffset(horizontal: -6, vertical: 0)
        static let textColor = UIColor.stepikSystemPrimaryText

        // Height should be fixed and leq than 44pt (due to iOS 11+ strange nav bar)
        static let barHeight: CGFloat = 44.0

        static let placeholderText = NSLocalizedString("SubmissionsSearchBarPlaceholderText", comment: "")
    }

    weak var searchBarDelegate: SubmissionsSearchBarDelegate?

    override var delegate: UISearchBarDelegate? {
        willSet {
            if newValue !== self {
                fatalError("Use property searchBarDelegate to set or get delegate")
            }
        }
    }

    private var searchField: UITextField? {
        self.value(forKey: "searchField") as? UITextField
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.delegate = self
        self.placeholder = Appearance.placeholderText
        self.searchBarStyle = .minimal

        self.searchField?.backgroundColor = .clear
        self.searchField?.textColor = Appearance.textColor

        self.applySystemFixes()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func cancel() {
        self.resignFirstResponder()
        self.text?.removeAll()
        self.searchBarDelegate?.searchBar?(self, textDidChange: self.text ?? "")
        self.endEditing(true)
        self.setShowsCancelButton(false, animated: true)
    }

    private func applySystemFixes() {
        self.searchFieldBackgroundPositionAdjustment = Appearance.searchFieldPositionAdjustment
        self.translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { make in
            make.height.equalTo(Appearance.barHeight)
        }
    }
}

extension SubmissionsSearchBar: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        self.searchBarDelegate?.searchBarTextDidBeginEditing?(searchBar)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBarDelegate?.searchBarTextDidEndEditing?(searchBar)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.cancel()
        self.searchBarDelegate?.searchBarCancelButtonClicked?(searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarDelegate?.searchBar?(searchBar, textDidChange: searchText)
    }

    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.searchBarDelegate?.searchBarSearchButtonClicked?(searchBar)
    }
}
