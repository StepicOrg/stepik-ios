import SnapKit
import UIKit

extension CourseRevenueHeaderSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let coverSize = CGSize(width: 32, height: 32)
        let coverCornerRadius: CGFloat = 16

        let titleHeight: CGFloat = 17
        let titleWidthRatio: CGFloat = 0.5

        let subtitleHeight: CGFloat = 26
        let subtitleWidthRatio: CGFloat = 0.3

        let labelsCornerRadius: CGFloat = 5
    }
}

final class CourseRevenueHeaderSkeletonView: UIView {
    let appearance: Appearance

    private lazy var coverView = UIView()

    private lazy var titleView = UIView()

    private lazy var subtitleView = UIView()

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

extension CourseRevenueHeaderSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = .clear

        self.coverView.clipsToBounds = true
        self.coverView.layer.cornerRadius = self.appearance.coverCornerRadius

        self.titleView.clipsToBounds = true
        self.titleView.layer.cornerRadius = self.appearance.labelsCornerRadius

        self.subtitleView.clipsToBounds = true
        self.subtitleView.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleView)
        self.addSubview(self.subtitleView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.centerY.equalToSuperview()
            make.size.equalTo(self.appearance.coverSize)
        }

        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.coverView.snp.trailing).offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.titleHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.titleWidthRatio)
        }

        self.subtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleView.snp.makeConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom).offset(self.appearance.insets.top / 2)
            make.leading.equalTo(self.coverView.snp.trailing).offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.subtitleHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.subtitleWidthRatio)
        }
    }
}
