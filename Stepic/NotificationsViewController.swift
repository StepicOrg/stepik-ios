//
//  NotificationsViewController.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 26.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import DZNEmptyDataSet
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
                self.tableView.reloadEmptyDataSet()
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

        presenter = NotificationsPresenter(section: section, notificationsAPI: ApiDataDownloader.notifications, usersAPI: ApiDataDownloader.users, view: self)

        tableView.register(UINib(nibName: "NotificationsTableViewCell", bundle: nil), forCellReuseIdentifier: NotificationsTableViewCell.reuseId)
        tableView.register(UINib(nibName: "NotificationsSectionHeaderView", bundle: nil), forHeaderFooterViewReuseIdentifier: NotificationsSectionHeaderView.reuseId)

        #if swift(>=3.2)
            if #available(iOS 11.0, *) {
                tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentBehavior.never
            }
        #endif

        refreshControl.addTarget(self, action: #selector(NotificationsViewController.refreshNotifications), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }

        self.tableView.tableFooterView = UIView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if data.isEmpty {
            presenter?.loadInitial()
        }
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
        if cell.status == .unread {
            presenter?.updateNotification(with: id, status: .read)
            cell.status = .read
        }
    }
}

extension NotificationsViewController: DZNEmptyDataSetSource {
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return #imageLiteral(resourceName: "white_pixel")
    }

    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let text: String = NSLocalizedString("NoNotifications", comment: "")

        let style = Style.font(.systemFont(ofSize: 18.0, weight: UIFontWeightLight))
            .foregroundColor(UIColor.mainDark.withAlphaComponent(0.4))
        return text.styleAll(style).attributedString
    }

    func backgroundColor(forEmptyDataSet scrollView: UIScrollView!) -> UIColor! {
        return .white
    }
}

extension NotificationsViewController: DZNEmptyDataSetDelegate {
    func emptyDataSetShouldAllowScroll(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
}
