import SnapKit
import UIKit

protocol ExploreSearchBarProtocol: UISearchBar {
    var searchBarDelegate: UISearchBarDelegate? { get set }
}

final class NewExploreSearchBar: UISearchBar, ExploreSearchBarProtocol {
    enum Appearance {
        static let textColor = UIColor.mainDark

        // Height should be fixed and leq than 44pt (due to iOS 11+ strange nav bar)
        static let barHeight: CGFloat = 44.0

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
        if #available(iOS 13.0, *) {
            return self.searchTextField
        } else {
            return self.value(forKey: "searchField") as? UITextField
        }
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self

        self.isTranslucent = false

        self.searchField?.backgroundColor = .clear
        self.searchField?.textColor = Appearance.textColor
        self.placeholder = Appearance.placeholderText
        self.searchField?.rightViewMode = .whileEditing
        self.searchBarStyle = .minimal

        self.applySystemFixes()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func applySystemFixes() {
        self.translatesAutoresizingMaskIntoConstraints = false
        self.snp.makeConstraints { make in
            make.height.equalTo(Appearance.barHeight)
        }
    }
}

extension NewExploreSearchBar: UISearchBarDelegate {
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
