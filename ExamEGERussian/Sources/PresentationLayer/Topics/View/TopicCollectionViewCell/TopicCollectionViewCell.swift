//
//  TopicCollectionViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicCollectionViewCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var bodyLabel: UILabel!
    @IBOutlet var commentLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        titleLabel.text = nil
        bodyLabel.text = nil
        commentLabel.text = nil
    }
}
