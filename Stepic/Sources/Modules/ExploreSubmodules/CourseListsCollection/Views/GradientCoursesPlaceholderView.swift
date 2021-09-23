import SnapKit
import UIKit

extension GradientCoursesPlaceholderView {
    struct Appearance {
        var titleFont = UIFont.systemFont(ofSize: 16)
        var subtitleFont = UIFont.systemFont(ofSize: 16)

        var titleTextAlignment = NSTextAlignment.natural
        var subtitleTextAlignment = NSTextAlignment.center

        var labelsSpacing: CGFloat = 9.0

        var labelsInsets = UIEdgeInsets(top: 20, left: 28, bottom: 20, right: 30)

        init() {}
    }
}

final class GradientCoursesPlaceholderView: UIView {
    let appearance: Appearance
    private var color: Color

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        return stackView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textAlignment = self.appearance.titleTextAlignment
        label.textColor = self.color.titleTextColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.subtitleFont
        label.textAlignment = self.appearance.subtitleTextAlignment
        label.textColor = self.color.subtitleTextColor
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.setContentCompressionResistancePriority(.required, for: .vertical)
        return label
    }()

    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView(image: self.color.backgroundImage)
        return imageView
    }()

    private var currentIntrinsicContentSize = CGSize(width: UIView.noIntrinsicMetric, height: UIView.noIntrinsicMetric)

    private var stackViewTopConstraint: Constraint?

    var topContentInset: CGFloat = 0 {
        didSet {
            guard oldValue != self.topContentInset else {
                return
            }

            self.stackViewTopConstraint?.update(offset: self.topContentInset)
            self.invalidateIntrinsicContentSize()
        }
    }

    var titleText: NSAttributedString? {
        didSet {
            self.titleLabel.attributedText = self.titleText
            self.invalidateIntrinsicContentSize()
        }
    }

    var subtitleText: NSAttributedString? {
        didSet {
            if (self.subtitleText?.length ?? 0) == 0 {
                self.stackView.spacing = 0
                self.subtitleLabel.isHidden = true
            } else {
                self.stackView.spacing = self.appearance.labelsSpacing
                self.subtitleLabel.isHidden = false
                self.subtitleLabel.attributedText = self.subtitleText
            }

            self.invalidateIntrinsicContentSize()
        }
    }

    var onIntrinsicContentSizeChange: ((CGSize) -> Void)?

    override var intrinsicContentSize: CGSize {
        let stackViewIntrinsicContentSize = self.stackView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)

        let newHeight = (
            self.topContentInset.isZero ? self.appearance.labelsInsets.top : self.topContentInset
                + stackViewIntrinsicContentSize.height
                + self.appearance.labelsInsets.bottom
        ).rounded(.up)

        let newIntrinsicContentSize = CGSize(width: UIView.noIntrinsicMetric, height: newHeight)

        if self.currentIntrinsicContentSize != newIntrinsicContentSize {
            self.currentIntrinsicContentSize = newIntrinsicContentSize
            self.onIntrinsicContentSizeChange?(newIntrinsicContentSize)
        }

        return newIntrinsicContentSize
    }

    init(frame: CGRect = .zero, color: Color, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        self.color = color
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

    enum Color: CaseIterable {
        case purple
        case blue
        case pink

        var backgroundImage: UIImage? {
            switch self {
            case .purple:
                return UIImage(named: "placeholder_gradient_purple")
            case .blue:
                return UIImage(named: "placeholder_gradient_blue")
            case .pink:
                return UIImage(named: "placeholder_gradient_pink")
            }
        }

        var titleTextColor: UIColor {
            switch self {
            case .purple:
                return .white
            case .blue:
                return .stepikGradientCoursesBluePlaceholderText
            case .pink:
                return .stepikGradientCoursesPinkPlaceholderText
            }
        }

        var subtitleTextColor: UIColor {
            switch self {
            case .purple:
                return .white.withAlphaComponent(0.6)
            case .blue, .pink:
                return .dynamic(light: .black.withAlphaComponent(0.6), dark: .white.withAlphaComponent(0.6))
            }
        }
    }
}

extension GradientCoursesPlaceholderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.backgroundImageView)
        self.addSubview(self.stackView)
        self.stackView.addArrangedSubview(self.titleLabel)
        self.stackView.addArrangedSubview(self.subtitleLabel)
    }

    func makeConstraints() {
        self.backgroundImageView.translatesAutoresizingMaskIntoConstraints = false
        self.backgroundImageView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            self.stackViewTopConstraint = make.top
                .equalToSuperview()
                .offset(self.appearance.labelsInsets.top)
                .constraint
            make.leading.bottom.trailing.equalToSuperview().inset(self.appearance.labelsInsets)
        }
    }
}
