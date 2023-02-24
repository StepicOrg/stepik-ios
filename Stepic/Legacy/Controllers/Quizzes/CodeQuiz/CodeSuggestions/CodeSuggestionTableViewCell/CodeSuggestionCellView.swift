import SnapKit
import UIKit

extension CodeSuggestionCellView {
    struct Appearance {
        let textColor = UIColor.stepikPrimaryText
        let textInsets = LayoutInsets(top: 4, left: 10, bottom: 4, right: 0)
    }
}

final class CodeSuggestionCellView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.textColor
        label.numberOfLines = 1
        return label
    }()

    var attributedText: NSAttributedString? {
        didSet {
            self.textLabel.attributedText = self.attributedText
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.textInsets.top
            + self.textLabel.intrinsicContentSize.height
            + self.appearance.textInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CodeSuggestionCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(self.appearance.textInsets.edgeInsets)
        }
    }
}
