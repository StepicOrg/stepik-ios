//
//  ParagraphTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 02.11.17.
//  Copyright © 2017 Alex Karpov. All rights reserved.
//

import UIKit

class ParagraphTableViewCell: UITableViewCell {

    static var reuseIdentifier: String { return "ParagraphTableViewCell" }
    static var size: CGFloat { get { return CGFloat(66) } }

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var progressIcon: UIImageView!

    private var index: Int?
    private var paragraphName: String?

    func configure(with index: Int, _ paragraphName: String) {
        self.index = index
        self.paragraphName = paragraphName

        self.nameLabel.text = "\(index). \(paragraphName)"
    }
}
