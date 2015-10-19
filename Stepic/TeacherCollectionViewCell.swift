//
//  TeacherCollectionViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class TeacherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codex
    }

    func initWithUser(user: User) {
    
        avatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!, placeholderImage: Constants.placeholderImage, completed: {
            _, _, _, _ in
            self.avatarImageView.setRoundedBounds(width: 1, color: UIColor.whiteColor())

        })
//        avatarImageView.sd_setImageWithURL(NSURL(string: user.avatarURL)!, placeholderImage: Constants.placeholderImage)
//        avatarImageView.setRoundedBounds(width: 1, color: UIColor.whiteColor())
        nameLabel.text = "\(user.firstName) \(user.lastName)"
        infoLabel.text = user.bio
    }
    
}
