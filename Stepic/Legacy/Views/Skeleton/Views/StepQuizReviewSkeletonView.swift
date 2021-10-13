import SnapKit
import UIKit

extension StepQuizReviewSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let circleViewSize = CGSize(width: 24, height: 24)

        let labelCornerRadius: CGFloat = 5
        let labelHeight: CGFloat = 16

        let contentViewsHeight: CGFloat = 88
        let contentViewsCornerRadius: CGFloat = 4

        let joinViewWidth: CGFloat = 2.5

        let separatorHeight: CGFloat = 1
    }
}

final class StepQuizReviewSkeletonView: UIView {
    let appearance: Appearance

    private lazy var circleView1 = UIView()
    private lazy var titleView1 = UIView()
    private lazy var separatorView1 = UIView()
    private lazy var contentView1 = UIView()
    private lazy var contentSeparatorView1 = UIView()

    private lazy var circleView2 = UIView()
    private lazy var titleView2 = UIView()
    private lazy var separatorView2 = UIView()
    private lazy var contentView2 = UIView()
    private lazy var contentSeparatorView2 = UIView()

    private lazy var joinView = UIView()

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

extension StepQuizReviewSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        [self.circleView1, self.circleView2].forEach { view in
            view.layer.cornerRadius = self.appearance.circleViewSize.width / 2
            view.clipsToBounds = true
        }

        [self.titleView1, self.titleView2].forEach { view in
            view.layer.cornerRadius = self.appearance.labelCornerRadius
            view.clipsToBounds = true
        }

        [self.contentView1, self.contentView2].forEach { view in
            view.layer.cornerRadius = self.appearance.contentViewsCornerRadius
            view.clipsToBounds = true
        }
    }

    func addSubviews() {
        self.addSubview(self.joinView)
        self.addSubview(self.circleView1)
        self.addSubview(self.titleView1)
        self.addSubview(self.separatorView1)
        self.addSubview(self.contentView1)
        self.addSubview(self.contentSeparatorView1)
        self.addSubview(self.circleView2)
        self.addSubview(self.titleView2)
        self.addSubview(self.separatorView2)
        self.addSubview(self.contentView2)
        self.addSubview(self.contentSeparatorView2)
    }

    func makeConstraints() {
        self.circleView1.translatesAutoresizingMaskIntoConstraints = false
        self.circleView1.snp.makeConstraints { make in
            make.top.leading.equalToSuperview().inset(self.appearance.insets.edgeInsets)
            make.size.equalTo(self.appearance.circleViewSize)
        }

        self.titleView1.translatesAutoresizingMaskIntoConstraints = false
        self.titleView1.snp.makeConstraints { make in
            make.leading.equalTo(self.circleView1.snp.trailing).offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalTo(self.circleView1.snp.centerY)
            make.height.equalTo(self.appearance.labelHeight)
        }

        self.separatorView1.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView1.snp.makeConstraints { make in
            make.top.equalTo(self.circleView1.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.titleView1.snp.leading)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.contentView1.translatesAutoresizingMaskIntoConstraints = false
        self.contentView1.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView1.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.separatorView1.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.contentViewsHeight)
        }

        self.contentSeparatorView1.translatesAutoresizingMaskIntoConstraints = false
        self.contentSeparatorView1.snp.makeConstraints { make in
            make.top.equalTo(self.contentView1.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.contentView1.snp.leading)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.circleView2.translatesAutoresizingMaskIntoConstraints = false
        self.circleView2.snp.makeConstraints { make in
            make.top.equalTo(self.contentSeparatorView1.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.size.equalTo(self.appearance.circleViewSize)
        }

        self.titleView2.translatesAutoresizingMaskIntoConstraints = false
        self.titleView2.snp.makeConstraints { make in
            make.leading.equalTo(self.circleView2.snp.trailing).offset(self.appearance.insets.left)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.centerY.equalTo(self.circleView2.snp.centerY)
            make.height.equalTo(self.appearance.labelHeight)
        }

        self.separatorView2.translatesAutoresizingMaskIntoConstraints = false
        self.separatorView2.snp.makeConstraints { make in
            make.top.equalTo(self.circleView2.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.titleView2.snp.leading)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.contentView2.translatesAutoresizingMaskIntoConstraints = false
        self.contentView2.snp.makeConstraints { make in
            make.top.equalTo(self.separatorView2.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.separatorView2.snp.leading)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.height.equalTo(self.appearance.contentViewsHeight)
        }

        self.contentSeparatorView2.translatesAutoresizingMaskIntoConstraints = false
        self.contentSeparatorView2.snp.makeConstraints { make in
            make.top.equalTo(self.contentView2.snp.bottom).offset(self.appearance.insets.top)
            make.leading.equalTo(self.contentView2.snp.leading)
            make.bottom.lessThanOrEqualToSuperview().offset(-self.appearance.insets.bottom)
            make.trailing.equalToSuperview()
            make.height.equalTo(self.appearance.separatorHeight)
        }

        self.joinView.translatesAutoresizingMaskIntoConstraints = false
        self.joinView.snp.makeConstraints { make in
            make.top.equalTo(self.circleView1.snp.bottom)
            make.centerX.equalTo(self.circleView1.snp.centerX)
            make.bottom.equalTo(self.circleView2.snp.top)
            make.width.equalTo(self.appearance.joinViewWidth)
        }
    }
}
