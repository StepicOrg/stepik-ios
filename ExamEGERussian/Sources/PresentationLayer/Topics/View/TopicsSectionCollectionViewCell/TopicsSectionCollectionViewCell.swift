//
//  TopicsSectionCollectionViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 27/08/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicsSectionCollectionViewCell: UICollectionViewCell, Reusable, NibLoadable {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var actionButton: UIButton!

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        actionButton.setTitle(nil, for: .normal)
    }
}
