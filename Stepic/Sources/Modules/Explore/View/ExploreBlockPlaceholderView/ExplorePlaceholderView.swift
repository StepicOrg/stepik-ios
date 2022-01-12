import SnapKit
import UIKit

extension ExplorePlaceholderView {
    struct Appearance {
        let titleFont: UIFont
        let titleTextColor: UIColor
        let titleTextAlignment: NSTextAlignment

        let actionButtonHeight: CGFloat = 44

        let insets = LayoutInsets.default
    }
}

final class ExplorePlaceholderView: UIView {
    let appearance: Appearance

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.textAlignment = self.appearance.titleTextAlignment
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton: ExplorePlaceholderActionButton = {
        let button = ExplorePlaceholderActionButton()
        button.addTarget(self, action: #selector(self.actionButtonClicked), for: .touchUpInside)
        return button
    }()

    private var actionButtonWidthToSuperviewConstraint: Constraint?

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var buttonTitle: String? {
        didSet {
            self.actionButton.title = self.buttonTitle
        }
    }

    var buttonImage: UIImage? {
        didSet {
            self.actionButton.image = self.buttonImage

            if self.buttonImage != nil {
                self.actionButtonWidthToSuperviewConstraint?.activate()
            } else {
                self.actionButtonWidthToSuperviewConstraint?.deactivate()
            }
        }
    }

    var onActionButtonClick: (() -> Void)? {
        didSet {
            self.actionButton.isEnabled = self.onActionButtonClick != nil
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.titleLabel.intrinsicContentSize.height
            + self.appearance.insets.top
            + self.appearance.actionButtonHeight
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(frame: CGRect = .zero, appearance: Appearance) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.invalidateIntrinsicContentSize()
    }

    @objc
    private func actionButtonClicked() {
        self.onActionButtonClick?()
    }
}

extension ExplorePlaceholderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.titleLabel)
        self.addSubview(self.actionButton)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
        }

        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.insets.top)
            make.bottom.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.actionButtonHeight)

            self.actionButtonWidthToSuperviewConstraint = make.width.equalToSuperview().constraint
            self.actionButtonWidthToSuperviewConstraint?.deactivate()
        }
    }
}
