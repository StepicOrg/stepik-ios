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
                self.tableView.tableFooterView?.isHidden = true
            case .refreshing:
                self.refreshControl.beginRefreshing()
            case .loading:
                self.tableView.tableFooterView?.isHidden = false
            default: break
            }
        }
    }

    var data: NotificationViewDataStruct = []

    @IBOutlet weak var markAllAsReadButton: NotificationsMarkAsReadButton!
    @IBOutlet weak var markAllAsReadButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!

    let refreshControl = UIRefreshControl()

    lazy var paginationView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView()
        paginationView.refreshAction = { [weak self] in
            self?.presenter?.loadNextPage()
        }

        paginationView.setLoading()
        return paginationView
    }()

    // How can we incapsulate this?
    func updateMarkAllAsReadButton(with status: NotificationsMarkAsReadButton.Status) {
        markAllAsReadButton.update(with: status)
    }

    @IBAction func onMarkAllAsReadButtonClick(_ sender: Any) {
        presenter?.markAllAsRead()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Hide "Mark all as read" button
        if section != .all {
            markAllAsReadButton.isHidden = true
            markAllAsReadButtonBottomConstraint.constant = 0
            markAllAsReadButtonTopConstraint.constant = 0
            markAllAsReadHeightConstraint.constant = 0
        }
        markAllAsReadButton.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)

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
        presenter?.loadInitial()
    }

    func refreshNotifications() {
        if state == .loading || state == .refreshing {
            return
        }

        presenter?.refresh()
    }

    func set(notifications: NotificationViewDataStruct) {
        self.data = notifications
        tableView.reloadData()
        setNeedsScrollViewInsetUpdate()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if state == .loading || state == .refreshing {
            return
        }

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        if deltaOffset <= 0 {
            presenter?.loadNextPage()
        }
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

            switch currentNotification.type {
            case .comments:
                if let url = currentNotification.avatarURL {
                    cell.updateLeftView(.avatar(url: url))
                }
            default:
                cell.updateLeftView(.category(firstLetter: currentNotification.type.localizedName.first ?? "A"))
            }

            cell.delegate = self
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

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let isLastSection = section == data.count - 1
        let hasNextPage = presenter?.hasNextPage ?? false
        return isLastSection && hasNextPage ? paginationView : UIView()
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let isLastSection = section == data.count - 1
        let hasNextPage = presenter?.hasNextPage ?? false
        return isLastSection && hasNextPage ? 60 : 0
    }
}

extension NotificationsViewController: NotificationsTableViewCellDelegate {
    func statusButtonClicked(inCell cell: NotificationsTableViewCell, withNotificationId id: Int) {
        if cell.status == .unread {
            presenter?.updateNotification(with: id, status: .read)
            cell.status = .read
        }
    }
}
