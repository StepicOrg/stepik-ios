//
//  NotificationsMarkAsReadButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class NotificationsMarkAsReadButton: StepikButton {
    enum Status {
        case normal, loading, error
    }

    var status: Status = .normal

    func update(with status: Status) {
        switch status {
        case .normal:
            activityIndicator.isHidden = true
            setTitle(NSLocalizedString("MarkAllAsReadSuccess", comment: ""), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            })
        case .loading:
            activityIndicator.isHidden = false
            setTitle("", for: .normal)
        case .error:
            activityIndicator.isHidden = true
            setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            self.status = .normal
        }
    }

    private var activityIndicator = UIActivityIndicatorView()

    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(activityIndicator)
        activityIndicator.alignCenter(withView: self)
        activityIndicator.color = UIColor.mainDark
        activityIndicator.startAnimating()
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
        activityIndicator.isHidden = true
    }
}
