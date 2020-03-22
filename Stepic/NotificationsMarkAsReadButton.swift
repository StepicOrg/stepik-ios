//
//  NotificationsMarkAsReadButton.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 13.10.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import SnapKit
import UIKit

final class NotificationsMarkAsReadButton: StepikButton {
    enum Status {
        case normal
        case loading
        case error
    }

    var status: Status = .normal

    func update(with status: Status) {
        switch status {
        case .normal:
            self.activityIndicator.stopAnimating()
            self.setTitle(NSLocalizedString("MarkAllAsReadSuccess", comment: ""), for: .normal)
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
                self.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            })
        case .loading:
            self.activityIndicator.startAnimating()
            self.setTitle("", for: .normal)
        case .error:
            self.activityIndicator.stopAnimating()
            self.setTitle(NSLocalizedString("MarkAllAsRead", comment: ""), for: .normal)
            self.status = .normal
        }
    }

    private var activityIndicator = UIActivityIndicatorView()

    override func awakeFromNib() {
        super.awakeFromNib()

        self.addSubview(activityIndicator)
        self.activityIndicator.snp.makeConstraints { make in
            make.center.equalTo(self)
        }
        self.activityIndicator.hidesWhenStopped = true
        self.activityIndicator.color = .stepikLoadingIndicator
    }
}
