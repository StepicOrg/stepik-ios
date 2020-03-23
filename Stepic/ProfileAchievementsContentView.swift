//
//  ProfileAchievementsContentView.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 06.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class ProfileAchievementsContentView: UIView, ProfileAchievementsView {
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

    @IBAction
    func onRefreshButtonClick(_ sender: Any) {
        self.refresh()
        self.presenter?.loadLastAchievements()
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.refreshButton.setTitle(NSLocalizedString("Refresh", comment: ""), for: .normal)
        self.refreshButton.clipsToBounds = true
        self.refreshButton.layer.cornerRadius = 8
        self.refreshButton.layer.borderWidth = 0.5
        self.refreshButton.contentEdgeInsets = UIEdgeInsets(top: 12.0, left: 23.0, bottom: 12.0, right: 23.0)

        self.achievementsStackView?.alpha = 0.0

        self.colorize()
        self.refresh()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func colorize() {
        self.backgroundColor = .stepikBackground
        self.refreshButton.layer.borderColor = UIColor.stepikSeparator.cgColor
        self.refreshButton.setTitleColor(.stepikPrimaryText, for: .normal)
    }

    private func addPlaceholdersView() {
        for v in self.achievementsStackView.arrangedSubviews {
            self.achievementsStackView.removeArrangedSubview(v)
            v.removeFromSuperview()
        }

        for _ in 0..<self.achievementsCountInRow {
            let placeholderView = UIView()
            placeholderView.translatesAutoresizingMaskIntoConstraints = false

            self.achievementsStackView?.addArrangedSubview(placeholderView)
            placeholderView.skeleton.viewBuilder = { UIView.fromNib(named: "AchievementSkeletonPlaceholderView") }
            placeholderView.skeleton.show()
        }
    }

    func set(achievements: [AchievementViewData]) {
        for view in self.achievementsStackView.arrangedSubviews {
            self.achievementsStackView.removeArrangedSubview(view)
            view.removeFromSuperview()
        }

        for i in 0..<min(achievements.count, self.achievementsCountInRow) {
            let data = achievements[i]

            let achievementView: AchievementBadgeView = AchievementBadgeView.fromNib()
            achievementView.translatesAutoresizingMaskIntoConstraints = false
            achievementView.data = data
            achievementView.onTap = { [weak self] in
                self?.presenter?.openAchievementInfo(with: data)
            }

            self.achievementsStackView?.addArrangedSubview(achievementView)
        }
    }

    func attachPresenter(_ presenter: ProfileAchievementsPresenter) {
        self.presenter = presenter
    }

    func showLoadingError() {
        self.achievementsStackView.alpha = 0.0
        self.refreshButton.isHidden = false
    }

    private func refresh() {
        self.achievementsStackView.alpha = 1.0
        self.refreshButton.isHidden = true
        self.addPlaceholdersView()
    }
}
