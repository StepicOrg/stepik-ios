import SnapKit
import UIKit

extension NewProfileAchievementsView {
    struct Appearance {
        let stackViewHeight: CGFloat = 80
        let stackViewSpacing: CGFloat = 8

        let backgroundColor = UIColor.stepikBackground
    }
}

final class NewProfileAchievementsView: UIView {
    let appearance: Appearance

    private lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = self.appearance.stackViewSpacing
        return stackView
    }()

    private var achievementsCountInRow: Int {
        if DeviceInfo.current.diagonal <= 4.0 {
            return 3
        } else if DeviceInfo.current.isPad || DeviceInfo.current.isPlus {
            return 5
        } else {
            return 4
        }
    }

    override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: self.appearance.stackViewHeight)
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

    func showLoading() {
        self.removeAllArrangedSubviews()

        for _ in 0..<self.achievementsCountInRow {
            let placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            self.stackView.addArrangedSubview(placeholderView)
            placeholderView.skeleton.viewBuilder = { UIView.fromNib(named: "AchievementSkeletonPlaceholderView") }
            placeholderView.skeleton.show()
        }
    }

    func hideLoading() {
        self.removeAllArrangedSubviews()
    }

    func configure(viewModel: NewProfileAchievementsViewModel) {
        self.removeAllArrangedSubviews()

        let achievements = viewModel.achievements

        for i in 0..<min(achievements.count, self.achievementsCountInRow) {
            let data = achievements[i]

            let achievementView = AchievementBadgeView.fromNib() as AchievementBadgeView
            achievementView.translatesAutoresizingMaskIntoConstraints = false
            achievementView.data = data
            achievementView.onTap = {
                print("Tapped")
            }

            self.stackView.addArrangedSubview(achievementView)
        }
    }

    private func removeAllArrangedSubviews() {
        for arrangedSubview in self.stackView.arrangedSubviews {
            self.stackView.removeArrangedSubview(arrangedSubview)
            arrangedSubview.removeFromSuperview()
        }
    }
}

extension NewProfileAchievementsView: ProgrammaticallyInitializableViewProtocol {
    func setupView() {
        self.backgroundColor = self.appearance.backgroundColor
    }

    func addSubviews() {
        self.addSubview(self.stackView)
    }

    func makeConstraints() {
        self.stackView.translatesAutoresizingMaskIntoConstraints = false
        self.stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.height.equalTo(self.appearance.stackViewHeight)
        }
    }
}
