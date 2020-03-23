//
//  AchievementsListViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.06.2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import Foundation

final class AchievementsListViewController: UIViewController, AchievementsListView, ControllerWithStepikPlaceholder {
    @IBOutlet weak var tableView: UITableView!

    var placeholderContainer = StepikPlaceholderControllerContainer()

    var presenter: AchievementsListPresenter?
    private var data: [AchievementViewData] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = NSLocalizedString("Achievements", comment: "")

        self.registerPlaceholder(
            placeholder: StepikPlaceholder(
                .noConnection,
                action: { [weak self] in
                    self?.refresh()
                }
            ),
            for: .connectionError
        )

        self.tableView.backgroundColor = .stepikGroupTableViewBackground

        self.tableView.skeleton.viewBuilder = { UIView.fromNib(named: "AchievementListSkeletonPlaceholderView") }
        self.tableView.register(
            UINib(nibName: "AchievementsListTableViewCell", bundle: nil),
            forCellReuseIdentifier: AchievementsListTableViewCell.reuseId
        )

        self.refresh()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.presenter?.sendAppearanceEvent()
    }

    func set(achievements: [AchievementViewData]) {
        self.data = achievements

        self.tableView.skeleton.hide()
        self.tableView.reloadData()
    }

    func showAchievementInfo(viewData: AchievementViewData, canShare: Bool) {
        let alertManager = AchievementPopupAlertManager(source: .achievementList)
        let vc = alertManager.construct(with: viewData, canShare: canShare)
        alertManager.present(alert: vc, inController: self)
    }

    func showLoadingError() {
        self.showPlaceholder(for: .connectionError)
    }

    private func refresh() {
        self.isPlaceholderShown = false
        self.tableView.skeleton.show()
        self.presenter?.refresh()
    }
}

extension AchievementsListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { self.data.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: AchievementsListTableViewCell.reuseId,
            for: indexPath
        ) as? AchievementsListTableViewCell else {
            return UITableViewCell()
        }

        if let viewData = self.data[safe: indexPath.row] {
            cell.update(with: viewData)
        }

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
