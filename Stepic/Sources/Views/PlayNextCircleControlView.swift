import SnapKit
import UIKit

extension PlayNextCircleControlView {
    struct Appearance {
        let backgroundColor = UIColor.white.withAlphaComponent(0.2)

        let circleWidth: CGFloat = 10
        let circleProgressColor = UIColor.green
        let circleTrackColor = UIColor.lightGray

        let iconImageSize = CGSize(width: 72, height: 72)
        let iconImageTintColor = UIColor.white
    }
}

final class PlayNextCircleControlView: UIControl {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let image = UIImage(named: "play-next")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageTintColor
        imageView.isUserInteractionEnabled = false
        return imageView
    }()

    private lazy var backgroundLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.fillColor = self.appearance.backgroundColor.cgColor
        return layer
    }()

    private lazy var trackLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = self.appearance.circleTrackColor.cgColor
        layer.lineWidth = self.appearance.circleWidth
        layer.fillColor = nil
        layer.lineCap = .round
        return layer
    }()

    private lazy var progressLayer: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.strokeColor = self.appearance.circleProgressColor.cgColor
        layer.lineWidth = self.appearance.circleWidth
        layer.fillColor = nil
        layer.lineCap = .round
        layer.strokeEnd = 0
        return layer
    }()

    private lazy var containerView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = false
        return view
    }()

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

        [
            self.backgroundLayer,
            self.trackLayer,
            self.progressLayer
        ].forEach { layer in
            layer.path = self.makeCircularPath().cgPath
            layer.position = self.containerView.center
        }

        self.progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)
    }

    func startCountdown(duration: TimeInterval, completion completionBlock: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)

        let animation = CABasicAnimation(keyPath: AnimationKeyPath.strokeEnd.rawValue)
        animation.toValue = 1
        animation.duration = CFTimeInterval(duration)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        self.progressLayer.removeAllAnimations()
        self.progressLayer.strokeEnd = 0

        self.progressLayer.add(animation, forKey: AnimationKeyPath.progressAnimation.rawValue)

        CATransaction.commit()
    }

    private func makeCircularPath() -> UIBezierPath {
        UIBezierPath(
            arcCenter: .zero,
            radius: self.bounds.width / 2 - self.appearance.circleWidth,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
    }

    private enum AnimationKeyPath: String {
        case strokeEnd
        case progressAnimation
    }
}

extension PlayNextCircleControlView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.containerView)

        self.containerView.layer.addSublayer(self.backgroundLayer)
        self.containerView.layer.addSublayer(self.trackLayer)
        self.containerView.layer.addSublayer(self.progressLayer)
        self.containerView.addSubview(self.iconImageView)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.appearance.iconImageSize)
        }
    }
}
