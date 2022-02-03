import SnapKit
import UIKit

extension CourseWidgetProgressCertificateThresholdValueView {
    struct Appearance {
        var iconImageViewTintColor = UIColor.stepikGreenFixed
        let iconImageViewSize = CGSize(width: 8, height: 8)
        let iconImageViewInsets = LayoutInsets(left: 4)

        var textLabelAppearance = CourseWidgetLabel.Appearance()
        let textLabelInsets = LayoutInsets(top: 1, left: 2, bottom: 1, right: 4)

        var backgroundColor = UIColor.stepikGreenFixed.withAlphaComponent(0.12)
        let cornerRadius: CGFloat = 6
    }
}

final class CourseWidgetProgressCertificateThresholdValueView: UIView {
    let appearance: Appearance

    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView(
            image: UIImage(named: "course-info-certificate")?.withRenderingMode(.alwaysTemplate)
        )
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.iconImageViewTintColor
        return imageView
    }()

    private lazy var textLabel = CourseWidgetLabel(appearance: self.appearance.textLabelAppearance)

    var text: String? {
        didSet {
            self.textLabel.text = self.text
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let width = self.appearance.iconImageViewInsets.left
            + self.appearance.iconImageViewSize.width
            + self.appearance.textLabelInsets.left
            + self.textLabel.intrinsicContentSize.width
            + self.appearance.textLabelInsets.right
        let height = self.appearance.textLabelInsets.top
            + self.textLabel.intrinsicContentSize.height
            + self.appearance.textLabelInsets.bottom
        return CGSize(width: width, height: height)
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
}

extension CourseWidgetProgressCertificateThresholdValueView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor

        self.clipsToBounds = true
        self.layer.cornerRadius = self.appearance.cornerRadius
    }

    func addSubviews() {
        self.addSubview(self.iconImageView)
        self.addSubview(self.textLabel)
    }

    func makeConstraints() {
        self.iconImageView.translatesAutoresizingMaskIntoConstraints = false
        self.iconImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.iconImageViewInsets.left)
            make.centerY.equalTo(self.textLabel.snp.centerY)
            make.size.equalTo(self.appearance.iconImageViewSize)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.top.trailing.bottom.equalToSuperview().inset(self.appearance.textLabelInsets.edgeInsets)
            make.leading.equalTo(self.iconImageView.snp.trailing).offset(self.appearance.textLabelInsets.left)
        }
    }
}
