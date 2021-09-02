import UIKit

final class CourseSearchSuggestionTableViewCell: UITableViewCell, Reusable {
    enum Appearance {
        static let regularFont = UIFont.systemFont(ofSize: 17)
        static let mediumFont = UIFont.systemFont(ofSize: 17, weight: .medium)
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
                .foregroundColor: UIColor.stepikMaterialSecondaryText
            ]
        )

        if let queryLocation = suggestion.lowercased().indexOf(query.lowercased()) {
            attributedSuggestionString.addAttributes(
                [
                    .font: Appearance.mediumFont,
                    .foregroundColor: UIColor.stepikMaterialPrimaryText
                ],
                range: NSRange(location: queryLocation, length: query.count)
            )
        }

        self.textLabel?.attributedText = attributedSuggestionString
    }
}
