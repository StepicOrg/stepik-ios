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

    private let meColor = UIColor(hex: 0xFFCC66).withAlphaComponent(0.7)

    override func awakeFromNib() {
        super.awakeFromNib()

        positionLabel.isHidden = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        backgroundColor = .clear
        positionLabel.isHidden = true
    }

    func updateInfo(position: Int, username: String, exp: Int, isMe: Bool = false) {
        updatePosition(position)
        userLabel.text = "\(username)"
        expLabel.text = "\(exp)"

        if isMe {
            backgroundColor = meColor
            userLabel.text = "Вы"
        }
    }

    fileprivate func updatePosition(_ position: Int) {
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
            positionLabel.text = "\(position)."
            positionLabel.isHidden = false
            medalImageView.isHidden = true
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
    }

}
