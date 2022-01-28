import SnapKit
import UIKit

extension CourseWidgetProgressCertificateThresholdPointView {
    struct Appearance {
        let iconImageViewSize = CGSize(width: 6, height: 6)
        let iconImageViewTintColor = UIColor.white

        let regularSize = CGSize(width: 6, height: 6)
        let doneSize = CGSize(width: 10, height: 10)

        var backgroundColor = UIColor.stepikGreenFixed
    }
}

final class CourseWidgetProgressCertificateThresholdPointView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "course-info-news-badge-correct")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageViewTintColor
        return imageView
    }()

    var isDone = false {
        didSet {
            self.updateAppearance()

            if oldValue != self.isDone {
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        self.isDone ? self.appearance.doneSize : self.appearance.regularSize
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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.clipsToBounds = true
        self.layer.cornerRadius = self.bounds.height / 2
    }

    private func updateAppearance() {
        self.iconImageView.isHidden = !self.isDone
        self.invalidateIntrinsicContentSize()
    }
}

extension CourseWidgetProgressCertificateThresholdPointView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.size.equalTo(self.appearance.iconImageViewSize)
        }
    }
}
