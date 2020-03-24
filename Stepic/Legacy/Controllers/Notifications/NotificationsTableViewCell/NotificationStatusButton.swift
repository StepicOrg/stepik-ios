//
//  NotificationStatusButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class NotificationStatusButton: UIButton {
    enum Status {
        case unread
        case read
    }

    private var unreadMark: UIView?

    private var status: Status = .read

    private lazy var unreadMarkView: UIView = {
        let mark = UIView()
        mark.frame = CGRect(x: 11, y: -6, width: 12, height: 12)
        mark.clipsToBounds = true
        mark.layer.cornerRadius = 6
        mark.backgroundColor = self.unreadMarkColor
        return mark
    }()

    private let unreadMarkColor = UIColor.stepikGreen
    private let unreadMarkColorHightlighted = UIColor(red: 91 / 255, green: 183 / 255, blue: 91 / 255, alpha: 1.0)

    override var isHighlighted: Bool {
        didSet {
            self.unreadMark?.backgroundColor = isHighlighted ? unreadMarkColorHightlighted : unreadMarkColor
        }
    }

    override func awakeFromNib() {
        self.setTitle("", for: .normal)
        self.backgroundColor = .clear
        self.tintColor = .stepikAccent
        self.clipsToBounds = false

        self.adjustsImageWhenDisabled = false
    }

    func update(with newStatus: Status) {
        switch newStatus {
        case .unread:
            self.setImage(UIImage(named: "notifications-letter-sign")?.withRenderingMode(.alwaysTemplate), for: .normal)
            // read -> unread: add mark
            let markView = unreadMarkView
            markView.alpha = 0.0
            markView.transform = .identity
            unreadMark = markView
            addSubview(markView)
            UIView.animate(withDuration: 0.45, animations: {
                self.unreadMark?.alpha = 1.0
            })
        case .read:
            self.setImage(UIImage(named: "notifications-check-sign")?.withRenderingMode(.alwaysTemplate), for: .normal)
            self.isEnabled = false
            if status == .unread {
                // unread -> read: hide mark
                unreadMarkAnimation()
            }
        }

        status = newStatus
    }

    func reset() {
        self.status = .read
        self.isEnabled = true
        self.unreadMark?.removeFromSuperview()
        self.unreadMark = nil
    }

    private func unreadMarkAnimation() {
        UIView.animate(withDuration: 0.45, animations: {
            self.unreadMark?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { _ in
            self.unreadMark?.removeFromSuperview()
            self.unreadMark = nil
        })
    }
}
