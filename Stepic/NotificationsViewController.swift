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
    var data: NotificationViewDataStruct = []

    @IBOutlet weak var markAllAsReadButton: UIButton!
    @IBOutlet weak var markAllAsReadButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    let refreshControl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide "Mark all as read" button
        if section != .all {
            markAllAsReadButton.isHidden = true
            markAllAsReadButtonBottomConstraint.constant = 0
            markAllAsReadButtonTopConstraint.constant = 0
            markAllAsReadHeightConstraint.constant = 0
        }

        presenter = NotificationsPresenter(section: section, notificationsAPI: ApiDataDownloader.notifications, usersAPI: ApiDataDownloader.users, view: self)

        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: NotificationsTableViewCell.reuseId)
        tableView.register(UINib(nibName: "NotificationsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: NotificationsSectionHeaderView.reuseId)

        refreshControl.addTarget(self, action: #selector(NotificationsViewController.refreshNotifications), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presenter?.load()
    }

    func refreshNotifications() {
        presenter?.refresh()
    }

    func set(notifications: NotificationViewDataStruct) {
        self.data = notifications
        tableView.reloadData()
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return data.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data[section].notifications.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NotificationsTableViewCell.reuseId)

        if let cell = cell as? NotificationsTableViewCell {
            let currentNotification = data[indexPath.section].notifications[indexPath.item]
            cell.update(with: currentNotification)
            DispatchQueue.global(qos: .userInitiated).async {
                let categories: [NotificationType: String] = [
                    .comments: "Comments",
                    .learn: "Learn",
                    .`default`: "Default",
                    .review: "Review",
                    .teach: "Teach"
                ]

                if let userId = NotificationDataExtractor(text: currentNotification.text, type: currentNotification.type).userId {
                    ApiDataDownloader.users.retrieve(ids: [userId], existing: [], refreshMode: .update, success: { users in
                        DispatchQueue.main.async {
                            switch currentNotification.type {
                            case .comments:
                                cell.updateLeftView(.avatar(url: URL(string: users.first?.avatarURL ?? "")!))
                            default:
                                cell.updateLeftView(.category(firstLetter: categories[currentNotification.type]?.first ?? "A"))
                            }
                        }
                    }, error: { _ in
                    })
                } else {
                    DispatchQueue.main.async {
                        cell.updateLeftView(.category(firstLetter: categories[currentNotification.type]?.first ?? "A"))
                    }
                }
            }
        }
        return cell!
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: NotificationsSectionHeaderView.reuseId)
        if let header = header as? NotificationsSectionHeaderView {
            header.update(with: data[section].date)
        }
        return header
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
}
