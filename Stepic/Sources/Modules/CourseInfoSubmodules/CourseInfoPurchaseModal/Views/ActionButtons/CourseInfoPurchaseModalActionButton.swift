import SnapKit
import UIKit

extension CourseInfoPurchaseModalActionButton {
    struct Appearance {
        let loadingIndicatorInsets = LayoutInsets(left: 16)
        var loadingIndicatorColor: UIColor?

        let textLabelFont = Typography.bodyFont
        var textLabelTextColor = UIColor.white

        var backgroundColor = UIColor.stepikVioletFixed

        var borderWidth: CGFloat = 0
        var borderColor: UIColor?
        let cornerRadius: CGFloat = 8
    }
}

final class CourseInfoPurchaseModalActionButton: UIControl {
    var appearance: Appearance {
        didSet {
            self.updateAppearance()
        }
    }

    private lazy var loadingActivityIndicator: UIActivityIndicatorView = {
        let activityIndicatorView = UIActivityIndicatorView(style: .stepikGray)
        activityIndicatorView.hidesWhenStopped = true
        activityIndicatorView.stopAnimating()
        return activityIndicatorView
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 1
        return label
    }()

    var isLoadingActivityIndicatorVisible = false {
        didSet {
            if self.isLoadingActivityIndicatorVisible {
                self.loadingActivityIndicator.startAnimating()
            } else {
                self.loadingActivityIndicator.stopAnimating()
            }
        }
    }

    var text: String? {
        didSet {
            self.textLabel.text = self.text
        }
    }

    var attributedText: NSAttributedString? {
        didSet {
            self.textLabel.attributedText = self.attributedText
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.alpha = self.isHighlighted ? 0.5 : (self.isEnabled ? 1.0 : 0.5)
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.alpha = self.isEnabled ? 1.0 : 0.5
        }
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

        self.updateAppearance()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.updateBorder()
        }
    }

    private func updateAppearance() {
        if let loadingIndicatorColor = self.appearance.loadingIndicatorColor {
            self.loadingActivityIndicator.color = loadingIndicatorColor
        }

        self.textLabel.font = self.appearance.textLabelFont
        self.textLabel.textColor = self.appearance.textLabelTextColor

        self.backgroundColor = self.appearance.backgroundColor

        self.updateBorder()
    }

    private func updateBorder() {
        self.layer.borderWidth = self.appearance.borderWidth
        self.layer.borderColor = self.appearance.borderColor?.cgColor
    }
}

extension CourseInfoPurchaseModalActionButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true
        self.clipsToBounds = true
    }

    func addSubviews() {
        self.addSubview(self.loadingActivityIndicator)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.loadingActivityIndicator.translatesAutoresizingMaskIntoConstraints = false
        self.loadingActivityIndicator.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.loadingIndicatorInsets.left)
            make.centerY.equalTo(self.textLabel.snp.centerY)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
}
