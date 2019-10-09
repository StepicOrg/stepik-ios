import SnapKit
import UIKit

extension CourseInfoTabReviewsCellView {
    struct Appearance {
        let avatarImageViewInsets = UIEdgeInsets(top: 20, left: 20, bottom: 0, right: 16)
        let avatarImageViewSize = CGSize(width: 30, height: 30)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let starsViewInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 20)

        let dateLabelInsets = UIEdgeInsets(top: 20, left: 16, bottom: 0, right: 16)
        let dateLabelFont = UIFont.systemFont(ofSize: 12, weight: .light)
        let dateLabelTextColor = UIColor.mainDark

        let nameLabelTextColor = UIColor.mainDark
        let nameLabelFont = UIFont.systemFont(ofSize: 14, weight: .medium)
        let nameLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 0, right: 20)

        let textLabelTextColor = UIColor.mainDark
        let textLabelFont = UIFont.systemFont(ofSize: 14, weight: .light)
        let textLabelInsets = UIEdgeInsets(top: 8, left: 0, bottom: 20, right: 20)

        let clearStarsColor = UIColor.mainDark
    }
}

final class CourseInfoTabReviewsCellView: UIView {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView()
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.dateLabelFont
        label.textColor = self.appearance.dateLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.nameLabelFont
        label.textColor = self.appearance.nameLabelTextColor
        label.numberOfLines = 1
        return label
    }()

    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.font = self.appearance.textLabelFont
        label.textColor = self.appearance.textLabelTextColor
        label.numberOfLines = 0
        return label
    }()

    private lazy var starsRatingView: CourseRatingView = {
        var appearance = CourseRatingView.Appearance()
        appearance.statClearColor = self.appearance.clearStarsColor
        let view = CourseRatingView(appearance: appearance)
        return view
    }()

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

    func configure(viewModel: CourseInfoTabReviewsViewModel?) {
        guard let viewModel = viewModel else {
            self.nameLabel.text = nil
            self.starsRatingView.starsCount = 0
            self.dateLabel.text = nil
            self.textLabel.text = nil
            self.avatarImageView.reset()
            return
        }

        self.nameLabel.text = viewModel.userName
        self.dateLabel.text = viewModel.dateRepresentation
        self.textLabel.text = viewModel.text
        self.starsRatingView.starsCount = viewModel.score

        if let url = viewModel.avatarImageURL {
            self.avatarImageView.set(with: url)
        }
    }
}

extension CourseInfoTabReviewsCellView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.dateLabel)
        self.addSubview(self.nameLabel)
        self.addSubview(self.textLabel)
        self.addSubview(self.starsRatingView)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.starsRatingView.translatesAutoresizingMaskIntoConstraints = false
        self.starsRatingView.snp.makeConstraints { make in
            make.centerY.equalTo(self.dateLabel.snp.centerY)
            make.trailing.equalToSuperview().offset(-self.appearance.starsViewInsets.right)
        }

        self.dateLabel.translatesAutoresizingMaskIntoConstraints = false
        self.dateLabel.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.dateLabelInsets.top)
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.dateLabelInsets.left)
            make.trailing
                .lessThanOrEqualTo(self.starsRatingView.snp.leading)
                .offset(-self.appearance.dateLabelInsets.right)
        }

        self.nameLabel.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.nameLabelInsets.left)
            make.top.equalTo(self.starsRatingView.snp.bottom).offset(self.appearance.nameLabelInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.nameLabelInsets.right)
        }

        self.textLabel.snp.makeConstraints { make in
            make.top.equalTo(self.nameLabel.snp.bottom).offset(self.appearance.textLabelInsets.top)
            make.leading.equalTo(self.nameLabel.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.textLabelInsets.right)
            make.bottom.equalToSuperview().offset(-self.appearance.textLabelInsets.bottom)
        }
    }
}
