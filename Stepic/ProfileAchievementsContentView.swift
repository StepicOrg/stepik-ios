//
//  ProfileAchievementsContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class ProfileAchievementsContentView: UIView, ProfileAchievementsView {
    @IBOutlet weak var achievementsStackView: UIStackView!
    @IBOutlet weak var refreshButton: UIButton!

    private var presenter: ProfileAchievementsPresenter?

    private var achievementsCountInRow: Int {
        if DeviceInfo.current.diagonal <= 4.0 {
            return 3
        }

        if DeviceInfo.current.isPad || DeviceInfo.current.isPlus {
            return 5
        }

        return 4
    }

    @IBAction func onRefreshButtonClick(_ sender: Any) {
        refresh()
        self.presenter?.loadLastAchievements()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        refreshButton.setTitle(NSLocalizedString("Refresh", comment: ""), for: .normal)
        refreshButton.clipsToBounds = true
        refreshButton.layer.cornerRadius = 8
        refreshButton.layer.borderWidth = 0.5
        refreshButton.layer.borderColor = UIColor(red: 204 / 255, green: 204 / 255, blue: 204 / 255, alpha: 1.0).cgColor

        refreshButton.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 23.0, bottom: 12.0, right: 23.0)
        refreshButton.setTitleColor(UIColor(red: 83 / 255, green: 83 / 255, blue: 102 / 255, alpha: 1.0), for: .normal)

        achievementsStackView?.alpha = 0.0

        refresh()
    }

    private func addPlaceholdersView() {
        for v in achievementsStackView.arrangedSubviews {
            achievementsStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        for _ in 0..<achievementsCountInRow {
            let placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            achievementsStackView?.addArrangedSubview(placeholderView)
            placeholderView.skeleton.viewBuilder = { UIView.fromNib(named: "AchievementSkeletonPlaceholderView") }
            placeholderView.skeleton.show()
        }
    }

    func set(achievements: [AchievementViewData]) {
        var achievements = achievements
        for view in achievementsStackView.arrangedSubviews {
            achievementsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for i in 0..<min(achievements.count, achievementsCountInRow) {
            let data = achievements[i]

            let achievementView: AchievementBadgeView = AchievementBadgeView.fromNib()
            achievementView.translatesAutoresizingMaskIntoConstraints = false
            achievementView.data = data
            achievementView.onTap = { [weak self] in
                self?.presenter?.openAchievementInfo(with: data)
            }

            achievementsStackView?.addArrangedSubview(achievementView)
        }
    }

    func attachPresenter(_ presenter: ProfileAchievementsPresenter) {
        self.presenter = presenter
    }

    func showLoadingError() {
        achievementsStackView.alpha = 0.0
        refreshButton.isHidden = false
    }

    private func refresh() {
        achievementsStackView.alpha = 1.0
        refreshButton.isHidden = true
        addPlaceholdersView()
    }
}
