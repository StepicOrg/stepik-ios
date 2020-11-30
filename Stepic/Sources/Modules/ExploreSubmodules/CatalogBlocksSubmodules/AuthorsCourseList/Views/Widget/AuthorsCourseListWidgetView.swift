import SnapKit
import UIKit

extension AuthorsCourseListWidgetView {
    struct Appearance {
        let coverViewWidthHeight: CGFloat = 64
        let coverViewInsets = LayoutInsets(top: 16, left: 16)

        let titleLabelFont = Typography.subheadlineFont
        let titleLabelTextColor = UIColor.stepikSystemPrimaryText
        let titleLabelInsets = LayoutInsets(left: 16, right: 16)

        let createdCoursesRatingViewImage = UIImage(named: "authors-course-list-created-courses")
        let followersRatingViewImage = UIImage(named: "authors-course-list-followers-count")
        let ratingsSpacing: CGFloat = 8
        let ratingsInsets = LayoutInsets(bottom: 16)
    }
}

final class AuthorsCourseListWidgetView: UIView {
    let appearance: Appearance

    private lazy var coverView = AuthorsCourseListWidgetCoverView()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.titleLabelFont
        label.textColor = self.appearance.titleLabelTextColor
        label.numberOfLines = 2
        return label
    }()

    private lazy var createdCoursesRatingView: AuthorsCourseListWidgetRatingView = {
        let view = AuthorsCourseListWidgetRatingView()
        view.image = self.appearance.createdCoursesRatingViewImage?.withRenderingMode(.alwaysTemplate)
        return view
    }()

    private lazy var followersRatingView: AuthorsCourseListWidgetRatingView = {
        let view = AuthorsCourseListWidgetRatingView()
        view.image = self.appearance.followersRatingViewImage?.withRenderingMode(.alwaysTemplate)
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

    func configure(viewModel: AuthorsCourseListWidgetViewModel) {
        self.coverView.coverImageURL = viewModel.avatarURL
        self.titleLabel.text = viewModel.title
        self.createdCoursesRatingView.text = viewModel.formattedCreatedCoursesCountString
        self.followersRatingView.text = viewModel.formattedFollowersCountString
    }
}

extension AuthorsCourseListWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleLabel)
        self.addSubview(self.createdCoursesRatingView)
        self.addSubview(self.followersRatingView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.coverViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.coverViewInsets.left)
            make.width.height.equalTo(self.appearance.coverViewWidthHeight)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.top.equalTo(self.coverView.snp.top)
            make.leading.equalTo(self.coverView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.titleLabelInsets.right)
        }

        if DeviceInfo.current.isSmallDiagonal {
            self.createdCoursesRatingView.translatesAutoresizingMaskIntoConstraints = false
            self.createdCoursesRatingView.snp.makeConstraints { make in
                make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.ratingsSpacing)
                make.leading.equalTo(self.titleLabel.snp.leading)
                make.trailing.equalTo(self.titleLabel.snp.trailing)
            }

            self.followersRatingView.translatesAutoresizingMaskIntoConstraints = false
            self.followersRatingView.snp.makeConstraints { make in
                make.top.equalTo(self.createdCoursesRatingView.snp.bottom).offset(self.appearance.ratingsSpacing)
                make.leading.equalTo(self.titleLabel.snp.leading)
                make.bottom.equalToSuperview().offset(-self.appearance.ratingsInsets.bottom)
                make.trailing.equalTo(self.titleLabel.snp.trailing)
            }
        } else {
            self.createdCoursesRatingView.translatesAutoresizingMaskIntoConstraints = false
            self.createdCoursesRatingView.snp.makeConstraints { make in
                make.top.greaterThanOrEqualTo(self.titleLabel.snp.bottom).offset(self.appearance.ratingsSpacing)
                make.leading.equalTo(self.titleLabel.snp.leading)
                make.bottom.equalToSuperview().offset(-self.appearance.ratingsInsets.bottom)
            }

            self.followersRatingView.translatesAutoresizingMaskIntoConstraints = false
            self.followersRatingView.snp.makeConstraints { make in
                make.leading.equalTo(self.createdCoursesRatingView.snp.trailing).offset(self.appearance.ratingsSpacing)
                make.bottom.equalToSuperview().offset(-self.appearance.ratingsInsets.bottom)
                make.trailing.lessThanOrEqualTo(self.titleLabel.snp.trailing)
            }
        }
    }
}
