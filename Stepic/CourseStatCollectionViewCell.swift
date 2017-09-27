//
//  CourseStatCollectionViewCell.swift
//  Stepic
//
//  Created by Ostrenkiy on 28.09.2017.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class CourseStatCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var text: StepikLabel!
    @IBOutlet weak var image: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func setup(data: CourseStatData) {
        self.image.image = data.image
        self.text.text = data.text
    }
}
