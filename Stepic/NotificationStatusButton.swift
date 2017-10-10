//
//  NotificationStatusButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 10.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationStatusButton: UIButton {
    var unreadMark: UIView? {
        willSet {
            if let view = newValue {
                self.addSubview(view)
            }
        }
    }

    enum Status {
        case unread, notOpened, read
    }

    var status: Status = .unread {
        willSet {
            if status == .unread && newValue != .unread {
                self.unreadMarkAnimation()
            }
        }
        didSet {
            self.update()
        }
    }

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
        status = .unread
    }

    private func unreadMarkAnimation() {
        UIView.animate(withDuration: 0.45, animations: {
            self.unreadMark?.transform = CGAffineTransform(scaleX: 0.001, y: 0.001)
        }, completion: { _ in
            self.unreadMark?.removeFromSuperview()
            self.unreadMark = nil
        })
    }

    private func update() {
        switch status {
        case .unread:
            self.unreadMark = unreadMarkView
            self.setImage(#imageLiteral(resourceName: "letterSign"), for: .normal)
        case .notOpened:
            self.unreadMark = nil
            self.setImage(#imageLiteral(resourceName: "letterSign"), for: .normal)
        case .read:
            self.unreadMark = nil
            self.setImage(#imageLiteral(resourceName: "readSign"), for: .normal)
        }
    }

    override var isHighlighted: Bool {
        didSet {
            self.unreadMark?.backgroundColor = isHighlighted ? unreadMarkColorHightlighted : unreadMarkColor
        }
    }
}
