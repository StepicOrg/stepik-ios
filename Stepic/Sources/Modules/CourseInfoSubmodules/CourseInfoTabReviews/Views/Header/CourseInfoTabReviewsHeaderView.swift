import SnapKit
import UIKit

extension CourseInfoTabReviewsHeaderView {
    struct Appearance {
        let buttonSpacing: CGFloat = 14.0

        let buttonTintColor = UIColor.mainDark
        let buttonFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let buttonImageInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 4)
        let buttonTitleInsets = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 0)
        let buttonImageSize = CGSize(width: 15, height: 15)

        let labelFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let labelTextColor = UIColor.mainDark

        let insets = UIEdgeInsets(top: 0, left: 18, bottom: 0, right: 18)
    }
}

final class CourseInfoTabReviewsHeaderView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = self.appearance.buttonSpacing
        return stackView
    }()

    private lazy var writeReviewButton: ImageButton = {
        let button = ImageButton()
        button.image = UIImage(named: "course-info-reviews-write")?.withRenderingMode(.alwaysTemplate)
        button.tintColor = self.appearance.buttonTintColor
        button.title = NSLocalizedString("WriteCourseReviewActionCreate", comment: "")
        button.font = self.appearance.buttonFont
        button.imageInsets = self.appearance.buttonImageInsets
        button.titleInsets = self.appearance.buttonTitleInsets
        button.imageSize = self.appearance.buttonImageSize
        button.addTarget(self, action: #selector(self.onWriteReviewButtonClicked), for: .touchUpInside)
        button.isHidden = true
        return button
    }()

    private lazy var writeReviewDescriptionLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("WriteCourseReviewActionNotAllowedDescription", comment: "")
        label.font = self.appearance.labelFont
        label.textColor = self.appearance.labelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var separatorView = SeparatorView()

    var shouldShowWriteReviewButton: Bool = false {
        didSet {
            self.writeReviewButton.isHidden = !self.shouldShowWriteReviewButton
            self.writeReviewDescriptionLabel.isHidden = self.shouldShowWriteReviewBanner
        }
    }

    var shouldShowWriteReviewBanner: Bool = true {
        didSet {
            self.writeReviewDescriptionLabel.isHidden = !self.shouldShowWriteReviewBanner
        }
    }

    var writeReviewBannerText: String? {
        didSet {
            self.writeReviewDescriptionLabel.text = self.writeReviewBannerText
        }
    }

    var onWriteReviewButtonClick: (() -> Void)?

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

    @objc
    private func onWriteReviewButtonClicked() {
        self.onWriteReviewButtonClick?()
    }
}

extension CourseInfoTabReviewsHeaderView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.stackView)
        self.addSubview(self.writeReviewDescriptionLabel)
        self.addSubview(self.separatorView)

        self.stackView.addArrangedSubview(self.writeReviewButton)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.insets.right).priority(999)
        }

        self.writeReviewDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        self.writeReviewDescriptionLabel.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.top.equalToSuperview()
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.bottom.equalTo(self.separatorView.snp.top)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.top
                .equalTo(self.stackView.snp.bottom)
                .offset(self.appearance.insets.bottom)
            make.leading.trailing.bottom.equalToSuperview()
            make.height.equalTo(SeparatorView.Appearance().height)
        }
    }
}
