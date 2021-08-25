import SnapKit
import UIKit

extension SubmissionsSelectionView {
    struct Appearance {
        let separatorHeight: CGFloat = 1
        let separatorColor = UIColor.onSurface.withAlphaComponent(0.04)

        let titleFont = Typography.bodyFont
        let titleTextColor = UIColor.stepikVioletFixed
        let titleInsets = LayoutInsets.default

        let detailDisclosureImageTintColor = UIColor.stepikMaterialSecondaryText
        let detailDisclosureImageSize = CGSize(width: 14, height: 14)
        let detailDisclosureImageInsets = LayoutInsets(right: 16)
    }
}

final class SubmissionsSelectionView: UIControl {
    let appearance: Appearance

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.numberOfLines = 1
        label.textAlignment = .left
        label.text = NSLocalizedString("SubmissionsSelectSubmission", comment: "")
        return label
    }()

    private lazy var detailDisclosureImageView: UIImageView = {
        let image = UIImage(named: "chevron.right")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = self.appearance.detailDisclosureImageTintColor
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    override var isHighlighted: Bool {
        didSet {
            [self.titleLabel, self.detailDisclosureImageView].forEach { view in
                view.alpha = self.isHighlighted ? 0.5 : 1.0
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = self.appearance.separatorHeight
            + self.appearance.titleInsets.top
            + max(self.titleLabel.intrinsicContentSize.height, self.appearance.detailDisclosureImageSize.height)
            + self.appearance.titleInsets.bottom
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance()
    ) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SubmissionsSelectionView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.separatorView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.detailDisclosureImageView)
    }

    func makeConstraints() {
        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView.snp.bottom).offset(self.appearance.titleInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.titleInsets.left)
            make.trailing.equalTo(self.detailDisclosureImageView.snp.leading).offset(-self.appearance.titleInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.titleInsets.bottom)
        }

        self.detailDisclosureImageView.translatesAutoresizingMaskIntoConstraints = false
        self.detailDisclosureImageView.snp.makeConstraints { make in
            make.centerY.equalTo(self.titleLabel.snp.centerY)
            make.size.equalTo(self.appearance.detailDisclosureImageSize)
            make.trailing.equalToSuperview().offset(-self.appearance.detailDisclosureImageInsets.right)
        }
    }
}
