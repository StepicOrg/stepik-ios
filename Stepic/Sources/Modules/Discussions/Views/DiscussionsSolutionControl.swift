import SnapKit
import UIKit

extension DiscussionsSolutionControl {
    struct Appearance {
        static let height: CGFloat = 40

        let cornerRadius: CGFloat = 6
        let borderWidth: CGFloat = 1
        let borderColor = UIColor(hex6: 0xCCCCCC)
        var isBorderEnabled = true

        let iconInsets = LayoutInsets(top: 8, left: 8, bottom: 8, right: 8)

        let titleTextColor = UIColor.stepikAccent
        let titleFont = UIFont.systemFont(ofSize: 14)
        let titleInsets = LayoutInsets(top: 8, left: 8, bottom: 8, right: 8)
    }
}

final class DiscussionsSolutionControl: UIControl {
    let appearance: Appearance

    private lazy var borderLayer: CAShapeLayer = {
        let borderLayer = CAShapeLayer()
        borderLayer.lineWidth = self.appearance.borderWidth
        borderLayer.strokeColor = self.appearance.borderColor.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        return borderLayer
    }()

    private lazy var imageView = UIImageView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 1
        return label
    }()

    override var isHighlighted: Bool {
        didSet {
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
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

    override func layoutSubviews() {
        super.layoutSubviews()

        DispatchQueue.main.async {
            self.updateCorners()
        }
    }

    func update(state: SolutionState, title: String?) {
        self.imageView.image = state.icon?.withRenderingMode(.alwaysTemplate)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.tintColor = state.tintColor

        self.titleLabel.text = title
    }

    private func updateCorners() {
        guard self.appearance.isBorderEnabled else {
            return
        }

        let path = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: self.appearance.cornerRadius, height: self.appearance.cornerRadius)
        )
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        self.layer.mask = mask

        let borderPath = UIBezierPath(
            roundedRect: self.bounds,
            byRoundingCorners: .allCorners,
            cornerRadii: CGSize(width: self.appearance.cornerRadius, height: self.appearance.cornerRadius)
        )
        self.borderLayer.path = borderPath.cgPath
        self.borderLayer.frame = self.bounds
    }

    // MARK: Types

    enum SolutionState {
        case correct
        case wrong

        var tintColor: UIColor {
            switch self {
            case .correct:
                return UIColor(hex6: 0x66CC66)
            case .wrong:
                return UIColor(hex6: 0xFF7965)
            }
        }

        var icon: UIImage? {
            switch self {
            case .correct:
                return UIImage(named: "quiz-mark-correct")
            case .wrong:
                return UIImage(named: "quiz-mark-wrong")
            }
        }
    }
}

extension DiscussionsSolutionControl: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        if self.appearance.isBorderEnabled {
            self.layer.addSublayer(self.borderLayer)
        }
    }

    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.iconInsets.left)
            make.trailing.equalTo(self.titleLabel.snp.leading).offset(-self.appearance.iconInsets.right)
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        self.titleLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.top.greaterThanOrEqualToSuperview().offset(self.appearance.titleInsets.top)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.titleInsets.bottom)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.titleInsets.right)
        }
    }
}
