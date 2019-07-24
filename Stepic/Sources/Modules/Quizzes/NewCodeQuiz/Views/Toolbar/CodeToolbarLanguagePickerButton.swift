import SnapKit
import UIKit

extension CodeToolbarLanguagePickerButton {
    struct Appearance {
        let iconSize = CGSize(width: 16, height: 16)
        let horizontalSpacing: CGFloat = 8

        let mainColor = UIColor.mainDark
        let textFont = UIFont.systemFont(ofSize: 16)
    }

    enum Animation {
        static let iconRotationAnimationDuration: TimeInterval = 0.33
    }
}

final class CodeToolbarLanguagePickerButton: UIControl {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textFont
        label.textColor = self.appearance.mainColor
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "code-quiz-arrow-down")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.mainColor
        return view
    }()

    private var currentRotationAngle: CGFloat = 0

    override var isHighlighted: Bool {
        didSet {
            self.textLabel.alpha = self.isHighlighted ? 0.5 : 1.0
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    override var isEnabled: Bool {
        didSet {
            self.textLabel.alpha = self.isEnabled ? 1.0 : 0.5
            self.imageView.alpha = self.isEnabled ? 1.0 : 0.5
        }
    }

    var language: String? {
        didSet {
            self.textLabel.text = self.language
        }
    }

    var isExpanded: Bool {
        return self.currentRotationAngle != 0
    }

    var isCollapsed: Bool {
        return self.currentRotationAngle == 0
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

    func expand() {
        self.currentRotationAngle = CGFloat(Double.pi)
        self.rotateImageViewWithAnimation()
    }

    func collapse() {
        self.currentRotationAngle = 0
        self.rotateImageViewWithAnimation()
    }

    private func rotateImageViewWithAnimation() {
        self.imageView.layer.removeAllAnimations()
        UIView.animate(withDuration: Animation.iconRotationAnimationDuration) {
            self.imageView.transform = CGAffineTransform(rotationAngle: self.currentRotationAngle)
        }
    }

    @objc
    private func onClick() {
        if self.isCollapsed {
            self.expand()
        } else {
            self.collapse()
        }
    }
}

extension CodeToolbarLanguagePickerButton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.addTarget(self, action: #selector(self.onClick), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        self.textLabel.snp.makeConstraints { make in
            make.leading.top.bottom.equalToSuperview()
        }

        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.setContentCompressionResistancePriority(.defaultHigh, for: .horizontal)
        self.imageView.snp.makeConstraints { make in
            make.leading.equalTo(self.textLabel.snp.trailing).offset(self.appearance.horizontalSpacing)
            make.trailing.equalToSuperview()
            make.centerY.equalToSuperview()
            make.width.equalTo(self.appearance.iconSize.width)
            make.height.equalTo(self.appearance.iconSize.height)
        }
    }
}
