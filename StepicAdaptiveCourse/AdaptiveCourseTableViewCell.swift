//
//  AdaptiveCourseTableViewCell.swift
//  Adaptive 1838
//
//  Created by jetbrains on 06/02/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

class AdaptiveCourseTableViewCell: UITableViewCell {
    static let reuseId = "AdaptiveCourseTableViewCell"

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var courseLabel: UILabel!

    func setData(imageLink: URL?, courseName: String) {
        coverImageView.setImageWithURL(url: imageLink, placeholder: #imageLiteral(resourceName: "lesson_cover_50"))
        courseLabel.text = courseName
    }
}
