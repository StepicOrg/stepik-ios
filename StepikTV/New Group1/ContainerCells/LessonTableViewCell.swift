//
//  LessonTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 07.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

extension UILabel {

    var textSize: CGSize? {
        guard let labelText = text else {
            return nil
        }

        let labelTextSize = (labelText as NSString).size(attributes: [NSFontAttributeName: font])

        return labelTextSize
    }
}

class LessonTableViewCell: UITableViewCell {

    static var reuseIdentifier: String { get { return "LessonTableViewCell" } }

    static var estimatedSize: CGFloat { get { return CGFloat(90) } }

    @IBOutlet var indexLabel: UILabel!

    @IBOutlet var nameLabel: UILabel!

    @IBOutlet var progressLabel: UILabel!

    @IBOutlet var progressIcon: UIImageView!

    @IBOutlet weak var progressLabelWidth: NSLayoutConstraint!

    @IBOutlet weak var indexLabelWidth: NSLayoutConstraint!

    func configure(with paragraphIndex: Int, _ lessonIndex: Int, _ name: String) {

        self.indexLabel.text = "\(paragraphIndex).\(lessonIndex)."
        self.nameLabel.text = name

        indexLabelWidth.constant = (indexLabel.textSize?.width ?? 0) + CGFloat(1)
        progressLabelWidth.constant = (progressLabel.textSize?.width ?? 0) + CGFloat(1)
    }

}
