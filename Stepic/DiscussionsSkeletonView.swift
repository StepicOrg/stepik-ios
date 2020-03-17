import SnapKit
import UIKit

extension DiscussionsSkeletonView {
    struct Appearance {
        let labelCornerRadius: CGFloat = 5.0

        let avatarImageViewInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        let avatarImageViewSize = CGSize(width: 36, height: 36)
        let avatarImageViewCornerRadius: CGFloat = 4.0

        let badgeViewInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let badgeViewSize = CGSize(width: 80, height: 12)

        let nameLabelHeight: CGFloat = 14.0
        let nameLabelInsets = UIEdgeInsets(top: 8, left: 16, bottom: 8, right: 16)

        let textLabelInsets = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 16)
        let textLabelHeight: CGFloat = 14.0

        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor(hex6: 0xe7e7e7)
    }
}

final class DiscussionsSkeletonView: UIView {
    let appearance: Appearance

    private lazy var avatarView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.avatarImageViewCornerRadius
        return view
    }()

    private lazy var badgeView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.labelCornerRadius
        return view
    }()

    private lazy var nameLabelView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.labelCornerRadius
        return view
    }()

    private lazy var descriptionLabel1View: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.labelCornerRadius
        return view
    }()

    private lazy var descriptionLabel2View: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.labelCornerRadius
        return view
    }()

    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = self.appearance.separatorColor
        return view
    }()

    init(frame: CGRect = .zero, appearance: Appearance = Appearance()) {
        self.appearance = appearance
        super.init(frame: frame)

        self.addSubviews()
        self.makeConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension DiscussionsSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarView)
        self.addSubview(self.badgeView)
        self.addSubview(self.nameLabelView)
        self.addSubview(self.descriptionLabel1View)
        self.addSubview(self.descriptionLabel2View)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.avatarView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.avatarImageViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarImageViewInsets.left)
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.badgeView.translatesAutoresizingMaskIntoConstraints = false
        self.badgeView.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarView.snp.trailing).offset(self.appearance.badgeViewInsets.left)
            make.top.equalTo(self.avatarView.snp.top)
            make.size.equalTo(self.appearance.badgeViewSize)
        }

        self.nameLabelView.translatesAutoresizingMaskIntoConstraints = false
        self.nameLabelView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.nameLabelHeight)
            make.bottom.equalTo(self.avatarView.snp.bottom).priority(999)
            make.leading
                .equalTo(self.avatarView.snp.trailing)
                .offset(self.appearance.nameLabelInsets.left)
            make.width.equalTo(self.snp.width).multipliedBy(0.4)
        }

        self.descriptionLabel1View.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel1View.snp.makeConstraints { make in
            make.leading.equalTo(self.nameLabelView.snp.leading)
            make.top
                .equalTo(self.nameLabelView.snp.bottom)
                .offset(self.appearance.nameLabelInsets.bottom)
            make.height.equalTo(self.appearance.textLabelHeight)
            make.width.equalTo(self.descriptionLabel2View).multipliedBy(0.8)
        }

        self.descriptionLabel2View.translatesAutoresizingMaskIntoConstraints = false
        self.descriptionLabel2View.snp.makeConstraints { make in
            make.leading.equalTo(self.descriptionLabel1View.snp.leading)
            make.top
                .equalTo(self.descriptionLabel1View.snp.bottom)
                .offset(self.appearance.textLabelInsets.top)
            make.trailing.equalToSuperview().offset(-self.appearance.textLabelInsets.right)
            make.bottom
                .equalTo(self.separatorView.snp.top)
                .offset(-self.appearance.textLabelInsets.bottom)
            make.height.equalTo(self.appearance.textLabelHeight)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.height.equalTo(self.appearance.separatorHeight)
            make.leading.bottom.trailing.equalToSuperview()
        }
    }
}
