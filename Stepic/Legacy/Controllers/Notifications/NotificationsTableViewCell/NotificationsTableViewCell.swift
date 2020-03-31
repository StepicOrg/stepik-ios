//
//  NotificationsTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 03.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import Atributika
import TTTAttributedLabel
import UIKit

protocol NotificationsTableViewCellDelegate: AnyObject {
    func statusButtonClicked(inCell cell: NotificationsTableViewCell, withNotificationId id: Int)
    func linkClicked(inCell cell: NotificationsTableViewCell, url: URL, withNotificationId id: Int)
}

final class NotificationsTableViewCell: UITableViewCell {
    enum LeftView {
        case avatar(url: URL)
        case category(firstLetter: Character)
    }

    static let reuseId = "notificationsCell"

    private static let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }()

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var sectionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var notificationTextLabel: TTTAttributedLabel!
    @IBOutlet weak var statusButton: NotificationStatusButton!
    @IBOutlet weak var statusButtonProxyView: TapProxyView!

    weak var delegate: NotificationsTableViewCellDelegate?

    private var displayedNotification: NotificationViewData?

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

        self.statusButtonProxyView.targetView = statusButton

        self.notificationTextLabel.delegate = self
        self.avatarImageView.shape = .rectangle(cornerRadius: 4.0)

        self.colorize()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)

        self.performBlockIfAppearanceChanged(from: previousTraitCollection) {
            self.colorize()
        }
    }

    private func colorize() {
        self.timeLabel.textColor = .stepikPrimaryText
        self.sectionLabel.textColor = .stepikAccentFixed
        self.sectionLabel.backgroundColor = .stepikLightSecondaryBackground
    }

    func update(with notification: NotificationViewData) {
        self.displayedNotification = notification

        // State
        self.status = notification.status

        // Text
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 2.2

        let all = Style
            .font(.systemFont(ofSize: self.notificationTextLabel.font.pointSize, weight: .light))
            .foregroundColor(.stepikPrimaryText)
            .paragraphStyle(paragraphStyle)

        let link = Style("a")
            .font(.systemFont(ofSize: self.notificationTextLabel.font.pointSize, weight: .medium))
            .foregroundColor(.stepikPrimaryText)

        let activeLink = Style
            .font(.systemFont(ofSize: self.notificationTextLabel.font.pointSize, weight: .medium))
            .foregroundColor(.stepikPrimaryText)
            .backgroundColor(.stepikSecondaryBackground)

        let styledText = notification.text.style(tags: link).styleAll(all)

        self.notificationTextLabel.linkAttributes = link.attributes
        self.notificationTextLabel.activeLinkAttributes = activeLink.attributes
        self.notificationTextLabel.setText(styledText.attributedString)

        styledText.detections.forEach { detection in
            switch detection.type {
            case .tag(let tag):
                if tag.name == "a", let href = tag.attributes["href"] {
                    self.notificationTextLabel.addLink(
                        to: URL(string: href),
                        with: NSRange(detection.range, in: styledText.string)
                    )
                }
            default:
                break
            }
        }

        self.timeLabel.text = Self.dateFormatter.string(from: notification.time)
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.notificationTextLabel.attributedText = nil
        self.statusButton.reset()
        self.timeLabel.text = nil

        self.updateLeftView(.category(firstLetter: " "))
    }

    func updateLeftView(_ view: LeftView) {
        switch view {
        case .avatar(let url):
            self.sectionLabel.isHidden = true
            self.avatarImageView.isHidden = false
            self.avatarImageView.set(with: url)
        case .category(let firstLetter):
            self.avatarImageView.isHidden = true
            self.sectionLabel.isHidden = false
            self.sectionLabel.text = "\(firstLetter)"
        }
    }

    @IBAction func onStatusButtonClick(_ sender: Any) {
        guard let notification = self.displayedNotification else {
            return
        }

        self.delegate?.statusButtonClicked(inCell: self, withNotificationId: notification.id)
    }
}

extension NotificationsTableViewCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        guard let notification = self.displayedNotification else {
            return
        }

        self.delegate?.linkClicked(inCell: self, url: url, withNotificationId: notification.id)
    }
}
