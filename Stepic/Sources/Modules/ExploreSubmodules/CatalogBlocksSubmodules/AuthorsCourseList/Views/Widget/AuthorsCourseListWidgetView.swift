import SnapKit
import UIKit

extension AuthorsCourseListWidgetView {
    struct Appearance {
        let coverViewWidthHeight: CGFloat = 64
        let coverViewInsets = LayoutInsets(top: 16, left: 16)

        let titleLabelFont = Typography.subheadlineFont
        let titleLabelTextColor = UIColor.stepikSystemPrimaryText
        let titleLabelInsets = LayoutInsets(left: 16, right: 16)
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
    }
}

extension AuthorsCourseListWidgetView: ProgrammaticallyInitializableViewProtocol {
    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleLabel)
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
    }
}
