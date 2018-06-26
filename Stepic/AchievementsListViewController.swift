//
//  AchievementsListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import NotificationBannerSwift

class AchievementsListViewController: UIViewController, AchievementsListView {
    @IBOutlet weak var tableView: UITableView!

    var presenter: AchievementsListPresenter?
    private var data: [AchievementViewData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = NSLocalizedString("Achievements", comment: "")

        tableView.skeleton.viewBuilder = { return UIView.fromNib(named: "AchievementListSkeletonPlaceholderView") }
        tableView.skeleton.show()

        tableView.register(UINib(nibName: "AchievementsListTableViewCell", bundle: nil), forCellReuseIdentifier: AchievementsListTableViewCell.reuseId)

        presenter?.refresh()
    }

    func set(achievements: [AchievementViewData]) {
        data = achievements

        tableView.skeleton.hide()
        tableView.reloadData()
    }

    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool) {
        let alertManager = AchievementPopupAlertManager()
        let vc = alertManager.construct(with: viewData, canShare: canShare)
        alertManager.present(alert: vc, inController: self)
    }
}

extension AchievementsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: AchievementsListTableViewCell.reuseId, for: indexPath) as? AchievementsListTableViewCell,
              let viewData = data[safe: indexPath.row] else {
            return UITableViewCell()
        }

        cell.update(with: viewData)
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        guard let viewData = data[safe: indexPath.row] else {
            return
        }

        self.presenter?.achievementSelected(with: viewData)
    }
}
