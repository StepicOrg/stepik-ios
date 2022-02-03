import SnapKit
import UIKit

extension CourseInfoTabInfoAuthorView {
    struct Appearance {
        let avatarImageViewSize = CGSize(width: 32, height: 32)
        let avatarImageViewCornerRadius: CGFloat = 8

        var titleLabelAppearance = CourseInfoTabInfoLabel.Appearance(
            maxLinesCount: 0,
            font: Typography.subheadlineFont,
            textColor: UIColor.stepikMaterialPrimaryText
        )
        var titleLabelInsets = LayoutInsets(left: 8)
    }
}

final class CourseInfoTabInfoAuthorView: UIControl {
    let appearance: Appearance

    private lazy var avatarImageView: AvatarImageView = {
        let view = AvatarImageView(frame: .zero)
        view.shape = .rectangle(cornerRadius: self.appearance.avatarImageViewCornerRadius)
        return view
    }()

    private lazy var titleLabel = CourseInfoTabInfoLabel(appearance: self.appearance.titleLabelAppearance)

    override var isHighlighted: Bool {
        didSet {
            self.avatarImageView.alpha = self.isHighlighted ? 0.5 : 1.0
            self.titleLabel.alpha = self.isHighlighted ? 0.5 : 1.0
        }
    }

    var title: String? {
        didSet {
            self.titleLabel.text = self.title
        }
    }

    var avatarImageURL: URL? {
        didSet {
            if let avatarImageURL = self.avatarImageURL {
                self.avatarImageView.set(with: avatarImageURL)
            } else {
                self.avatarImageView.reset()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(
            width: UIView.noIntrinsicMetric,
            height: max(self.appearance.avatarImageViewSize.height, self.titleLabel.intrinsicContentSize.height)
        )
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

extension CourseInfoTabInfoAuthorView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {}

    func addSubviews() {
        self.addSubview(self.avatarImageView)
        self.addSubview(self.titleLabel)
    }

    func makeConstraints() {
        self.avatarImageView.translatesAutoresizingMaskIntoConstraints = false
        self.avatarImageView.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview()
            make.size.equalTo(self.appearance.avatarImageViewSize)
        }

        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.snp.makeConstraints { make in
            make.leading.equalTo(self.avatarImageView.snp.trailing).offset(self.appearance.titleLabelInsets.left)
            make.trailing.lessThanOrEqualToSuperview()
            make.centerY.equalTo(self.avatarImageView.snp.centerY)
        }
    }
}
