//
//  RightDetailedCustomTableViewCell.swift
//  StepikTV
//
//  Created by Александр Пономарев on 16.02.18.
//  Copyright © 2018 Alex Karpov. All rights reserved.
//


import UIKit

class RightDetailedCustomTableViewCell: FocusableCustomTableViewCell {

    static var reuseIdentifier: String { return "RightDetailedCustomTableViewCell" }
    static var size: CGFloat { get { return CGFloat(66) } }

    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var detailedLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        changeToDefault()
    }

    func setup(with title: String, detailed: String? = nil) {
        self.titleLabel.text = title
        self.detailedLabel.text = detailed
    }

    override func changeToDefault() {
        super.changeToDefault()
        titleLabel?.textColor = UIColor.black.withAlphaComponent(0.1)
        detailedLabel?.textColor = UIColor.black.withAlphaComponent(0.1)
    }

    override func changeToFocused() {
        super.changeToFocused()
        titleLabel?.textColor = UIColor.white
        detailedLabel?.textColor = UIColor.white
    }
}
