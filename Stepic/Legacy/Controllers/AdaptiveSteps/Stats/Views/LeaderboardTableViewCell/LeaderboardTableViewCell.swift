//
//  LeaderboardTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

final class LeaderboardTableViewCell: UITableViewCell {
    static let reuseId = "LeaderboardTableViewCell"

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var separatorImageView: UIImageView!

    private var isMe: Bool = false
    private var isMeBackgroundColor: UIColor {
        .dynamic(
            light: UIColor.stepikYellow.withAlphaComponent(0.4),
            dark: UIColor.stepikYellow.withAlphaComponent(0.1)
        )
    }

    var isSeparator: Bool = false {
        didSet {
            self.separatorImageView.isHidden = !self.isSeparator
            self.userLabel.isHidden = self.isSeparator
            self.expLabel.isHidden = self.isSeparator
            self.medalImageView.isHidden = self.isSeparator
            self.positionLabel.isHidden = self.isSeparator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.positionLabel.isHidden = true
        self.separatorImageView.image = UIImage(named: "more")?.withRenderingMode(.alwaysTemplate)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.colorize()
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        self.isMe = false
        self.isSeparator = false
        self.positionLabel.isHidden = true

        self.layoutIfNeeded()
    }

    func updateInfo(position: Int, username: String, exp: Int, isMe: Bool = false) {
        self.updatePosition(position)
        self.userLabel.text = "\(username)"
        self.expLabel.text = "\(exp)"

        self.isMe = isMe

        if isMe {
            self.backgroundColor = self.isMeBackgroundColor
            self.userLabel.text = NSLocalizedString("AdaptiveRatingYou", comment: "")
        }
    }

    private func updatePosition(_ position: Int) {
        self.medalImageView.isHidden = false
        self.positionLabel.isHidden = true
        self.positionLabel.text = "\(position)."

        switch position {
        case 1:
            self.medalImageView.image = UIImage(named: "medal1")
        case 2:
            self.medalImageView.image = UIImage(named: "medal2")
        case 3:
            self.medalImageView.image = UIImage(named: "medal3")
        default:
            self.positionLabel.isHidden = false
            self.medalImageView.isHidden = true
        }
    }

    private func colorize() {
        self.backgroundColor = self.isMe ? self.isMeBackgroundColor : .clear
        self.separatorImageView.tintColor = .stepikSeparator
        self.userLabel.textColor = .stepikSystemGray
        self.positionLabel.textColor = .stepikSystemGray
        self.expLabel.textColor = .stepikSystemGray2
    }
}
