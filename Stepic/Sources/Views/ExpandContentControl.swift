import SnapKit
import UIKit

extension ExpandContentControl {
    struct Appearance {
        let iconColor = UIColor.stepikMaterialSecondaryText
    }

    enum Animation {
        static let iconRotationAnimationDuration: TimeInterval = 0.33
    }
}

final class ExpandContentControl: UIControl {
    let appearance: Appearance

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "code-quiz-arrow-down")
        let view = UIImageView(image: image?.withRenderingMode(.alwaysTemplate))
        view.contentMode = .scaleAspectFit
        view.tintColor = self.appearance.iconColor
        return view
    }()

    private var currentRotationAngle: CGFloat = 0

    var onClick: (() -> Void)?

    override var isHighlighted: Bool {
        didSet {
            self.imageView.alpha = self.isHighlighted ? 0.5 : 1.0
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
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc
    private func handleTouchUpInside() {
        self.rotateImageView()
        self.onClick?()
    }

    private func rotateImageView() {
        self.imageView.layer.removeAllAnimations()
        UIView.animate(withDuration: Animation.iconRotationAnimationDuration) {
            if self.currentRotationAngle == 0 {
                self.currentRotationAngle = CGFloat(Double.pi)
                self.imageView.transform = CGAffineTransform(rotationAngle: self.currentRotationAngle)
            } else {
                self.currentRotationAngle = 0
                self.imageView.transform = .identity
            }
        }
    }
}

extension ExpandContentControl: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.addTarget(self, action: #selector(self.handleTouchUpInside), for: .touchUpInside)
    }

    func addSubviews() {
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }
}
