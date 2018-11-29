//
//  NotificationsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import Atributika

class NotificationsViewController: UIViewController, NotificationsView {
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
            markAllAsReadButtonTopConstraint.constant = 21
            markAllAsReadHeightConstraint.constant = 0
        }
        markAllAsReadButton.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)

        presenter = NotificationsPresenter(
            section: section,
            notificationsAPI: ApiDataDownloader.notifications,
            usersAPI: ApiDataDownloader.users,
            notificationsStatusAPI: NotificationStatusesAPI(),
            notificationsRegistrationService: NotificationsRegistrationService(
                presenter: NotificationsRequestAlertPresenter(context: .notificationsTab),
                analytics: .init(source: .notificationsTab)
            ),
            notificationSuggestionManager: NotificationSuggestionManager(),
            view: self,
            splitTestingService: SplitTestingService(
                analyticsService: AnalyticsUserProperties(),
                storage: UserDefaults.standard
            )
        )

        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: NotificationsTableViewCell.reuseId)
        tableView.register(UINib(nibName: "NotificationsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: NotificationsSectionHeaderView.reuseId)

        tableView.estimatedRowHeight = 44.0
        tableView.rowHeight = UITableViewAutomaticDimension

//        if #available(iOS 11.0, *) {
//            tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
//        }

        refreshControl.addTarget(self, action: #selector(NotificationsViewController.refreshNotifications), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        self.tableView.tableFooterView = UIView()

        tableView.emptySetPlaceholder = StepikPlaceholder(.emptyNotifications) { [weak self] in
            self?.tabBarController?.selectedIndex = 1
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        AmplitudeAnalyticsEvents.Notifications.screenOpened.send()
        presenter?.didAppear()

        if data.isEmpty {
            presenter?.loadInitial()
        }
    }

    @objc func refreshNotifications() {
        if state == .loading || state == .refreshing {
            return
        }

        presenter?.refresh()
    }

    func set(notifications: NotificationViewDataStruct, withReload: Bool = true) {
        self.data = notifications
        if withReload {
            tableView.reloadData()
        }
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
}

extension NotificationsViewController: NotificationsTableViewCellDelegate {
    func statusButtonClicked(inCell cell: NotificationsTableViewCell, withNotificationId id: Int) {
        presenter?.updateNotification(with: id, status: .read)
        AnalyticsReporter.reportEvent(AnalyticsEvents.Notifications.markAsRead, parameters: ["action": "button"])

        cell.status = .read
    }

    func linkClicked(inCell cell: NotificationsTableViewCell, url: URL, withNotificationId id: Int) {
        let deepLinkingUrlString = "https://stepik.org" + url.absoluteString
        if let deepLinkingUrl = URL(string: deepLinkingUrlString) {
            DeepLinkRouter.routeFromDeepLink(url: deepLinkingUrl)

            presenter?.updateNotification(with: id, status: .read)
            AnalyticsReporter.reportEvent(AnalyticsEvents.Notifications.markAsRead, parameters: ["action": "link"])

            cell.status = .read
        }
    }
}
