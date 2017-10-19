//
//  NotificationStatusButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationStatusButton: UIButton {
    var unreadMark: UIView?

    enum Status {
        case unread, opened, read
    }

    var status: Status = .read

    lazy var unreadMarkView: UIView = {
        let mark = UIView()
        mark.frame = CGRect(x: 11, y: -6, width: 12, height: 12)
        mark.clipsToBounds = true
        mark.layer.cornerRadius = 6
        mark.backgroundColor = self.unreadMarkColor
        return mark
    }()

    private let unreadMarkColor = UIColor.stepicGreen
    private let unreadMarkColorHightlighted = UIColor(red: 91 / 255, green: 183 / 255, blue: 91 / 255, alpha: 1.0)

    override func awakeFromNib() {
        setTitle("", for: .normal)
        backgroundColor = .clear
        clipsToBounds = false
    }

    private func unreadMarkAnimation() {
        UIView.animate(withDuration: 0.45, animations: {
            self.unreadMark?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { _ in
            self.unreadMark?.removeFromSuperview()
            self.unreadMark = nil
        })
    }

    func update(with newStatus: Status) {
        switch newStatus {
        case .unread:
            self.setImage(#imageLiteral(resourceName: "letterSign"), for: .normal)
            if status == .read {
                // read -> unread: add mark
                let markView = unreadMarkView
                markView.alpha = 0.0
                unreadMark = markView
                addSubview(markView)
                UIView.animate(withDuration: 0.45, animations: {
                    self.unreadMark?.alpha = 1.0
                })
            }
        case .read:
            self.setImage(#imageLiteral(resourceName: "letterSign"), for: .normal)
            if status == .unread {
                // unread -> read: hide mark
                unreadMarkAnimation()
            }
        case .opened:
            self.setImage(#imageLiteral(resourceName: "readSign"), for: .normal)
            self.isEnabled = false
            if status == .unread {
                unreadMarkAnimation()
            }
        }

        status = newStatus
    }

    func reset() {
        status = .read
        isEnabled = true
        unreadMark?.removeFromSuperview()
        unreadMark = nil
    }

    override var isHighlighted: Bool {
        didSet {
            self.unreadMark?.backgroundColor = isHighlighted ? unreadMarkColorHightlighted : unreadMarkColor
        }
    }
}
