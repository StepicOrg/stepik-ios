import SnapKit
import UIKit

extension CodeSuggestionTableViewCell {
    enum Appearance {
        static let defaultFontSize: CGFloat = 11
    }
}

final class CodeSuggestionTableViewCell: UITableViewCell, Reusable {
    private lazy var cellView = CodeSuggestionCellView()

    override func updateConstraintsIfNeeded() {
        super.updateConstraintsIfNeeded()

        if self.cellView.superview == nil {
            self.setupSubview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        self.cellView.attributedText = nil
    }

    func setSuggestion(_ suggestion: String, prefixLength: Int, size: CodeSuggestionsSize?) {
        let fontSize = size?.realSizes.fontSize ?? Appearance.defaultFontSize

        let boldFont = UIFont(name: "Courier-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize)
        let regularFont = UIFont(name: "Courier", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)

        let attributedSuggestion = NSMutableAttributedString(string: suggestion, attributes: [.font: regularFont])
        attributedSuggestion.addAttributes([.font: boldFont], range: NSRange(location: 0, length: prefixLength))

        self.cellView.attributedText = attributedSuggestion
    }

    private func setupSubview() {
        self.contentView.addSubview(self.cellView)
        self.cellView.translatesAutoresizingMaskIntoConstraints = false
        self.cellView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
