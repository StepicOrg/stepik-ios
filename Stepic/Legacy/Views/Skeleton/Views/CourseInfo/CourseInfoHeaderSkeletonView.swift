import SnapKit
import UIKit

extension CourseInfoHeaderSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let actionButtonHeight: CGFloat = 42
        let actionButtonWidthRatio: CGFloat = 0.55

        let statsViewHeight: CGFloat = 17
        let statsViewWidthRatio: CGFloat = 0.7

        let coverSize = CGSize(width: 36, height: 36)
        let coverCornerRadius: CGFloat = 3
        let coverInsets = LayoutInsets(right: 8)

        let titleHeight: CGFloat = 17
        let titleWidthRatio: CGFloat = 0.3

        let labelsCornerRadius: CGFloat = 5
    }
}

final class CourseInfoHeaderSkeletonView: UIView {
    let appearance: Appearance

    private lazy var actionButton = UIView()

    private lazy var statsView = UIView()

    private lazy var coverView = UIView()

    private lazy var titleView = UIView()

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

extension CourseInfoHeaderSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.actionButton.clipsToBounds = true
        self.actionButton.layer.cornerRadius = self.appearance.actionButtonHeight / 2

        self.statsView.clipsToBounds = true
        self.statsView.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.coverView.clipsToBounds = true
        self.coverView.layer.cornerRadius = self.appearance.coverCornerRadius

        self.titleView.clipsToBounds = true
        self.titleView.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.actionButton)
        self.addSubview(self.statsView)
        self.addSubview(self.coverView)
        self.addSubview(self.titleView)
    }

    func makeConstraints() {
        self.actionButton.translatesAutoresizingMaskIntoConstraints = false
        self.actionButton.snp.makeConstraints { make in
            make.top.equalTo(self.safeAreaLayoutGuide.snp.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.actionButtonHeight)
            make.width.equalTo(self.snp.width).multipliedBy(self.appearance.actionButtonWidthRatio)
        }

        self.statsView.translatesAutoresizingMaskIntoConstraints = false
        self.statsView.snp.makeConstraints { make in
            make.top.equalTo(self.actionButton.snp.bottom).offset(self.appearance.insets.top)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.statsViewHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.statsViewWidthRatio)
        }

        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top.equalTo(self.statsView.snp.bottom).offset(self.appearance.insets.top)
            make.trailing.equalTo(self.titleView.snp.leading).offset(-self.appearance.coverInsets.right)
            make.size.equalTo(self.appearance.coverSize)
        }

        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.snp.makeConstraints { make in
            make.centerY.equalTo(self.coverView.snp.centerY)
            make.centerX.equalToSuperview()
            make.height.equalTo(self.appearance.titleHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.titleWidthRatio)
        }
    }
}
