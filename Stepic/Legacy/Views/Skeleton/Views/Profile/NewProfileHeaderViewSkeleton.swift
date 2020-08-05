import SnapKit
import UIKit

extension NewProfileHeaderViewSkeleton {
    struct Appearance {
        let avatarViewWithHeight: CGFloat = 64
        let avatarViewInsets = LayoutInsets(top: 16, left: 16)

        let usernameInsets = LayoutInsets(left: 16)
        let usernameHeight: CGFloat = 24

        let shortBioInsets = LayoutInsets(right: 16)
        let shortBioHeight: CGFloat = 29

        let spacing: CGFloat = 8
        let labelsCornerRadius: CGFloat = 5
    }
}

final class NewProfileHeaderViewSkeleton: UIView {
    let appearance: Appearance

    private let topContentInset: CGFloat

    private lazy var avatarView = UIView()
    private lazy var usernameView = UIView()
    private lazy var shortBioView = UIView()

    init(
        frame: CGRect = .zero,
        appearance: Appearance = Appearance(),
        topContentInset: CGFloat = 0
    ) {
        self.appearance = appearance
        self.topContentInset = topContentInset
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

extension NewProfileHeaderViewSkeleton: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.avatarView.clipsToBounds = true
        self.avatarView.layer.cornerRadius = self.appearance.avatarViewWithHeight / 2

        self.usernameView.clipsToBounds = true
        self.usernameView.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.shortBioView.clipsToBounds = true
        self.shortBioView.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.avatarView)
        self.addSubview(self.usernameView)
        self.addSubview(self.shortBioView)
    }

    func makeConstraints() {
        self.avatarView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarView.snp.makeConstraints { make in
            make.top
                .equalToSuperview()
                .offset(self.topContentInset + self.appearance.avatarViewInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.avatarViewInsets.left)
            make.width.equalTo(self.appearance.avatarViewWithHeight)
            make.height.equalTo(self.appearance.avatarViewWithHeight)
        }

        self.usernameView.translatesAutoresizingMaskIntoConstraints = false
        self.usernameView.snp.makeConstraints { make in
            make.top.equalTo(self.avatarView.snp.top)
            make.leading.equalTo(self.avatarView.snp.trailing).offset(self.appearance.usernameInsets.left)
            make.height.equalTo(self.appearance.usernameHeight)
            make.width.equalToSuperview().multipliedBy(0.3)
        }

        self.shortBioView.translatesAutoresizingMaskIntoConstraints = false
        self.shortBioView.snp.makeConstraints { make in
            make.top.equalTo(self.usernameView.snp.bottom).offset(self.appearance.spacing)
            make.leading.equalTo(self.usernameView.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.shortBioInsets.right)
            make.height.equalTo(self.appearance.shortBioHeight)
        }
    }
}
