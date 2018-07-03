//
//  NotificationsMarkAsReadButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit
import SnapKit

class NotificationsMarkAsReadButton: StepikButton {
    enum Status {
        case normal, loading, error
    }

    var status: Status = .normal

    func update(with status: Status) {
        switch status {
        case .normal:
            activityIndicator.stopAnimating()
            setTitle(NSLocalizedString("MarkAllAsReadSuccess", comment: ""), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            })
        case .loading:
            activityIndicator.startAnimating()
            setTitle("", for: .normal)
        case .error:
            activityIndicator.stopAnimating()
            setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            self.status = .normal
        }
    }

    private var activityIndicator = UIActivityIndicatorView()

    override func awakeFromNib() {
        super.awakeFromNib()

        addSubview(activityIndicator)
        activityIndicator.snp.makeConstraints { make -> Void in
            make.center.equalTo(self)
        }
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.mainDark
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)
    }
}
