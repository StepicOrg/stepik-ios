//
//  LeaderboardTableViewCell.swift
//  Stepic
//
//  Created by Vladislav Kiryukhin on 15.08.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class LeaderboardTableViewCell: UITableViewCell {
    static let reuseId = "LeaderboardTableViewCell"

    @IBOutlet weak var userLabel: UILabel!
    @IBOutlet weak var expLabel: UILabel!
    @IBOutlet weak var medalImageView: UIImageView!
    @IBOutlet weak var positionLabel: UILabel!
    @IBOutlet weak var separatorImageView: UIImageView!

    private let meColor = UIColor(hex: 0xFFDCA5)

    var isSeparator: Bool = false {
        didSet {
            separatorImageView.isHidden = !isSeparator
            userLabel.isHidden = isSeparator
            expLabel.isHidden = isSeparator
            medalImageView.isHidden = isSeparator
            positionLabel.isHidden = isSeparator
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        backgroundColor = .clear
        positionLabel.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundColor = .clear
        isSeparator = false
        positionLabel.isHidden = true
        layoutIfNeeded()
    }

    func updateInfo(position: Int, username: String, exp: Int, isMe: Bool = false) {
        updatePosition(position)
        userLabel.text = "\(username)"
        expLabel.text = "\(exp)"

        if isMe {
            self.backgroundColor = meColor
            userLabel.text = NSLocalizedString("AdaptiveRatingYou", comment: "")
        }
    }

    fileprivate func updatePosition(_ position: Int) {
        medalImageView.isHidden = false
        positionLabel.isHidden = true
        positionLabel.text = "\(position)."
        switch position {
        case 1:
            medalImageView.image = #imageLiteral(resourceName: "medal1")
            break
        case 2:
            medalImageView.image = #imageLiteral(resourceName: "medal2")
            break
        case 3:
            medalImageView.image = #imageLiteral(resourceName: "medal3")
            break
        default:
            positionLabel.isHidden = false
            medalImageView.isHidden = true
        }
    }
}
