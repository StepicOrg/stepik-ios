//
//  NotificationsTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import TTTAttributedLabel
import Atributika

protocol NotificationsTableViewCellDelegate: class {
    func statusButtonClicked(inCell cell: NotificationsTableViewCell, withNotificationId id: Int)
    func linkClicked(inCell cell: NotificationsTableViewCell, url: URL, withNotificationId id: Int)
}

class NotificationsTableViewCell: UITableViewCell {
    static let reuseId = "notificationsCell"

    enum LeftView {
        case avatar(url: URL)
        case category(firstLetter: Character)
    }

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: TTTAttributedLabel!
    @IBOutlet weak var statusButton: NotificationStatusButton!
    @IBOutlet weak var statusButtonProxyView: TapProxyView!

    weak var delegate: NotificationsTableViewCellDelegate?

    fileprivate var displayedNotification: NotificationViewData?

    var status: NotificationStatus = .unread {
        didSet {
            switch status {
            case .read:
                statusButton.update(with: .read)
            case .unread:
                statusButton.update(with: .unread)
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        statusButtonProxyView.targetView = statusButton

        notificationTextLabel.delegate = self
        avatarImageView.shape = .rectangle(cornerRadius: 4.0)
    }

    func update(with notification: NotificationViewData) {
        displayedNotification = notification

        // State
        status = notification.status

        // Text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.2

        let all = Style.font(.systemFont(ofSize: notificationTextLabel.font.pointSize, weight: UIFontWeightLight))
                       .foregroundColor(UIColor.mainText)
                       .paragraphStyle(paragraphStyle)
        let link = Style("a").font(.systemFont(ofSize: notificationTextLabel.font.pointSize, weight: UIFontWeightMedium)).foregroundColor(UIColor.mainText)
        let activeLink = Style.font(.systemFont(ofSize: notificationTextLabel.font.pointSize, weight: UIFontWeightMedium))
                        .foregroundColor(UIColor.mainText)
                        .backgroundColor(UIColor(hex: 0xF6F6F6))

        let styledText = notification.text.style(tags: link).styleAll(all)

        notificationTextLabel.linkAttributes = link.attributes
        notificationTextLabel.activeLinkAttributes = activeLink.attributes
        notificationTextLabel.setText(styledText.attributedString)

        styledText.detections.forEach { detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"] {
                    notificationTextLabel.addLink(to: URL(string: href), with: NSRange(detection.range))
                }
            default: break
            }
        }

        // Date
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        let dateString = formatter.string(from: notification.time)
        timeLabel.text = dateString
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        notificationTextLabel.attributedText = nil
        statusButton.reset()
        timeLabel.text = nil

        updateLeftView(.category(firstLetter: " "))
    }

    func updateLeftView(_ view: LeftView) {
        switch view {
        case .avatar(let url):
            sectionLabel.isHidden = true
            avatarImageView.isHidden = false
            avatarImageView.set(with: url)
        case .category(let firstLetter):
            avatarImageView.isHidden = true
            sectionLabel.isHidden = false
            sectionLabel.text = "\(firstLetter)"
        }
    }

    @IBAction func onStatusButtonClick(_ sender: Any) {
        guard let notification = displayedNotification else {
            return
        }
        delegate?.statusButtonClicked(inCell: self, withNotificationId: notification.id)
    }
}

extension NotificationsTableViewCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard let notification = displayedNotification else {
            return
        }
        delegate?.linkClicked(inCell: self, url: url, withNotificationId: notification.id)
    }
}
