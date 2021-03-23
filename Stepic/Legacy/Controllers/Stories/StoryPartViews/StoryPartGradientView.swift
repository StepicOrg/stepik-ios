import SnapKit
import UIKit

extension StoryPartGradientView {
    struct Appearance {
        let gradientColors = [UIColor.black.withAlphaComponent(0.87), UIColor.clear]
    }
}

final class StoryPartGradientView: UIView {
    let appearance: Appearance

    private lazy var topGradientLayer = CAGradientLayer(colors: self.appearance.gradientColors, rotationAngle: 0)

    private lazy var bottomGradientLayer: CAGradientLayer = {
        let layer = CAGradientLayer(colors: self.appearance.gradientColors, rotationAngle: 0)
        layer.startPoint = CGPoint(x: 0.5, y: 1.0)
        layer.endPoint = CGPoint(x: 0.5, y: 0.0)
        return layer
    }()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.setupView()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        self.topGradientLayer.frame = CGRect(
            x: 0,
            y: 0,
            width: self.frame.width,
            height: self.frame.height / 2
        )

        self.bottomGradientLayer.frame = CGRect(
            x: 0,
            y: self.center.y,
            width: self.frame.width,
            height: self.frame.height / 2
        )
    }
}

extension StoryPartGradientView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.layer.addSublayer(self.topGradientLayer)
        self.layer.addSublayer(self.bottomGradientLayer)
    }
}
