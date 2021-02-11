import UIKit

enum Typography {
    /// The font for large titles.
    static let largeTitleFont = UIFont.preferredFont(forTextStyle: .largeTitle)
    /// The font used for first level hierarchical headings.
    static let title1Font = UIFont.preferredFont(forTextStyle: .title1)
    /// The font used for second level hierarchical headings.
    static let title2Font = UIFont.preferredFont(forTextStyle: .title2)
    /// The font used for third level hierarchical headings.
    static let title3Font = UIFont.preferredFont(forTextStyle: .title3)
    /// The font used for headings.
    static let headlineFont = UIFont.preferredFont(forTextStyle: .headline)
    /// The font used for body text.
    static let bodyFont = UIFont.preferredFont(forTextStyle: .body)
    /// The font used for callouts.
    static let calloutFont = UIFont.preferredFont(forTextStyle: .callout)
    /// The font used for subheadings.
    static let subheadlineFont = UIFont.preferredFont(forTextStyle: .subheadline)
    /// The font used in footnotes.
    static let footnoteFont = UIFont.preferredFont(forTextStyle: .footnote)
    /// The font used for standard captions.
    static let caption1Font = UIFont.preferredFont(forTextStyle: .caption1)
    /// The font used for alternate captions.
    static let caption2Font = UIFont.preferredFont(forTextStyle: .caption2)

    /// The font used for quiz contents text.
    static let quizContent = Self.bodyFont
    /// The font used for quiz feedbacks text.
    static var quizFeedback = Self.makeMonospacedFont(ofSize: 17, weight: .regular)

    // MARK: Private Helpers

    private static func makeMonospacedFont(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        if #available(iOS 13.0, *) {
            return UIFont.monospacedSystemFont(ofSize: size, weight: weight)
        } else {
            return UIFont.monospacedDigitSystemFont(ofSize: size, weight: weight)
        }
    }
}
