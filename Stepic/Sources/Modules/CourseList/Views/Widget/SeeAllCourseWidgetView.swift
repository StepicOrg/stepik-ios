import SnapKit
import UIKit

extension SeeAllCourseWidgetView {
    struct Appearance {
        let tintColor: UIColor
        let font = Typography.bodyFont
        let textLabelInsets = LayoutInsets(right: 8)
        let imageViewSize = CGSize(width: 24, height: 24)
    }
}

final class SeeAllCourseWidgetView: UIView {
    let appearance: Appearance

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.font
        label.textColor = self.tintColor
        label.numberOfLines = 1
        label.text = NSLocalizedString("CourseWidgetSeeAllTitle", comment: "")
        return label
    }()

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "arrow.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.tintColor
        return imageView
    }()

    override var intrinsicContentSize: CGSize {
        let textLabelIntrinsicContentSize = self.textLabel.intrinsicContentSize

        let width = textLabelIntrinsicContentSize.width
            + self.appearance.textLabelInsets.right
            + self.appearance.imageViewSize.width
        let height = max(textLabelIntrinsicContentSize.height, self.appearance.imageViewSize.height)

        return CGSize(width: width, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.tintColor = appearance.tintColor

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SeeAllCourseWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.textLabel)
        self.addSubview(self.imageView)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.trailing.centerY.equalToSuperview()

            make.width.equalTo(self.appearance.imageViewSize.width)
            make.height.equalTo(self.appearance.imageViewSize.height)
        }

        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalTo(self.imageView.snp.leading).offset(-self.appearance.textLabelInsets.right)
            make.centerY.equalTo(self.imageView.snp.centerY)
        }
    }
}
