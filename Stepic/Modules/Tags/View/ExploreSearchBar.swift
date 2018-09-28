//
//  ExploreSearchBar.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 28.09.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

final class ExploreSearchBar: UISearchBar {
    enum Appearance {
        static let searchFieldPositionAdjustment = UIOffset(horizontal: -6, vertical: 0)
        static let textColor = UIColor.mainDark.withAlphaComponent(0.3)

        // Height should be fixed and leq than 44pt (due to iOS 11+ strange nav bar)
        static let barHeight: CGFloat = 44.0

        static let placeholderText = NSLocalizedString("SearchCourses", comment: "")
    }

    private var isInitialized = false

    weak var searchBarDelegate: UISearchBarDelegate?

    override var delegate: UISearchBarDelegate? {
        willSet {
            if newValue !== self {
                fatalError("Use property searchBarDelegate to set or get delegate")
            }
        }
    }

    private var searchTextField: UITextField? {
        return self.value(forKey: "searchField") as? UITextField
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        self.delegate = self

        self.isTranslucent = false

        self.searchTextField?.backgroundColor = .clear
        self.searchTextField?.textColor = Appearance.textColor
        self.placeholder = Appearance.placeholderText
        self.searchTextField?.rightViewMode = .whileEditing

        self.applySystemFixes()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
    }

    private func applySystemFixes() {
        if #available(iOS 11.0, *) {
            self.searchFieldBackgroundPositionAdjustment = Appearance
                .searchFieldPositionAdjustment
            self.translatesAutoresizingMaskIntoConstraints = false
            self.snp.makeConstraints { make in
                make.height.equalTo(Appearance.barHeight)
            }
        }
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
        searchBar.endEditing(true)
        searchBar.setShowsCancelButton(false, animated: true)
        self.searchBarDelegate?.searchBarCancelButtonClicked?(searchBar)
    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarDelegate?.searchBar?(searchBar, textDidChange: searchText)
    }
}
