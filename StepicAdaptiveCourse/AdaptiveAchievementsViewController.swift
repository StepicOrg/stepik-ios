//
//  AdaptiveAchievementsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 27.07.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Charts

class AdaptiveAchievementsViewController: UIViewController {
    var presenter: AdaptiveAchievementsPresenter?

    fileprivate var data: [AchievementViewData]?

    @IBOutlet weak var tableView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        setUpTable()

        presenter?.reloadData(force: true)
    }

    fileprivate func setUpTable() {
        tableView.delegate = self
        tableView.dataSource = self

        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 112

        tableView.register(UINib(nibName: "AchievementTableViewCell", bundle: nil), forCellReuseIdentifier: AchievementTableViewCell.reuseId)

        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
        }
    }
}

extension AdaptiveAchievementsViewController: AdaptiveAchievementsView {
    func setAchievements(records: [AchievementViewData]) {
        data = records
    }

    func reload() {
        tableView.reloadData()
    }
}

extension AdaptiveAchievementsViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (data?.count ?? 0)
    }

    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AchievementTableViewCell.reuseId, for: indexPath) as! AchievementTableViewCell
        if let achievement = data?[indexPath.item] {
            cell.updateInfo(name: achievement.name, info: achievement.info, cover: achievement.cover, isUnlocked: achievement.isUnlocked, type: achievement.type, currentProgress: achievement.currentProgress, maxProgress: achievement.maxProgress)
        }
        return cell
    }
}
