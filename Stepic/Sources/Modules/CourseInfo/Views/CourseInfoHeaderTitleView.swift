import SnapKit
import UIKit

extension CourseInfoHeaderTitleView {
    struct Appearance {
        let coverImageViewSize = CGSize(width: 32, height: 32)
        let coverImageViewCornerRadius: CGFloat = 6

        let titleLabelFont = Typography.subheadlineFont
        let titleLabelColor = UIColor.white

        let spacing: CGFloat = 8
    }
}

final class CourseInfoHeaderTitleView: UIView {
    let appearance: Appearance

    private lazy var coverImageView: CourseCoverImageView = {
        let view = CourseCoverImageView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.coverImageViewCornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.numberOfLines = 2
        label.lineBreakMode = .byTruncatingTail
        label.textColor = self.appearance.titleLabelColor
        return label
    }()

    private lazy var containerView = UIView()

    var coverImageURL: URL? {
        didSet {
            self.coverImageView.loadImage(url: self.coverImageURL)
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
            self.invalidateIntrinsicContentSize()
        }
    }

    override var intrinsicContentSize: CGSize {
        let height = max(self.appearance.coverImageViewSize.height, self.titleLabel.intrinsicContentSize.height)
        return CGSize(width: UIView.noIntrinsicMetric, height: height)
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

extension CourseInfoHeaderTitleView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.containerView.addSubview(self.coverImageView)
        self.containerView.addSubview(self.titleLabel)
        self.addSubview(self.containerView)
    }

    func makeConstraints() {
        self.containerView.translatesAutoresizingMaskIntoConstraints = false
        self.containerView.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.leading.greaterThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.titleLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualToSuperview()
            make.leading.equalTo(self.coverImageView.snp.trailing).offset(self.appearance.spacing)
            make.bottom.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalToSuperview()
        }
    }
}
