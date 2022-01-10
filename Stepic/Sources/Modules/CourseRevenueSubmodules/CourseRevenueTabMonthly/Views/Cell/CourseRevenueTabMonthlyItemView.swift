import SnapKit
import UIKit

extension CourseRevenueTabMonthlyItemView {
    struct Appearance {
        let imageViewSize = CGSize(width: 24, height: 24)
        let imageViewInsets = LayoutInsets.default
        let imageViewTintColor = UIColor.stepikMaterialPrimaryText

        let titleFont = Typography.bodyFont
        let titleTextColor = UIColor.stepikMaterialPrimaryText

        let titleLabelInsets = LayoutInsets(left: 8)
        let rightDetailSubtitleLabelInsets = LayoutInsets(left: 8)
    }
}

final class CourseRevenueTabMonthlyItemView: UIView {
    let appearance: Appearance

    private let shouldShowImageView: Bool

    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = self.appearance.imageViewTintColor
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.textAlignment = .left
        label.numberOfLines = 1
        return label
    }()

    private lazy var rightDetailTitleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleFont
        label.textColor = self.appearance.titleTextColor
        label.textAlignment = .right
        label.numberOfLines = 1
        return label
    }()

    var image: UIImage? {
        didSet {
            self.imageView.image = self.image
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var rightDetailTitle: String? {
        didSet {
            self.rightDetailTitleLabel.text = self.rightDetailTitle
        }
    }

    var rightDetailAttributedTitle: NSAttributedString? {
        didSet {
            if let rightDetailAttributedTitle = self.rightDetailAttributedTitle {
                self.rightDetailTitleLabel.attributedText = rightDetailAttributedTitle
            } else {
                self.rightDetailTitleLabel.attributedText = nil
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = max(
            self.appearance.imageViewSize.height,
            self.titleLabel.intrinsicContentSize.height
        )
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
    }

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        shouldShowImageView: Bool
    ) {
        self.appearance = appearance
        self.shouldShowImageView = shouldShowImageView

        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    @available(*, unavailable)
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CourseRevenueTabMonthlyItemView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        if self.shouldShowImageView {
            self.addSubview(self.imageView)
        }

        self.addSubview(self.titleLabel)
        self.addSubview(self.rightDetailTitleLabel)
    }

    func makeConstraints() {
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        self.titleLabel.setContentHuggingPriority(.defaultLow, for: .vertical)

        self.rightDetailTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailTitleLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        self.rightDetailTitleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.rightDetailTitleLabel.snp.makeConstraints { make in
            make.leading
                .greaterThanOrEqualTo(self.titleLabel.snp.trailing)
                .offset(self.appearance.rightDetailSubtitleLabelInsets.left)
            make.trailing.equalToSuperview()
            make.centerY.equalTo(self.titleLabel.snp.centerY)
        }

        if self.shouldShowImageView {
            self.imageView.translatesAutoresizingMaskIntoConstraints = false
            self.imageView.snp.makeConstraints { make in
                make.leading.centerY.equalToSuperview()
                make.size.equalTo(self.appearance.imageViewSize)
            }

            self.titleLabel.snp.makeConstraints { make in
                make.leading.equalTo(self.imageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
                make.centerY.equalTo(self.imageView.snp.centerY)
            }
        } else {
            self.titleLabel.snp.makeConstraints { make in
                make.top.leading.bottom.equalToSuperview()
            }
        }
    }
}
