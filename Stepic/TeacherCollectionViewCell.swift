//
//  TeacherCollectionViewCell.swift
//  Stepic
//
//  Created by Alexander Karpov on 30.09.15.
//  Copyright © 2015 Alex Karpov. All rights reserved.
//

import UIKit

class TeacherCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var avatarImageView: AvatarImageView!
    @IBOutlet weak var nameLabel: StepikLabel!
    @IBOutlet weak var infoLabel: StepikLabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization codex
        infoLabel.isGray = true
    }

    func initWithUser(_ user: User) {
        if let url = URL(string: user.avatarURL) {
            avatarImageView.set(with: url)
        }

        nameLabel.text = "\(user.firstName) \(user.lastName)"
        infoLabel.text = user.bio
    }

}
