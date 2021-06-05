import SnapKit
import UIKit

protocol UserCoursesReviewsWidgetViewDelegate: AnyObject {
    func userCoursesReviewsWidgetViewDidClick(_ view: UserCoursesReviewsWidgetView)
}

extension UserCoursesReviewsWidgetView {
    struct Appearance {
        let backgroundColor = UIColor.dynamic(light: .white, dark: .stepikSecondaryBackground)
        let cornerRadius: CGFloat = 13.0

        let shadowColor = UIColor.black
        let shadowOffset = CGSize(width: 0, height: 1)
        let shadowRadius: CGFloat = 4.0
        let shadowOpacity: Float = 0.1

        let imageViewSize = CGSize(width: 24, height: 16)
        let imageViewInsets = LayoutInsets(top: 16, left: 16)

        let titleTextColor = UIColor.stepikMaterialPrimaryText
        let titleFont = UIFont.systemFont(ofSize: 16, weight: .medium)
        let titleInsets = LayoutInsets(top: 8, right: 16)

        let subtitleTextColor = UIColor.stepikMaterialSecondaryText
        let subtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let subtitleInsets = LayoutInsets(top: 8)

        let accentSubtitleTextColor = UIColor.stepikGreenFixed
        let accentSubtitleFont = UIFont.systemFont(ofSize: 14, weight: .regular)
        let accentSubtitleInsets = LayoutInsets(left: 4, right: 16)

        let accentIndicatorViewBackgroundColor = UIColor.stepikGreenFixed
        let accentIndicatorViewSize = CGSize(width: 10, height: 10)
        let accentIndicatorViewCornerRadius: CGFloat = 5
        let accentIndicatorViewInsets = LayoutInsets(top: 16, right: 16)

        let skeletonViewHeight: CGFloat = 8
        let skeletonViewInsets = LayoutInsets(top: 16)
    }
}

final class UserCoursesReviewsWidgetView: UIView {
    let appearance: Appearance

    weak var delegate: UserCoursesReviewsWidgetViewDelegate?

    private lazy var imageView: UIImageView = {
        let image = UIImage(named: "user-courses-reviews-block-stars")
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = NSLocalizedString("UserCoursesReviewsBlockTitle", comment: "")
        label.textColor = self.appearance.titleTextColor
        label.font = self.appearance.titleFont
        label.numberOfLines = 1
        label.textAlignment = .left
        return label
    }()

    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.subtitleTextColor
        label.font = self.appearance.subtitleFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var accentSubtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.appearance.accentSubtitleTextColor
        label.font = self.appearance.accentSubtitleFont
        label.numberOfLines = 1
        return label
    }()

    private lazy var accentIndicatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.accentIndicatorViewBackgroundColor
        view.isHidden = true
        view.setRoundedCorners(cornerRadius: self.appearance.accentIndicatorViewCornerRadius)
        return view
    }()

    private lazy var overlayButton: UIButton = {
        let button = HighlightFakeButton()
        button.addTarget(self, action: #selector(self.overlayButtonClicked), for: .touchUpInside)
        return button
    }()

    private lazy var skeletonFakeView: UIView = {
        let view = UIView()
        view.isHidden = true
        return view
    }()

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

    override func layoutSubviews() {
        super.layoutSubviews()

        self.backgroundColor = self.appearance.backgroundColor
        self.layer.cornerRadius = self.appearance.cornerRadius
        self.layer.masksToBounds = true

        self.layer.shadowColor = self.appearance.shadowColor.cgColor
        self.layer.shadowOffset = self.appearance.shadowOffset
        self.layer.shadowRadius = self.appearance.shadowRadius
        self.layer.shadowOpacity = self.appearance.shadowOpacity
        self.layer.masksToBounds = false
        self.layer.shadowPath = UIBezierPath(
            roundedRect: self.bounds,
            cornerRadius: self.layer.cornerRadius
        ).cgPath
    }

    func showLoading() {
        [self.subtitleLabel, self.accentSubtitleLabel, self.accentIndicatorView].forEach { $0.alpha = 0 }
        self.overlayButton.isUserInteractionEnabled = false

        self.skeletonFakeView.isHidden = false
        self.skeletonFakeView.skeleton.viewBuilder = {
            UserCoursesReviewsBlockSkeletonView()
        }
        self.skeletonFakeView.skeleton.show()
    }

    func hideLoading() {
        self.skeletonFakeView.skeleton.hide()
        self.skeletonFakeView.isHidden = true

        [self.subtitleLabel, self.accentSubtitleLabel, self.accentIndicatorView].forEach { $0.alpha = 1 }
        self.overlayButton.isUserInteractionEnabled = true
    }

    func configure(viewModel: UserCoursesReviewsWidgetViewModel) {
        self.subtitleLabel.text = viewModel.formattedLeavedCourseReviewsCount
        self.accentSubtitleLabel.text = viewModel.formattedPossibleReviewsCount
        self.accentIndicatorView.isHidden = viewModel.formattedPossibleReviewsCount?.trimmed().isEmpty ?? true
    }

    @objc
    private func overlayButtonClicked() {
        self.delegate?.userCoursesReviewsWidgetViewDidClick(self)
    }
}

extension UserCoursesReviewsWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.imageView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.accentIndicatorView)
        self.addSubview(self.subtitleLabel)
        self.addSubview(self.accentSubtitleLabel)
        self.addSubview(self.skeletonFakeView)
        self.addSubview(self.overlayButton)
    }

    func makeConstraints() {
        self.imageView.translatesAutoresizingMaskIntoConstraints = false
        self.imageView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.imageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.imageViewInsets.left)
            make.size.equalTo(self.appearance.imageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.imageView.snp.bottom).offset(self.appearance.titleInsets.top)
            make.leading.equalTo(self.imageView.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.titleInsets.right)
        }

        self.accentIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        self.accentIndicatorView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.accentIndicatorViewInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.accentIndicatorViewInsets.right)
            make.size.equalTo(self.appearance.accentIndicatorViewSize)
        }

        self.subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.subtitleInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
        }

        self.accentSubtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.accentSubtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleLabel.snp.top)
            make.leading.equalTo(self.subtitleLabel.snp.trailing).offset(self.appearance.accentSubtitleInsets.left)
            make.trailing.lessThanOrEqualToSuperview().offset(-self.appearance.accentSubtitleInsets.right)
        }

        self.skeletonFakeView.translatesAutoresizingMaskIntoConstraints = false
        self.skeletonFakeView.snp.makeConstraints { make in
            make.top.equalTo(self.titleLabel.snp.bottom).offset(self.appearance.skeletonViewInsets.top)
            make.leading.equalTo(self.titleLabel.snp.leading)
            make.width.equalToSuperview().multipliedBy(0.33)
            make.height.equalTo(self.appearance.skeletonViewHeight)
        }

        self.overlayButton.translatesAutoresizingMaskIntoConstraints = false
        self.overlayButton.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
}
