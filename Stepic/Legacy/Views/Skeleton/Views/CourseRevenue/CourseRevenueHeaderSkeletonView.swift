import SnapKit
import UIKit

extension CourseRevenueHeaderSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let coverSize = CGSize(width: 32, height: 32)
        let coverCornerRadius: CGFloat = 16

        let titleHeight: CGFloat = 17
        let titleWidthRatio: CGFloat = 0.5

        let subtitleHeight: CGFloat = 24
        let subtitleWidthRatio: CGFloat = 0.3

        let disclaimerHeight: CGFloat = 17
        let disclaimerWidthRatio: CGFloat = 0.8

        let labelsCornerRadius: CGFloat = 5
    }
}

final class CourseRevenueHeaderSkeletonView: UIView {
    let appearance: Appearance

    private lazy var coverView = UIView()

    private lazy var titleView = UIView()

    private lazy var subtitleView = UIView()

    private lazy var disclaimerView = UIView()

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

        self.disclaimerView.clipsToBounds = true
        self.disclaimerView.layer.cornerRadius = self.appearance.labelsCornerRadius
    }

    func addSubviews() {
        self.addSubview(self.coverView)
        self.addSubview(self.titleView)
        self.addSubview(self.subtitleView)
        self.addSubview(self.disclaimerView)
    }

    func makeConstraints() {
        self.coverView.translatesAutoresizingMaskIntoConstraints = false
        self.coverView.snp.makeConstraints { make in
            make.top
                .equalTo(self.titleView.snp.bottom)
                .offset(-(self.appearance.coverSize.height / 2) + (self.appearance.insets.top / 4))
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
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

        self.disclaimerView.translatesAutoresizingMaskIntoConstraints = false
        self.disclaimerView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleView.snp.bottom).offset(self.appearance.insets.top / 2)
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.disclaimerHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.disclaimerWidthRatio)
        }
    }
}
