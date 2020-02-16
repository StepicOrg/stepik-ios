import SnapKit
import UIKit

final class ExploreSearchBar: UISearchBar {
    enum Appearance {
        static let textColor = UIColor.mainDark
        static let placeholderText = NSLocalizedString("SearchCourses", comment: "")
    }

    weak var searchBarDelegate: UISearchBarDelegate?

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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension ExploreSearchBar: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(true, animated: true)
        self.searchBarDelegate?.searchBarTextDidBeginEditing?(searchBar)
    }

    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBarDelegate?.searchBarTextDidEndEditing?(searchBar)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchBar.text?.removeAll()
        searchBar.endEditing(true)

        searchBar.setShowsCancelButton(false, animated: true)
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
