//
//  AchievementsListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation
import SkeletonView

class AchievementsListViewController: UIViewController, AchievementsListView {
    @IBOutlet weak var tableView: UITableView!

    var presenter: AchievementsListPresenter?
    private var data: [AchievementViewData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Achievements"
        tableView.isSkeletonable = true
        tableView.register(UINib(nibName: "AchievementsListTableViewCell", bundle: nil), forCellReuseIdentifier: AchievementsListTableViewCell.reuseId)

        presenter?.refresh()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        view.showAnimatedGradientSkeleton(usingGradient: SkeletonGradient(baseColor: UIColor.mainLight),
                                          animation: GradientDirection.leftRight.slidingAnimation())
    }

    func set(count: Int, achievements: [AchievementViewData]) {
        data = achievements

        for _ in 0..<(count - achievements.count) {
            data.append(AchievementViewData.empty)
        }

        view.hideSkeleton()
        tableView.reloadData()
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
}

extension AchievementsListViewController: SkeletonTableViewDataSource {
    func collectionSkeletonView(_ skeletonView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 25
    }

    func collectionSkeletonView(_ skeletonView: UITableView, cellIdenfierForRowAt indexPath: IndexPath) -> ReusableCellIdentifier {
        return "AchievementsListTableViewCell"
    }
}
