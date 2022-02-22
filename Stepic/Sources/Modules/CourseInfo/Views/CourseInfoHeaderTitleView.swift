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

    private var containerViewWidthConstraint: Constraint?

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
        let coverImageViewWidthWithSpacing = self.appearance.coverImageViewSize.width + self.appearance.spacing

        let superviewSize = self.superview?.bounds.size ?? .zero
        let specifiedSize = CGSize(
            width: max(0, superviewSize.width - coverImageViewWidthWithSpacing),
            height: CGFloat.greatestFiniteMagnitude
        )

        let titleBestFitsSize = self.titleLabel.sizeThatFits(specifiedSize)

        let width = ceil(coverImageViewWidthWithSpacing + titleBestFitsSize.width)
        let height = ceil(max(self.appearance.coverImageViewSize.height, titleBestFitsSize.height))

        self.containerViewWidthConstraint?.update(offset: width)

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
            make.top.bottom.centerX.equalToSuperview()
            self.containerViewWidthConstraint = make.width.equalTo(0).constraint
        }

        self.coverImageView.translatesAutoresizingMaskIntoConstraints = false
        self.coverImageView.snp.makeConstraints { make in
            make.leading.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.coverImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.coverImageView.snp.trailing).offset(self.appearance.spacing)
            make.trailing.centerY.equalToSuperview()
        }
    }
}
