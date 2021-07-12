import SnapKit
import UIKit

extension CourseRevenueTabMonthlyCellSkeletonView {
    struct Appearance {
        let insets = LayoutInsets.default

        let totalViewHeight: CGFloat = 44
        let totalViewCornerRadius: CGFloat = 6
        let totalViewInsets = LayoutInsets.default

        let logoIconSize = CGSize(width: 24, height: 24)

        let labelsHeight: CGFloat = 17
        let labelsCornerRadius: CGFloat = 5
        let labelsInsets = LayoutInsets(top: 16, left: 32, bottom: 16, right: 32)
    }
}

final class CourseRevenueTabMonthlyCellSkeletonView: UIView {
    let appearance: Appearance

    private lazy var totalView = UIView()

    private lazy var firstTitleView = UIView()
    private lazy var firstSubtitleView = UIView()

    private lazy var secondTitleView = UIView()
    private lazy var secondSubtitleView = UIView()

    private lazy var thirdTitleView = UIView()
    private lazy var thirdSubtitleView = UIView()

    private lazy var fourthLogoIconView = UIView()
    private lazy var fourthTitleView = UIView()
    private lazy var fourthSubtitleView = UIView()

    private lazy var fifthLogoIconView = UIView()
    private lazy var fifthTitleView = UIView()
    private lazy var fifthSubtitleView = UIView()

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

extension CourseRevenueTabMonthlyCellSkeletonView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.totalView.clipsToBounds = true
        self.totalView.layer.cornerRadius = self.appearance.totalViewCornerRadius

        [
            self.firstTitleView,
            self.firstSubtitleView,
            self.secondTitleView,
            self.secondSubtitleView,
            self.thirdTitleView,
            self.thirdSubtitleView,
            self.fourthTitleView,
            self.fourthSubtitleView,
            self.fifthTitleView,
            self.fifthSubtitleView
        ].forEach { view in
            view.clipsToBounds = true
            view.layer.cornerRadius = self.appearance.labelsCornerRadius
        }

        [
            self.fourthLogoIconView,
            self.fifthLogoIconView
        ].forEach { view in
            view.clipsToBounds = true
            view.layer.cornerRadius = self.appearance.logoIconSize.height / 2
        }
    }

    func addSubviews() {
        self.addSubview(self.totalView)
        self.addSubview(self.firstTitleView)
        self.addSubview(self.firstSubtitleView)
        self.addSubview(self.secondTitleView)
        self.addSubview(self.secondSubtitleView)
        self.addSubview(self.thirdTitleView)
        self.addSubview(self.thirdSubtitleView)
        self.addSubview(self.fourthLogoIconView)
        self.addSubview(self.fourthTitleView)
        self.addSubview(self.fourthSubtitleView)
        self.addSubview(self.fifthLogoIconView)
        self.addSubview(self.fifthTitleView)
        self.addSubview(self.fifthSubtitleView)
    }

    func makeConstraints() {
        self.totalView.translatesAutoresizingMaskIntoConstraints = false
        self.totalView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(self.appearance.totalViewInsets.edgeInsets)
            make.height.equalTo(self.appearance.totalViewHeight)
        }

        self.firstTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.firstTitleView.snp.makeConstraints { make in
            make.top.equalTo(self.totalView.snp.bottom).offset(self.appearance.labelsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.height.equalTo(self.appearance.labelsHeight)
            make.width.equalToSuperview().multipliedBy(0.15)
        }

        self.firstSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.firstSubtitleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.height.equalTo(self.appearance.labelsHeight)
            make.centerY.equalTo(self.firstTitleView.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.25)
        }

        self.secondTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.secondTitleView.snp.makeConstraints { make in
            make.top.equalTo(self.firstTitleView.snp.bottom).offset(self.appearance.labelsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.height.equalTo(self.appearance.labelsHeight)
            make.width.equalToSuperview().multipliedBy(0.2)
        }

        self.secondSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.secondSubtitleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.height.equalTo(self.appearance.labelsHeight)
            make.centerY.equalTo(self.secondTitleView.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.2)
        }

        self.thirdTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.thirdTitleView.snp.makeConstraints { make in
            make.top.equalTo(self.secondTitleView.snp.bottom).offset(self.appearance.labelsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.height.equalTo(self.appearance.labelsHeight)
            make.width.equalToSuperview().multipliedBy(0.25)
        }

        self.thirdSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.thirdSubtitleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.height.equalTo(self.appearance.labelsHeight)
            make.centerY.equalTo(self.thirdTitleView.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.15)
        }

        self.fourthLogoIconView.translatesAutoresizingMaskIntoConstraints = false
        self.fourthLogoIconView.snp.makeConstraints { make in
            make.top.equalTo(self.thirdTitleView.snp.bottom).offset(self.appearance.labelsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.size.equalTo(self.appearance.logoIconSize)
        }

        self.fourthTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.fourthTitleView.snp.makeConstraints { make in
            make.leading.equalTo(self.fourthLogoIconView.snp.trailing).offset(self.appearance.insets.left / 2)
            make.centerY.equalTo(self.fourthLogoIconView.snp.centerY)
            make.height.equalTo(self.appearance.labelsHeight)
            make.width.equalToSuperview().multipliedBy(0.4)
        }

        self.fourthSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.fourthSubtitleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.height.equalTo(self.appearance.labelsHeight)
            make.centerY.equalTo(self.fourthTitleView.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.15)
        }

        self.fifthLogoIconView.translatesAutoresizingMaskIntoConstraints = false
        self.fifthLogoIconView.snp.makeConstraints { make in
            make.top.equalTo(self.fourthLogoIconView.snp.bottom).offset(self.appearance.labelsInsets.top)
            make.leading.equalToSuperview().offset(self.appearance.labelsInsets.left)
            make.bottom.equalToSuperview().offset(-self.appearance.labelsInsets.bottom)
            make.size.equalTo(self.appearance.logoIconSize)
        }

        self.fifthTitleView.translatesAutoresizingMaskIntoConstraints = false
        self.fifthTitleView.snp.makeConstraints { make in
            make.leading.equalTo(self.fifthLogoIconView.snp.trailing).offset(self.appearance.insets.left / 2)
            make.centerY.equalTo(self.fifthLogoIconView.snp.centerY)
            make.height.equalTo(self.appearance.labelsHeight)
            make.width.equalToSuperview().multipliedBy(0.45)
        }

        self.fifthSubtitleView.translatesAutoresizingMaskIntoConstraints = false
        self.fifthSubtitleView.snp.makeConstraints { make in
            make.trailing.equalToSuperview().offset(-self.appearance.labelsInsets.right)
            make.height.equalTo(self.appearance.labelsHeight)
            make.centerY.equalTo(self.fifthTitleView.snp.centerY)
            make.width.equalToSuperview().multipliedBy(0.15)
        }
    }
}
