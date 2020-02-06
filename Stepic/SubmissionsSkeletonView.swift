import SnapKit
import UIKit

extension SubmissionsSkeletonView {
    struct Appearance {
        let cornerRadius: CGFloat = 5.0

        let avatarInsets = UIEdgeInsets(top: 16, left: 16, bottom: 0, right: 0)
        let avatarSize = CGSize(width: 36, height: 36)
        let avatarCornerRadius: CGFloat = 4.0

        let usernameInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
        let usernameSize = CGSize(width: 80, height: 17)

        let submissionHeight: CGFloat = 40
        let submissionInsets = UIEdgeInsets(top: 8, left: 0, bottom: 8, right: 16)

        let dateInsets = UIEdgeInsets(top: 8, left: 0, bottom: 16, right: 16)
        let dateHeight: CGFloat = 14

        let separatorHeight: CGFloat = 0.5
        let separatorColor = UIColor(hex: 0xe7e7e7)
        let separatorInsets = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 0)
    }
}

final class SubmissionsSkeletonView: UIView {
    let appearance: Appearance

    private lazy var avatarView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.avatarCornerRadius
        return view
    }()

    private lazy var usernameView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
        return view
    }()

    private lazy var submissionView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
        return view
    }()

    private lazy var dateView: UIView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = self.appearance.cornerRadius
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

extension SubmissionsSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.avatarView)
        self.addSubview(self.usernameView)
        self.addSubview(self.submissionView)
        self.addSubview(self.dateView)
        self.addSubview(self.separatorView)
    }

    func makeConstraints() {
        self.avatarView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.avatarInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarInsets.left)
            make.size.equalTo(self.appearance.avatarSize)
        }

        self.usernameView.translatesAutoresizingMaskIntoConstraints = false
        self.usernameView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.top)
            make.leading.equalTo(self.avatarView.snp.trailing).offset(self.appearance.usernameInsets.left)
            make.width.equalToSuperview().multipliedBy(0.4)
            make.height.equalTo(self.appearance.usernameSize.height)
        }

        self.submissionView.translatesAutoresizingMaskIntoConstraints = false
        self.submissionView.snp.makeConstraints { make in
            make.leading.equalTo(self.usernameView.snp.leading)
            make.top.equalTo(self.usernameView.snp.bottom).offset(self.appearance.submissionInsets.bottom)
            make.trailing.equalToSuperview().offset(-self.appearance.submissionInsets.right)
            make.height.equalTo(self.appearance.submissionHeight)
        }

        self.dateView.translatesAutoresizingMaskIntoConstraints = false
        self.dateView.snp.makeConstraints { make in
            make.top.equalTo(self.submissionView.snp.bottom).offset(self.appearance.dateInsets.top)
            make.leading.equalTo(self.submissionView.snp.leading)
            make.bottom.equalTo(self.separatorView.snp.top).offset(-self.appearance.dateInsets.bottom)
            make.width.equalToSuperview().multipliedBy(0.3)
            make.height.equalTo(self.appearance.dateHeight)
        }

        self.separatorView.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.separatorInsets.left)
            make.bottom.trailing.equalToSuperview().priority(999)
            make.height.equalTo(self.appearance.separatorHeight)
        }
    }
}
