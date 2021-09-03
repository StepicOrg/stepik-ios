import UIKit

final class CourseSearchSuggestionTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let separatorHeight: CGFloat = 0.5
        static let separatorColor = UIColor.stepikSeparator
        static let separatorInsets = LayoutInsets(left: 16)

        static let regularFont = UIFont.systemFont(ofSize: 17)
        static let regularTextColor = UIColor.stepikMaterialSecondaryText

        static let highlightedFont = UIFont.systemFont(ofSize: 17, weight: .medium)
        static let highlightedTextColor = UIColor.stepikMaterialPrimaryText
    }

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = Appearance.separatorColor
        return view
    }()

    private lazy var searchImage: UIImage? = {
        if #available(iOS 13.0, *) {
            return UIImage(
                systemName: "magnifyingglass",
                withConfiguration: UIImage.SymbolConfiguration(scale: .default)
            )
        } else {
            return nil
        }
    }()

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.separatorView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.textLabel?.attributedText = nil
    }

    func configure(suggestion: String, query: String) {
        let attributedSuggestionString = NSMutableAttributedString(
            string: suggestion,
            attributes: [
                .font: Appearance.regularFont,
                .foregroundColor: Appearance.regularTextColor
            ]
        )

        if let queryLocation = suggestion.lowercased().indexOf(query.lowercased()) {
            attributedSuggestionString.addAttributes(
                [
                    .font: Appearance.highlightedFont,
                    .foregroundColor: Appearance.highlightedTextColor
                ],
                range: NSRange(location: queryLocation, length: query.count)
            )
        }

        self.textLabel?.attributedText = attributedSuggestionString

        if let searchImage = self.searchImage {
            self.imageView?.image = searchImage
            self.imageView?.tintColor = Appearance.highlightedTextColor
        }
    }

    private func setupSubview() {
        self.contentView.addSubview(self.separatorView)

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(Appearance.separatorHeight)
            make.leading.equalToSuperview().offset(Appearance.separatorInsets.left)
            make.bottom.trailing.equalToSuperview()
        }
    }
}
