//
//  NotificationsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationsViewController: UIViewController, NotificationsView {
    var presenter: NotificationsPresenter?

    var section: NotificationsSection!
    var state: NotificationsViewState = .normal {
        didSet {
            switch state {
            case .normal:
                self.refreshControl.endRefreshing()
            case .refresh:
                self.refreshControl.beginRefreshing()
            default: break
            }
        }
    }
    var notifications: [NotificationViewData] = []

    @IBOutlet weak var tableView: UITableView!

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        presenter = NotificationsPresenter(section: section, notificationsAPI: ApiDataDownloader.notifications, view: self)

        refreshControl.addTarget(self, action: #selector(NotificationsViewController.refreshNotifications), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        view.layoutIfNeeded()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        presenter?.load()
    }

    func refreshNotifications() {
        presenter?.refresh()
    }

    func set(notifications: [NotificationViewData]) {
        self.notifications = notifications

        tableView.reloadData()
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.text = "\(notifications[indexPath.item].text.trimmingCharacters(in: .whitespacesAndNewlines))"
        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return NotificationsSectionHeaderView()
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
