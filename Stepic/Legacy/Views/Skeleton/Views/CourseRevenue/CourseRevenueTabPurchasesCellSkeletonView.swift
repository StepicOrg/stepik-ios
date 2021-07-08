import SnapKit
import UIKit

extension CourseRevenueTabPurchasesCellSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let logoIconSize = CGSize(width: 24, height: 24)

        let titleHeight: CGFloat = 14
        let titleWidthRatio: CGFloat = 0.5

        let subtitleHeight: CGFloat = 20
        let subtitleWidthRatio: CGFloat = 0.4

        let promoCodeHeight: CGFloat = 14
        let promoCodeWidthRatio: CGFloat = 0.3

        let labelsCornerRadius: CGFloat = 5
    }
}

final class CourseRevenueTabPurchasesCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var logoIconView = UIView()

    private lazy var titleView = UIView()

    private lazy var rightDetailTitleView = UIView()

    private lazy var subtitleView = UIView()

    private lazy var rightDetailSubtitleView = UIView()

    private lazy var promoCodeView = UIView()

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

extension CourseRevenueTabPurchasesCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.logoIconView.clipsToBounds = true
        self.logoIconView.layer.cornerRadius = self.appearance.logoIconSize.height / 2

        [
            self.titleView,
            self.rightDetailTitleView,
            self.subtitleView,
            self.rightDetailSubtitleView,
            self.promoCodeView
        ].forEach {
            $0.clipsToBounds = true
            $0.layer.cornerRadius = self.appearance.labelsCornerRadius
        }
    }

    func addSubviews() {
        self.addSubview(self.logoIconView)
        self.addSubview(self.titleView)
        self.addSubview(self.rightDetailTitleView)
        self.addSubview(self.subtitleView)
        self.addSubview(self.rightDetailSubtitleView)
        self.addSubview(self.promoCodeView)
    }

    func makeConstraints() {
        self.logoIconView.translatesAutoresizingMaskIntoConstraints = false
        self.logoIconView.snp.makeConstraints { make in
            make.leading.equalToSuperview().offset(self.appearance.insets.left)
            make.size.equalTo(self.appearance.logoIconSize)
            make.centerY.equalTo(self.subtitleView.snp.centerY)
        }

        self.titleView.translatesAutoresizingMaskIntoConstraints = false
        self.titleView.snp.makeConstraints { make in
            make.top.equalToSuperview().offset(self.appearance.insets.top)
            make.leading.equalTo(self.logoIconView.snp.trailing).offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.titleHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.titleWidthRatio)
        }

        self.rightDetailTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailTitleView.snp.makeConstraints { make in
            make.leading.equalTo(self.titleView.snp.trailing).offset(self.appearance.insets.left * 2)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.top.bottom.equalTo(self.titleView)
        }

        self.subtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.subtitleView.snp.makeConstraints { make in
            make.top.equalTo(self.titleView.snp.bottom).offset(self.appearance.insets.top / 2)
            make.leading.equalTo(self.logoIconView.snp.trailing).offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.subtitleHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.subtitleWidthRatio)
        }

        self.rightDetailSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.rightDetailSubtitleView.snp.makeConstraints { make in
            make.leading.equalTo(self.subtitleView.snp.trailing).offset(self.appearance.insets.left * 3)
            make.trailing.equalToSuperview().offset(-self.appearance.insets.right)
            make.top.bottom.equalTo(self.subtitleView)
        }

        self.promoCodeView.translatesAutoresizingMaskIntoConstraints = false
        self.promoCodeView.snp.makeConstraints { make in
            make.top.equalTo(self.subtitleView.snp.bottom).offset(self.appearance.insets.top / 2)
            make.leading.equalTo(self.logoIconView.snp.trailing).offset(self.appearance.insets.left)
            make.height.equalTo(self.appearance.promoCodeHeight)
            make.width.equalToSuperview().multipliedBy(self.appearance.promoCodeWidthRatio)
            make.bottom.equalToSuperview().offset(-self.appearance.insets.bottom)
        }
    }
}
