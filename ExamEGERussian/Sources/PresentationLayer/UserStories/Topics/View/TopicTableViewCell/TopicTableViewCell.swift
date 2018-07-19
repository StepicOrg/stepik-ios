//
//  TopicTableViewCell.swift
//  ExamEGERussian
//
//  Created by Ivan Magda on 19/07/2018.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//

import UIKit

final class TopicTableViewCell: UITableViewCell, TopicCellView {
    @IBOutlet var descriptionTitleLabel: UILabel!

    func display(title: String) {
        descriptionTitleLabel.text = title
    }
}
