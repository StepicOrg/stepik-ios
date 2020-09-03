//
//  NotificationsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Atributika
import SVProgressHUD
import UIKit

final class NotificationsViewController: UIViewController, NotificationsView {
    var presenter: NotificationsPresenter?

    var section: NotificationsSection!
    var state: NotificationsViewState = .empty {
        didSet {
            switch state {
            case .normal:
                self.refreshControl.endRefreshing()
                self.tableView.tableFooterView = UIView()
            case .refreshing:
                self.refreshControl.beginRefreshing()
                self.tableView.tableFooterView = UIView()
            case .loading:
                self.refreshControl.endRefreshing()
                self.tableView.tableFooterView = paginationView
            case .empty:
                self.refreshControl.endRefreshing()
                self.tableView.tableFooterView = UIView()
            }
        }
    }

    var data: NotificationViewDataStruct = []

    @IBOutlet weak var markAllAsReadButton: NotificationsMarkAsReadButton!
    @IBOutlet weak var markAllAsReadButtonBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadButtonTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var markAllAsReadHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: StepikTableView!

    let refreshControl = UIRefreshControl()

    lazy var paginationView: LoadingPaginationView = {
        let paginationView = LoadingPaginationView(frame: CGRect(x: 0, y: 0, width: self.view.bounds.width, height: 40))
        paginationView.refreshAction = { [weak self] in
            self?.presenter?.loadNextPage()
        }

        paginationView.setLoading()
        return paginationView
    }()

    private let analytics: Analytics = StepikAnalytics.shared

    // How can we incapsulate this?
    func updateMarkAllAsReadButton(with status: NotificationsMarkAsReadButton.Status) {
        markAllAsReadButton.update(with: status)
    }

    @IBAction func onMarkAllAsReadButtonClick(_ sender: Any) {
        presenter?.markAllAsRead()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .stepikBackground

        // Hide "Mark all as read" button
        if self.section != .all {
            self.markAllAsReadButton.isHidden = true
            self.markAllAsReadButtonBottomConstraint.constant = 0
            self.markAllAsReadButtonTopConstraint.constant = 21
            self.markAllAsReadHeightConstraint.constant = 0
        }
        self.markAllAsReadButton.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)

        self.presenter = NotificationsPresenter(
            section: self.section,
            notificationsAPI: ApiDataDownloader.notifications,
            usersAPI: ApiDataDownloader.users,
            notificationsStatusAPI: NotificationStatusesAPI(),
            notificationsRegistrationService: NotificationsRegistrationService(
                presenter: NotificationsRequestAlertPresenter(context: .notificationsTab),
                analytics: .init(source: .notificationsTab)
            ),
            notificationSuggestionManager: NotificationSuggestionManager(),
            analytics: StepikAnalytics.shared,
            view: self
        )

        self.tableView.register(
            UINib(nibName: "NotificationsTableViewCell", bundle: nil),
            forCellReuseIdentifier: NotificationsTableViewCell.reuseId
        )
        self.tableView.register(
            UINib(nibName: "NotificationsSectionHeaderView", bundle: nil),
            forHeaderFooterViewReuseIdentifier: NotificationsSectionHeaderView.reuseId
        )

        self.tableView.estimatedRowHeight = 44.0
        self.tableView.rowHeight = UITableView.automaticDimension

        self.refreshControl.addTarget(self, action: #selector(NotificationsViewController.refreshNotifications), for: .valueChanged)
        self.tableView.refreshControl = refreshControl

        self.tableView.tableFooterView = UIView()

        self.tableView.emptySetPlaceholder = StepikPlaceholder(.emptyNotifications) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        self.analytics.send(.notificationsScreenOpened)
        self.presenter?.didAppear()

        if self.data.isEmpty {
            self.presenter?.loadInitial()
        }
    }

    @objc func refreshNotifications() {
        if self.state == .loading || self.state == .refreshing {
            return
        }

        self.presenter?.refresh()
    }

    func set(notifications: NotificationViewDataStruct, withReload: Bool = true) {
        self.data = notifications

        if withReload {
            self.tableView.reloadData()
        }

        let containsUnreadNotification = self.data.contains { (_, notifications) -> Bool in
            notifications.first(where: { $0.status == .unread }) != nil
        }
        self.markAllAsReadButton.isEnabled = containsUnreadNotification
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.state == .loading || self.state == .refreshing {
            return
        }

        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        let deltaOffset = maximumOffset - currentOffset

        if deltaOffset <= 0 {
            self.presenter?.loadNextPage()
        }
    }
}

extension NotificationsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int { self.data.count }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.data[section].notifications.count
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
                } else {
                    fallthrough
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

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat { 50 }
}

extension NotificationsViewController: NotificationsTableViewCellDelegate {
    func statusButtonClicked(inCell cell: NotificationsTableViewCell, withNotificationId id: Int) {
        self.presenter?.updateNotification(with: id, status: .read)
        self.analytics.send(.markNotificationAsReadTapped(source: .button))

        cell.status = .read
    }

    func linkClicked(inCell cell: NotificationsTableViewCell, url: URL, withNotificationId id: Int) {
        guard let deepLinkURL = URL(string: "https://stepik.org\(url.absoluteString)") else {
            return
        }

        SVProgressHUD.show()

        DeepLinkRouter.routeFromDeepLink(url: deepLinkURL) {
            SVProgressHUD.dismiss()
        }

        self.presenter?.updateNotification(with: id, status: .read)
        self.analytics.send(.markNotificationAsReadTapped(source: .link))

        cell.status = .read
    }
}
