import SnapKit
import UIKit

extension PlayNextCircleControlView {
    struct Appearance {
        let backgroundColor = UIColor.white.withAlphaComponent(0.5)

        let iconImageTintColor = UIColor.white

        let circleWidth: CGFloat = 10
        let circleProgressColor = UIColor.stepicGreen
        let circleTrackColor = UIColor.white
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

    private var iconImageViewWidthConstraint: Constraint?
    private var iconImageViewHeightConstraint: Constraint?

    private var circleRadius: CGFloat {
        self.bounds.width / 2 - self.appearance.circleWidth
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

        [
            self.backgroundLayer,
            self.trackLayer,
            self.progressLayer
        ].forEach { layer in
            layer.path = self.makeCircularPath().cgPath
            layer.position = self.containerView.center
        }

        self.progressLayer.transform = CATransform3DMakeRotation(-CGFloat.pi / 2, 0, 0, 1)

        self.iconImageViewWidthConstraint?.update(offset: self.circleRadius)
        self.iconImageViewHeightConstraint?.update(offset: self.circleRadius)
    }

    func startCountdown(duration: TimeInterval, completion completionBlock: (() -> Void)? = nil) {
        CATransaction.begin()
        CATransaction.setCompletionBlock(completionBlock)

        let animation = CABasicAnimation(keyPath: AnimationKeyPath.strokeEnd.rawValue)
        animation.toValue = 1
        animation.duration = CFTimeInterval(duration)
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false

        self.stopCountdown()
        self.progressLayer.add(animation, forKey: AnimationKeyPath.progressAnimation.rawValue)

        CATransaction.commit()
    }

    func stopCountdown() {
        self.setProgress(to: 0)
    }

    func completeCountdown() {
        self.setProgress(to: 1)
    }

    private func makeCircularPath() -> UIBezierPath {
        UIBezierPath(
            arcCenter: .zero,
            radius: self.circleRadius,
            startAngle: 0,
            endAngle: 2 * CGFloat.pi,
            clockwise: true
        )
    }

    private func setProgress(to value: CGFloat) {
        self.progressLayer.removeAnimation(forKey: AnimationKeyPath.progressAnimation.rawValue)
        self.progressLayer.strokeEnd = value
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
            self.iconImageViewWidthConstraint = make.width.equalTo(self.circleRadius).constraint
            self.iconImageViewHeightConstraint = make.height.equalTo(self.circleRadius).constraint
        }
    }
}
