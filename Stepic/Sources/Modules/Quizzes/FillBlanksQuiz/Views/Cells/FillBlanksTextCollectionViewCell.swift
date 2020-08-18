import SnapKit
import UIKit

extension FillBlanksTextCollectionViewCell {
    struct Appearance {
        let textLabelInsets = LayoutInsets(top: 8, bottom: 8)
        let backgroundColor = UIColor.stepikBackground
    }
}

final class FillBlanksTextCollectionViewCell: UICollectionViewCell, Reusable {
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = self.appearance.backgroundColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()

    private var textLabelMaxWidthConstraint: Constraint?

    var appearance = Appearance()

    var text: String? {
        didSet {
            if let text = self.text {
                self.textLabel.setTextWithHTMLString(text)
            } else {
                self.textLabel.text = nil
            }
        }
    }

    var maxWidth: CGFloat? {
        didSet {
            if let maxWidth = self.maxWidth {
                self.textLabelMaxWidthConstraint?.activate()
                self.textLabelMaxWidthConstraint?.update(offset: maxWidth)
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: self.appearance.textLabelInsets.top
                + self.textLabel.intrinsicContentSize.height
                + self.appearance.textLabelInsets.bottom
        )
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.setupView()
        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var isHighlighted: Bool {
        didSet {
            self.contentView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }
}

extension FillBlanksTextCollectionViewCell: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.contentView.isOpaque = true
    }

    func addSubviews() {
        self.contentView.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            self.textLabelMaxWidthConstraint = make.width.lessThanOrEqualTo(0).constraint
            self.textLabelMaxWidthConstraint?.deactivate()

            make.top.equalToSuperview().offset(self.appearance.textLabelInsets.top)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview().offset(-self.appearance.textLabelInsets.bottom)
        }
    }
}
